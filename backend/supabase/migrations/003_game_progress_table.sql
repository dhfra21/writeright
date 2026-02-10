-- Migration: Create game_progress table
-- Description: Tracks overall game progress for each child
-- Created: 2026-02-05

-- Create game_progress table
CREATE TABLE IF NOT EXISTS game_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID UNIQUE NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    total_xp INTEGER DEFAULT 0 NOT NULL CHECK (total_xp >= 0),
    current_level INTEGER DEFAULT 1 NOT NULL CHECK (current_level >= 1),
    total_stars INTEGER DEFAULT 0 NOT NULL CHECK (total_stars >= 0),
    badges JSONB DEFAULT '[]'::jsonb NOT NULL,
    last_practice_date DATE,
    streak_days INTEGER DEFAULT 0 NOT NULL CHECK (streak_days >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index on child_id for faster lookups
CREATE INDEX idx_game_progress_child_id ON game_progress(child_id);

-- Create index on last_practice_date for streak calculations
CREATE INDEX idx_game_progress_last_practice_date ON game_progress(last_practice_date);

-- Add comment to table
COMMENT ON TABLE game_progress IS 'Overall game progress tracking for each child';

-- Add comments to columns
COMMENT ON COLUMN game_progress.id IS 'Unique progress record ID';
COMMENT ON COLUMN game_progress.child_id IS 'Reference to child profile (one-to-one relationship)';
COMMENT ON COLUMN game_progress.total_xp IS 'Total experience points earned';
COMMENT ON COLUMN game_progress.current_level IS 'Current level (calculated from XP)';
COMMENT ON COLUMN game_progress.total_stars IS 'Total stars earned across all practice sessions';
COMMENT ON COLUMN game_progress.badges IS 'Array of earned badge objects (e.g., [{"id": "first_star", "earned_at": "2026-02-05"}])';
COMMENT ON COLUMN game_progress.last_practice_date IS 'Date of last practice session';
COMMENT ON COLUMN game_progress.streak_days IS 'Current consecutive days practice streak';
COMMENT ON COLUMN game_progress.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN game_progress.updated_at IS 'Last update timestamp';
