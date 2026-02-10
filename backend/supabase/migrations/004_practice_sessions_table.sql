-- Migration: Create practice_sessions table
-- Description: Records individual practice session data
-- Created: 2026-02-05

-- Create practice_sessions table
CREATE TABLE IF NOT EXISTS practice_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    character_type TEXT NOT NULL CHECK (character_type IN ('letter', 'number')),
    character_value TEXT NOT NULL,
    score DECIMAL(5, 2) NOT NULL CHECK (score >= 0 AND score <= 100),
    xp_earned INTEGER DEFAULT 0 NOT NULL CHECK (xp_earned >= 0),
    stars_earned INTEGER DEFAULT 0 NOT NULL CHECK (stars_earned >= 0 AND stars_earned <= 3),
    duration_seconds INTEGER CHECK (duration_seconds > 0),
    session_date TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for efficient queries
CREATE INDEX idx_practice_sessions_child_id ON practice_sessions(child_id);
CREATE INDEX idx_practice_sessions_session_date ON practice_sessions(session_date DESC);
CREATE INDEX idx_practice_sessions_character ON practice_sessions(child_id, character_type, character_value);

-- Add comment to table
COMMENT ON TABLE practice_sessions IS 'Individual practice session records with scores and rewards';

-- Add comments to columns
COMMENT ON COLUMN practice_sessions.id IS 'Unique session ID';
COMMENT ON COLUMN practice_sessions.child_id IS 'Reference to child who practiced';
COMMENT ON COLUMN practice_sessions.character_type IS 'Type of character: letter or number';
COMMENT ON COLUMN practice_sessions.character_value IS 'The specific character practiced (e.g., A, B, 1, 2)';
COMMENT ON COLUMN practice_sessions.score IS 'ML evaluation score (0-100)';
COMMENT ON COLUMN practice_sessions.xp_earned IS 'Experience points earned in this session';
COMMENT ON COLUMN practice_sessions.stars_earned IS 'Stars earned (0-3 based on score)';
COMMENT ON COLUMN practice_sessions.duration_seconds IS 'Duration of practice session in seconds';
COMMENT ON COLUMN practice_sessions.session_date IS 'Timestamp when session occurred';
COMMENT ON COLUMN practice_sessions.created_at IS 'Record creation timestamp';
