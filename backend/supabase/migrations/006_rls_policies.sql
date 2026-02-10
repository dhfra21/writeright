-- Migration: Row Level Security (RLS) Policies
-- Description: Implements security policies to ensure data isolation between accounts
-- Created: 2026-02-05

-- Enable Row Level Security on all tables
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE children ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE practice_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE character_mastery ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- ACCOUNTS TABLE POLICIES
-- ============================================================================

-- Policy: Users can view their own account
CREATE POLICY "Users can view own account"
    ON accounts
    FOR SELECT
    USING (auth.uid() = id);

-- Policy: Users can update their own account
CREATE POLICY "Users can update own account"
    ON accounts
    FOR UPDATE
    USING (auth.uid() = id);

-- Policy: Users can insert their own account (during signup)
CREATE POLICY "Users can insert own account"
    ON accounts
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Policy: Users can delete their own account
CREATE POLICY "Users can delete own account"
    ON accounts
    FOR DELETE
    USING (auth.uid() = id);

-- ============================================================================
-- CHILDREN TABLE POLICIES
-- ============================================================================

-- Policy: Parents can view their own children
CREATE POLICY "Parents can view own children"
    ON children
    FOR SELECT
    USING (
        account_id IN (
            SELECT id FROM accounts WHERE auth.uid() = id
        )
    );

-- Policy: Parents can insert children to their account
CREATE POLICY "Parents can insert own children"
    ON children
    FOR INSERT
    WITH CHECK (
        account_id IN (
            SELECT id FROM accounts WHERE auth.uid() = id
        )
    );

-- Policy: Parents can update their own children
CREATE POLICY "Parents can update own children"
    ON children
    FOR UPDATE
    USING (
        account_id IN (
            SELECT id FROM accounts WHERE auth.uid() = id
        )
    );

-- Policy: Parents can delete their own children
CREATE POLICY "Parents can delete own children"
    ON children
    FOR DELETE
    USING (
        account_id IN (
            SELECT id FROM accounts WHERE auth.uid() = id
        )
    );

-- ============================================================================
-- GAME_PROGRESS TABLE POLICIES
-- ============================================================================

-- Policy: Parents can view their children's game progress
CREATE POLICY "Parents can view own children game progress"
    ON game_progress
    FOR SELECT
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can insert game progress for their children
CREATE POLICY "Parents can insert own children game progress"
    ON game_progress
    FOR INSERT
    WITH CHECK (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can update their children's game progress
CREATE POLICY "Parents can update own children game progress"
    ON game_progress
    FOR UPDATE
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can delete their children's game progress
CREATE POLICY "Parents can delete own children game progress"
    ON game_progress
    FOR DELETE
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- ============================================================================
-- PRACTICE_SESSIONS TABLE POLICIES
-- ============================================================================

-- Policy: Parents can view their children's practice sessions
CREATE POLICY "Parents can view own children practice sessions"
    ON practice_sessions
    FOR SELECT
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can insert practice sessions for their children
CREATE POLICY "Parents can insert own children practice sessions"
    ON practice_sessions
    FOR INSERT
    WITH CHECK (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can delete their children's practice sessions
CREATE POLICY "Parents can delete own children practice sessions"
    ON practice_sessions
    FOR DELETE
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- ============================================================================
-- CHARACTER_MASTERY TABLE POLICIES
-- ============================================================================

-- Policy: Parents can view their children's character mastery
CREATE POLICY "Parents can view own children character mastery"
    ON character_mastery
    FOR SELECT
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can insert character mastery for their children
CREATE POLICY "Parents can insert own children character mastery"
    ON character_mastery
    FOR INSERT
    WITH CHECK (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can update their children's character mastery
CREATE POLICY "Parents can update own children character mastery"
    ON character_mastery
    FOR UPDATE
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );

-- Policy: Parents can delete their children's character mastery
CREATE POLICY "Parents can delete own children character mastery"
    ON character_mastery
    FOR DELETE
    USING (
        child_id IN (
            SELECT c.id FROM children c
            JOIN accounts a ON c.account_id = a.id
            WHERE a.id = auth.uid()
        )
    );
