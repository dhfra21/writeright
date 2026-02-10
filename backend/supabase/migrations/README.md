# Supabase Database Migrations

This directory contains SQL migration files for the Handwriting Learning App database schema.

## Migration Files

Run these migrations in order:

1. **001_accounts_table.sql** - Creates parent accounts table
2. **002_children_table.sql** - Creates children profiles table
3. **003_game_progress_table.sql** - Creates game progress tracking table
4. **004_practice_sessions_table.sql** - Creates practice sessions table
5. **005_character_mastery_table.sql** - Creates character mastery table
6. **006_rls_policies.sql** - Implements Row Level Security policies
7. **007_functions_and_triggers.sql** - Creates database functions and triggers

## How to Run

### Option 1: Supabase SQL Editor (Recommended for Beginners)

1. Open your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste each migration file content
4. Run them in order (001 → 007)

### Option 2: Supabase CLI (Recommended for Production)

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref <your-project-ref>

# Push migrations
supabase db push
```

## What Gets Created

### Tables
- `accounts` - Parent account information
- `children` - Child profiles
- `game_progress` - Overall game progress per child
- `practice_sessions` - Individual practice session records
- `character_mastery` - Character-specific mastery tracking

### Security
- Row Level Security (RLS) enabled on all tables
- Policies ensure parents can only access their own data
- Cascading deletes maintain data integrity

### Automation
- Triggers automatically update `updated_at` timestamps
- Practice sessions automatically update game progress
- Practice sessions automatically update character mastery
- New children automatically get game progress records

## Testing

After running migrations, test with sample data:

```sql
-- See sample_data.sql for test data
```

## Documentation

- [DATABASE_SCHEMA.md](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/docs/database/DATABASE_SCHEMA.md) - Complete schema documentation
- [SUPABASE_SETUP.md](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/docs/database/SUPABASE_SETUP.md) - Setup instructions

## Rollback

To rollback migrations, drop tables in reverse order:

```sql
DROP TABLE IF EXISTS character_mastery CASCADE;
DROP TABLE IF EXISTS practice_sessions CASCADE;
DROP TABLE IF EXISTS game_progress CASCADE;
DROP TABLE IF EXISTS children CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
```

## Support

For issues, see the troubleshooting section in [SUPABASE_SETUP.md](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/docs/database/SUPABASE_SETUP.md).
