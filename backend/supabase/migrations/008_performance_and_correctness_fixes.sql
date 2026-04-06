-- Migration: Performance and Correctness Fixes
-- Description: Fix RLS policy performance, CHECK constraint bug, missing indexes, and trigger date arithmetic
-- Created: 2026-04-06
--
-- Changes:
--   1. FORCE ROW LEVEL SECURITY on all tables
--   2. Fix duration_seconds CHECK (> 0 → >= 0, allows the backend's default of 0/null)
--   3. Add composite index on practice_sessions(child_id, session_date DESC)
--   4. Add GIN index on game_progress.badges JSONB
--   5. Rebuild all RLS policies: wrap auth.uid() in (SELECT ...) to evaluate once per query
--      and simplify child-ownership subqueries (remove unnecessary JOIN to accounts)
--   6. Fix date arithmetic in trigger: INTERVAL '1 day' → integer + 1 (keeps DATE type)

-- ============================================================================
-- 1. FORCE ROW LEVEL SECURITY (applies RLS even to table owner)
-- ============================================================================

ALTER TABLE accounts         FORCE ROW LEVEL SECURITY;
ALTER TABLE children         FORCE ROW LEVEL SECURITY;
ALTER TABLE game_progress    FORCE ROW LEVEL SECURITY;
ALTER TABLE practice_sessions FORCE ROW LEVEL SECURITY;
ALTER TABLE character_mastery FORCE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. Fix duration_seconds CHECK constraint (allow 0 and NULL)
-- ============================================================================

ALTER TABLE practice_sessions
    DROP CONSTRAINT IF EXISTS practice_sessions_duration_seconds_check;

ALTER TABLE practice_sessions
    ADD CONSTRAINT practice_sessions_duration_seconds_check
    CHECK (duration_seconds IS NULL OR duration_seconds >= 0);

-- ============================================================================
-- 3. Composite index: sessions by child ordered by date (most common query)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_practice_sessions_child_date
    ON practice_sessions(child_id, session_date DESC);

-- ============================================================================
-- 4. GIN index on badges JSONB (supports @> containment queries)
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_game_progress_badges
    ON game_progress USING gin(badges);

-- ============================================================================
-- 5. Rebuild RLS policies with (SELECT auth.uid()) for per-query evaluation
-- ============================================================================

-- ── ACCOUNTS ─────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can view own account"   ON accounts;
DROP POLICY IF EXISTS "Users can update own account" ON accounts;
DROP POLICY IF EXISTS "Users can insert own account" ON accounts;
DROP POLICY IF EXISTS "Users can delete own account" ON accounts;

CREATE POLICY "Users can view own account"
    ON accounts FOR SELECT
    USING ((SELECT auth.uid()) = id);

CREATE POLICY "Users can update own account"
    ON accounts FOR UPDATE
    USING ((SELECT auth.uid()) = id);

CREATE POLICY "Users can insert own account"
    ON accounts FOR INSERT
    WITH CHECK ((SELECT auth.uid()) = id);

CREATE POLICY "Users can delete own account"
    ON accounts FOR DELETE
    USING ((SELECT auth.uid()) = id);

-- ── CHILDREN ─────────────────────────────────────────────────────────────────
-- Simplified: accounts.id = auth.uid() so no subquery to accounts needed

DROP POLICY IF EXISTS "Parents can view own children"   ON children;
DROP POLICY IF EXISTS "Parents can insert own children" ON children;
DROP POLICY IF EXISTS "Parents can update own children" ON children;
DROP POLICY IF EXISTS "Parents can delete own children" ON children;

CREATE POLICY "Parents can view own children"
    ON children FOR SELECT
    USING (account_id = (SELECT auth.uid()));

CREATE POLICY "Parents can insert own children"
    ON children FOR INSERT
    WITH CHECK (account_id = (SELECT auth.uid()));

CREATE POLICY "Parents can update own children"
    ON children FOR UPDATE
    USING (account_id = (SELECT auth.uid()));

CREATE POLICY "Parents can delete own children"
    ON children FOR DELETE
    USING (account_id = (SELECT auth.uid()));

-- ── GAME_PROGRESS ─────────────────────────────────────────────────────────────
-- Simplified: removed JOIN to accounts, subquery only hits children

DROP POLICY IF EXISTS "Parents can view own children game progress"   ON game_progress;
DROP POLICY IF EXISTS "Parents can insert own children game progress" ON game_progress;
DROP POLICY IF EXISTS "Parents can update own children game progress" ON game_progress;
DROP POLICY IF EXISTS "Parents can delete own children game progress" ON game_progress;

CREATE POLICY "Parents can view own children game progress"
    ON game_progress FOR SELECT
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can insert own children game progress"
    ON game_progress FOR INSERT
    WITH CHECK (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can update own children game progress"
    ON game_progress FOR UPDATE
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can delete own children game progress"
    ON game_progress FOR DELETE
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

-- ── PRACTICE_SESSIONS ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Parents can view own children practice sessions"   ON practice_sessions;
DROP POLICY IF EXISTS "Parents can insert own children practice sessions" ON practice_sessions;
DROP POLICY IF EXISTS "Parents can delete own children practice sessions" ON practice_sessions;

CREATE POLICY "Parents can view own children practice sessions"
    ON practice_sessions FOR SELECT
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can insert own children practice sessions"
    ON practice_sessions FOR INSERT
    WITH CHECK (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can delete own children practice sessions"
    ON practice_sessions FOR DELETE
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

-- ── CHARACTER_MASTERY ─────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Parents can view own children character mastery"   ON character_mastery;
DROP POLICY IF EXISTS "Parents can insert own children character mastery" ON character_mastery;
DROP POLICY IF EXISTS "Parents can update own children character mastery" ON character_mastery;
DROP POLICY IF EXISTS "Parents can delete own children character mastery" ON character_mastery;

CREATE POLICY "Parents can view own children character mastery"
    ON character_mastery FOR SELECT
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can insert own children character mastery"
    ON character_mastery FOR INSERT
    WITH CHECK (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can update own children character mastery"
    ON character_mastery FOR UPDATE
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

CREATE POLICY "Parents can delete own children character mastery"
    ON character_mastery FOR DELETE
    USING (
        child_id IN (SELECT id FROM children WHERE account_id = (SELECT auth.uid()))
    );

-- ============================================================================
-- 6. Fix date arithmetic in trigger (last_date + INTERVAL '1 day' → last_date + 1)
--    Adding an integer to a DATE returns DATE; INTERVAL returns TIMESTAMP.
-- ============================================================================

CREATE OR REPLACE FUNCTION update_game_progress_after_practice()
RETURNS TRIGGER AS $$
DECLARE
    current_streak INTEGER;
    last_date DATE;
    new_level INTEGER;
BEGIN
    -- Get current streak and last practice date
    SELECT streak_days, last_practice_date
    INTO current_streak, last_date
    FROM game_progress
    WHERE child_id = NEW.child_id;

    -- Calculate new streak
    IF last_date IS NULL THEN
        current_streak := 1;
    ELSIF DATE(NEW.session_date) = last_date THEN
        -- Same day, keep streak
        current_streak := current_streak;
    ELSIF DATE(NEW.session_date) = last_date + 1 THEN
        -- Next consecutive day, increment streak
        current_streak := current_streak + 1;
    ELSE
        -- Gap in practice, reset streak
        current_streak := 1;
    END IF;

    -- Insert or update game progress
    INSERT INTO game_progress (
        child_id,
        total_xp,
        current_level,
        total_stars,
        last_practice_date,
        streak_days
    )
    VALUES (
        NEW.child_id,
        NEW.xp_earned,
        1,
        NEW.stars_earned,
        DATE(NEW.session_date),
        current_streak
    )
    ON CONFLICT (child_id)
    DO UPDATE SET
        total_xp            = game_progress.total_xp + NEW.xp_earned,
        total_stars         = game_progress.total_stars + NEW.stars_earned,
        last_practice_date  = DATE(NEW.session_date),
        streak_days         = current_streak,
        updated_at          = NOW();

    -- Calculate new level using same thresholds as the mobile app:
    -- [0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200]
    SELECT CASE
        WHEN total_xp >= 3200 THEN 10
        WHEN total_xp >= 2500 THEN 9
        WHEN total_xp >= 1900 THEN 8
        WHEN total_xp >= 1400 THEN 7
        WHEN total_xp >= 1000 THEN 6
        WHEN total_xp >= 700  THEN 5
        WHEN total_xp >= 450  THEN 4
        WHEN total_xp >= 250  THEN 3
        WHEN total_xp >= 100  THEN 2
        ELSE 1
    END
    INTO new_level
    FROM game_progress
    WHERE child_id = NEW.child_id;

    -- Update level
    UPDATE game_progress
    SET current_level = new_level
    WHERE child_id = NEW.child_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
