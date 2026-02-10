-- Migration: Create accounts table
-- Description: Stores parent account information linked to Supabase Auth
-- Created: 2026-02-05

-- Create accounts table
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    parent_first_name TEXT NOT NULL,
    parent_last_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index on email for faster lookups
CREATE INDEX idx_accounts_email ON accounts(email);

-- Add comment to table
COMMENT ON TABLE accounts IS 'Parent account information linked to Supabase Auth users';

-- Add comments to columns
COMMENT ON COLUMN accounts.id IS 'UUID from Supabase Auth, primary key';
COMMENT ON COLUMN accounts.email IS 'Parent email address, must be unique';
COMMENT ON COLUMN accounts.parent_first_name IS 'Parent first name';
COMMENT ON COLUMN accounts.parent_last_name IS 'Parent last name';
COMMENT ON COLUMN accounts.created_at IS 'Account creation timestamp';
COMMENT ON COLUMN accounts.updated_at IS 'Last update timestamp';
