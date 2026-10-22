-- ============================================================================
-- MY CAMPUS LIFE - SUPABASE POSTGRESQL CLOUD DATABASE SCHEMA
-- ============================================================================
-- Free Tier Compatible: Up to 50,000 monthly active users (GoTrue Auth + PostgreSQL)
-- Execute this script in your Supabase Dashboard: SQL Editor -> New Query -> Run

-- 1. Create Student Profiles Table
CREATE TABLE IF NOT EXISTS public.student_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    matric_no TEXT UNIQUE NOT NULL,
    department TEXT NOT NULL,
    faculty TEXT NOT NULL,
    gender TEXT DEFAULT 'Male',
    level INT DEFAULT 100,
    semester INT DEFAULT 1,
    cgpa NUMERIC(3,2) DEFAULT 3.50,
    wallet_balance INT DEFAULT 5000,
    complexion_idx INT DEFAULT 0,
    hairstyle_idx INT DEFAULT 0,
    shirt_idx INT DEFAULT 0,
    trouser_idx INT DEFAULT 0,
    owned_upgrades JSONB DEFAULT '[]'::jsonb,
    backpack_items JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Performance Indexes for Dean's List and Wealth Leaderboards
CREATE INDEX IF NOT EXISTS idx_student_profiles_cgpa ON public.student_profiles(cgpa DESC);
CREATE INDEX IF NOT EXISTS idx_student_profiles_wallet ON public.student_profiles(wallet_balance DESC);
CREATE INDEX IF NOT EXISTS idx_student_profiles_dept ON public.student_profiles(department);

-- 3. Enable Row-Level Security (RLS)
ALTER TABLE public.student_profiles ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies:
-- Allow anyone to read profiles (needed for global Dean's List and Wealth leaderboards)
CREATE POLICY "Public read profiles for leaderboards"
    ON public.student_profiles
    FOR SELECT
    USING (true);

-- Allow authenticated students to insert their own profile upon admission
CREATE POLICY "Students can insert own profile"
    ON public.student_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Allow authenticated students to update their own profile during cloud sync
CREATE POLICY "Students can update own profile"
    ON public.student_profiles
    FOR UPDATE
    USING (auth.uid() = id);

-- 5. Auto-update timestamp trigger
CREATE OR REPLACE FUNCTION public.handle_student_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_student_profiles_updated ON public.student_profiles;
CREATE TRIGGER on_student_profiles_updated
    BEFORE UPDATE ON public.student_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_student_updated_at();
