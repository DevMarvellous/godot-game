-- ============================================================================
-- MY CAMPUS LIFE - SUPABASE POSTGRESQL, SECURITY & LIVE CONFIG SCHEMA
-- Run this script in your Supabase SQL Editor to initialize the backend.
-- ============================================================================

-- 1. Student Profiles Table (Cloud Saves, Login, Dean's List & Wealth Leaderboards)
CREATE TABLE IF NOT EXISTS public.student_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    student_name TEXT NOT NULL DEFAULT 'Tunde Adeleke' CHECK (char_length(student_name) <= 36),
    student_email TEXT UNIQUE,
    gender TEXT NOT NULL DEFAULT 'Male' CHECK (gender IN ('Male', 'Female')),
    matric_no TEXT UNIQUE NOT NULL DEFAULT '2026/CSC/101',
    department TEXT NOT NULL DEFAULT 'CSC',
    admitted_course_title TEXT NOT NULL DEFAULT 'Computer Science',
    admitted_faculty TEXT NOT NULL DEFAULT 'Science & Computing',
    cgpa NUMERIC(3, 2) NOT NULL DEFAULT 3.50 CHECK (cgpa >= 0.00 AND cgpa <= 5.00),
    wallet_balance INTEGER NOT NULL DEFAULT 5000 CHECK (wallet_balance >= 0 AND wallet_balance <= 100000000),
    current_level INTEGER NOT NULL DEFAULT 100 CHECK (current_level IN (100, 200, 300, 400, 500)),
    current_semester INTEGER NOT NULL DEFAULT 1 CHECK (current_semester IN (1, 2)),
    complexion_index INTEGER NOT NULL DEFAULT 1 CHECK (complexion_index >= 0 AND complexion_index <= 10),
    hair_index INTEGER NOT NULL DEFAULT 0 CHECK (hair_index >= 0 AND hair_index <= 20),
    shirt_index INTEGER NOT NULL DEFAULT 0 CHECK (shirt_index >= 0 AND shirt_index <= 20),
    trouser_index INTEGER NOT NULL DEFAULT 0 CHECK (trouser_index >= 0 AND trouser_index <= 20),
    owned_upgrades JSONB NOT NULL DEFAULT '[]'::jsonb,
    backpack_items JSONB NOT NULL DEFAULT '[]'::jsonb,
    secret_token TEXT DEFAULT '',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for fast Global Leaderboards & Username Login
CREATE INDEX IF NOT EXISTS idx_student_profiles_cgpa ON public.student_profiles (cgpa DESC);
CREATE INDEX IF NOT EXISTS idx_student_profiles_wallet ON public.student_profiles (wallet_balance DESC);
CREATE INDEX IF NOT EXISTS idx_student_profiles_username ON public.student_profiles (username);

-- 2. Live Room Presence Table (Multiplayer Room Tracking)
CREATE TABLE IF NOT EXISTS public.room_presence (
    peer_id TEXT PRIMARY KEY,
    student_name TEXT NOT NULL CHECK (char_length(student_name) <= 40),
    department TEXT NOT NULL DEFAULT 'CSC',
    room_name TEXT NOT NULL DEFAULT 'Courtyard',
    pos_x REAL NOT NULL DEFAULT 0.0 CHECK (pos_x >= -100.0 AND pos_x <= 100.0),
    pos_y REAL NOT NULL DEFAULT 0.1 CHECK (pos_y >= -5.0 AND pos_y <= 20.0),
    pos_z REAL NOT NULL DEFAULT 0.0 CHECK (pos_z >= -100.0 AND pos_z <= 100.0),
    rot_y REAL NOT NULL DEFAULT 0.0,
    is_moving BOOLEAN NOT NULL DEFAULT FALSE,
    shirt_col TEXT NOT NULL DEFAULT '#1e824c',
    trouser_col TEXT NOT NULL DEFAULT '#273746',
    last_seen TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Campus Realtime Chat Log (With Length Guard)
CREATE TABLE IF NOT EXISTS public.campus_chat_messages (
    id BIGSERIAL PRIMARY KEY,
    peer_id TEXT NOT NULL,
    sender_name TEXT NOT NULL CHECK (char_length(sender_name) <= 40),
    room_name TEXT NOT NULL DEFAULT 'Courtyard',
    message TEXT NOT NULL CHECK (char_length(message) >= 1 AND char_length(message) <= 140),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Peer-to-Peer CampusPay Money Transfers Table
CREATE TABLE IF NOT EXISTS public.campus_transfers (
    id BIGSERIAL PRIMARY KEY,
    sender_username TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    recipient_username TEXT NOT NULL,
    amount INTEGER NOT NULL CHECK (amount >= 100 AND amount <= 1000000),
    note TEXT NOT NULL DEFAULT 'CampusPay P2P Transfer',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Backend Live Game Config Table (Edit Game Content/Economy Without Rebuilding!)
CREATE TABLE IF NOT EXISTS public.game_live_config (
    config_key TEXT PRIMARY KEY,
    config_value JSONB NOT NULL DEFAULT '{}'::jsonb,
    description TEXT NOT NULL DEFAULT '',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.game_live_config (config_key, config_value, description)
VALUES
    ('announcement', '{"title": "⚡ SUG WEEK & HACKATHON LIVE!", "body": "Visit the new Silicon Lagoon Tech Hub & Medical Clinic! Win ₦4,500 in the Campus Hackathon."}'::jsonb, 'Live campus banner shown to all online players'),
    ('economy', '{"gig_payout_multiplier": 1.0, "food_price_multiplier": 1.0, "fresher_allowance": 30000, "scholarship_reward": 25000}'::jsonb, 'Global economy balance multipliers editable in real time')
ON CONFLICT (config_key) DO NOTHING;

-- 6. Row-Level Security (RLS) Policies
ALTER TABLE public.student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_live_config ENABLE ROW LEVEL SECURITY;

-- Public read/write policies
CREATE POLICY "Public read student profiles" ON public.student_profiles FOR SELECT USING (true);
CREATE POLICY "Authenticated or anon upsert own profile" ON public.student_profiles FOR ALL USING (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Public access room presence" ON public.room_presence FOR ALL USING (true);
CREATE POLICY "Public access campus chat" ON public.campus_chat_messages FOR ALL USING (true);
CREATE POLICY "Public access campus transfers" ON public.campus_transfers FOR ALL USING (true);
CREATE POLICY "Public read live game config" ON public.game_live_config FOR SELECT USING (true);

-- 7. Enable Supabase Realtime Broadcast & Presence on tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.room_presence;
ALTER PUBLICATION supabase_realtime ADD TABLE public.campus_chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.campus_transfers;
ALTER PUBLICATION supabase_realtime ADD TABLE public.game_live_config;

-- 8. Atomic Server-Side Money Transfer RPC (Anti-Cheat & Double-Spending Prevention)
CREATE OR REPLACE FUNCTION public.execute_campus_transfer(
    p_sender_username TEXT,
    p_recipient_username TEXT,
    p_amount INTEGER,
    p_note TEXT DEFAULT 'CampusPay Transfer'
) RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_sender RECORD;
    v_recipient RECORD;
    v_new_sender_bal INTEGER;
    v_new_recipient_bal INTEGER;
BEGIN
    IF p_amount < 100 OR p_amount > 1000000 THEN
        RETURN jsonb_build_object('success', false, 'error', 'Transfer amount must be between ₦100 and ₦1,000,000');
    END IF;

    IF lower(p_sender_username) = lower(p_recipient_username) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Cannot transfer money to yourself');
    END IF;

    -- Fetch and lock sender
    SELECT * INTO v_sender FROM public.student_profiles
    WHERE lower(username) = lower(p_sender_username)
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Sender account not found in Campus Registry');
    END IF;

    IF v_sender.wallet_balance < p_amount THEN
        RETURN jsonb_build_object('success', false, 'error', 'Insufficient funds in CampusPay wallet');
    END IF;

    -- Fetch and lock recipient
    SELECT * INTO v_recipient FROM public.student_profiles
    WHERE lower(username) = lower(p_recipient_username)
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Recipient not found on campus');
    END IF;

    -- Perform atomic transfer
    v_new_sender_bal := v_sender.wallet_balance - p_amount;
    v_new_recipient_bal := v_recipient.wallet_balance + p_amount;

    UPDATE public.student_profiles
    SET wallet_balance = v_new_sender_bal, updated_at = NOW()
    WHERE id = v_sender.id;

    UPDATE public.student_profiles
    SET wallet_balance = v_new_recipient_bal, updated_at = NOW()
    WHERE id = v_recipient.id;

    -- Log transaction
    INSERT INTO public.campus_transfers (sender_username, sender_name, recipient_username, amount, note)
    VALUES (v_sender.username, v_sender.student_name, v_recipient.username, p_amount, p_note);

    RETURN jsonb_build_object(
        'success', true,
        'sender_balance', v_new_sender_bal,
        'recipient_balance', v_new_recipient_bal,
        'amount', p_amount
    );
END;
$$;
