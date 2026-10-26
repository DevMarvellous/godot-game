-- ============================================================================
-- MY CAMPUS LIFE - SUPABASE POSTGRESQL & REALTIME CLOUD SCHEMA
-- Run this script in your Supabase SQL Editor to initialize the backend.
-- ============================================================================

-- 1. Student Profiles Table (Cloud Saves, Dean's List & Wealth Leaderboards)
CREATE TABLE IF NOT EXISTS public.student_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    student_name TEXT NOT NULL DEFAULT 'Tunde Adeleke',
    student_email TEXT UNIQUE,
    gender TEXT NOT NULL DEFAULT 'Male',
    matric_no TEXT NOT NULL DEFAULT '2026/CSC/101',
    department TEXT NOT NULL DEFAULT 'CSC',
    admitted_course_title TEXT NOT NULL DEFAULT 'Computer Science',
    admitted_faculty TEXT NOT NULL DEFAULT 'Science & Computing',
    cgpa NUMERIC(3, 2) NOT NULL DEFAULT 3.50,
    wallet_balance INTEGER NOT NULL DEFAULT 5000,
    current_level INTEGER NOT NULL DEFAULT 100,
    current_semester INTEGER NOT NULL DEFAULT 1,
    complexion_index INTEGER NOT NULL DEFAULT 1,
    hair_index INTEGER NOT NULL DEFAULT 0,
    shirt_index INTEGER NOT NULL DEFAULT 0,
    trouser_index INTEGER NOT NULL DEFAULT 0,
    owned_upgrades JSONB NOT NULL DEFAULT '[]'::jsonb,
    backpack_items JSONB NOT NULL DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for fast Global Leaderboards
CREATE INDEX IF NOT EXISTS idx_student_profiles_cgpa ON public.student_profiles (cgpa DESC);
CREATE INDEX IF NOT EXISTS idx_student_profiles_wallet ON public.student_profiles (wallet_balance DESC);

-- 2. Live Room Presence Table (Multiplayer Room Tracking)
CREATE TABLE IF NOT EXISTS public.room_presence (
    peer_id TEXT PRIMARY KEY,
    student_name TEXT NOT NULL,
    department TEXT NOT NULL DEFAULT 'CSC',
    room_name TEXT NOT NULL DEFAULT 'Courtyard',
    pos_x REAL NOT NULL DEFAULT 0.0,
    pos_y REAL NOT NULL DEFAULT 0.1,
    pos_z REAL NOT NULL DEFAULT 0.0,
    rot_y REAL NOT NULL DEFAULT 0.0,
    is_moving BOOLEAN NOT NULL DEFAULT FALSE,
    shirt_col TEXT NOT NULL DEFAULT '#1e824c',
    trouser_col TEXT NOT NULL DEFAULT '#273746',
    last_seen TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Campus Realtime Chat Log
CREATE TABLE IF NOT EXISTS public.campus_chat_messages (
    id BIGSERIAL PRIMARY KEY,
    peer_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    room_name TEXT NOT NULL DEFAULT 'Courtyard',
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Row-Level Security (RLS) Policies
ALTER TABLE public.student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_chat_messages ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read leaderboards & room presence
CREATE POLICY "Public read student profiles" ON public.student_profiles
    FOR SELECT USING (true);

CREATE POLICY "Authenticated upsert own profile" ON public.student_profiles
    FOR ALL USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Public access room presence" ON public.room_presence
    FOR ALL USING (true);

CREATE POLICY "Public access campus chat" ON public.campus_chat_messages
    FOR ALL USING (true);

-- 5. Enable Supabase Realtime Broadcast & Presence on tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.room_presence;
ALTER PUBLICATION supabase_realtime ADD TABLE public.campus_chat_messages;
