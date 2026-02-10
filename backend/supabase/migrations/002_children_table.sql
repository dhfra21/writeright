-- Migration: Create children table
-- Description: Stores child profiles associated with parent accounts
-- Created: 2026-02-05

-- Create children table
CREATE TABLE IF NOT EXISTS children (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    child_name TEXT NOT NULL,
    age INTEGER CHECK (age > 0 AND age <= 18),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index on account_id for faster lookups
CREATE INDEX idx_children_account_id ON children(account_id);

-- Add comment to table
COMMENT ON TABLE children IS 'Child profiles associated with parent accounts';

-- Add comments to columns
COMMENT ON COLUMN children.id IS 'Unique child profile ID';
COMMENT ON COLUMN children.account_id IS 'Reference to parent account';
COMMENT ON COLUMN children.child_name IS 'Child display name (not required to be real name)';
COMMENT ON COLUMN children.age IS 'Child age (optional, 1-18)';
COMMENT ON COLUMN children.avatar_url IS 'URL or reference to profile avatar image';
COMMENT ON COLUMN children.created_at IS 'Profile creation timestamp';
COMMENT ON COLUMN children.updated_at IS 'Last update timestamp';
