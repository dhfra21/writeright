-- Migration: Create character_mastery table
-- Description: Tracks mastery level for each character per child
-- Created: 2026-02-05

-- Create character_mastery table
CREATE TABLE IF NOT EXISTS character_mastery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
    character_type TEXT NOT NULL CHECK (character_type IN ('letter', 'number')),
    character_value TEXT NOT NULL,
    practice_count INTEGER DEFAULT 0 NOT NULL CHECK (practice_count >= 0),
    average_score DECIMAL(5, 2) DEFAULT 0 NOT NULL CHECK (average_score >= 0 AND average_score <= 100),
    best_score DECIMAL(5, 2) DEFAULT 0 NOT NULL CHECK (best_score >= 0 AND best_score <= 100),
    mastery_level TEXT DEFAULT 'beginner' NOT NULL CHECK (mastery_level IN ('beginner', 'intermediate', 'advanced', 'master')),
    last_practiced TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    UNIQUE(child_id, character_type, character_value)
);

-- Create indexes for efficient queries
CREATE INDEX idx_character_mastery_child_id ON character_mastery(child_id);
CREATE INDEX idx_character_mastery_character ON character_mastery(character_type, character_value);
CREATE INDEX idx_character_mastery_level ON character_mastery(child_id, mastery_level);

-- Add comment to table
COMMENT ON TABLE character_mastery IS 'Tracks mastery progress for each character per child';

-- Add comments to columns
COMMENT ON COLUMN character_mastery.id IS 'Unique mastery record ID';
COMMENT ON COLUMN character_mastery.child_id IS 'Reference to child profile';
COMMENT ON COLUMN character_mastery.character_type IS 'Type of character: letter or number';
COMMENT ON COLUMN character_mastery.character_value IS 'The specific character (e.g., A, B, 1, 2)';
COMMENT ON COLUMN character_mastery.practice_count IS 'Total number of practice attempts';
COMMENT ON COLUMN character_mastery.average_score IS 'Average score across all attempts';
COMMENT ON COLUMN character_mastery.best_score IS 'Best score achieved';
COMMENT ON COLUMN character_mastery.mastery_level IS 'Current mastery level: beginner, intermediate, advanced, or master';
COMMENT ON COLUMN character_mastery.last_practiced IS 'Timestamp of last practice session';
COMMENT ON COLUMN character_mastery.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN character_mastery.updated_at IS 'Last update timestamp';
