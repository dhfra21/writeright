# Supabase Setup Guide

This guide walks you through setting up Supabase for the Children's Handwriting Learning App.

## Prerequisites

- Supabase account (free tier is sufficient for development)
- Git installed
- PostgreSQL client (optional, for local testing)

## Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign in or create an account
3. Click **"New Project"**
4. Fill in project details:
   - **Name**: `handwriting-learning-app` (or your preferred name)
   - **Database Password**: Generate a strong password (save this!)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free (for development)
5. Click **"Create new project"**
6. Wait for project initialization (~2 minutes)

## Step 2: Get Project Credentials

Once your project is ready:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key (for client-side access)
   - **service_role** key (for server-side access, keep secret!)

3. Go to **Settings** → **Database**
4. Copy the **Connection string** (for direct database access)

## Step 3: Run Database Migrations

### Option A: Using Supabase SQL Editor (Recommended for Beginners)

1. In your Supabase dashboard, go to **SQL Editor**
2. Click **"New query"**
3. Copy and paste the contents of each migration file in order:

   **Run these in order:**
   1. [001_accounts_table.sql](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/backend/supabase/migrations/001_accounts_table.sql)
   2. [002_children_table.sql](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/backend/supabase/migrations/002_children_table.sql)
   3. [003_game_progress_table.sql](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/backend/supabase/migrations/003_game_progress_table.sql)
   4. [004_practice_sessions_table.sql](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/backend/supabase/migrations/004_practice_sessions_table.sql)
   5. [005_character_mastery_table.sql](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/backend/supabase/migrations/005_character_mastery_table.sql)
   6. [006_rls_policies.sql](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/backend/supabase/migrations/006_rls_policies.sql)
   7. [007_functions_and_triggers.sql](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/backend/supabase/migrations/007_functions_and_triggers.sql)

4. Click **"Run"** for each migration
5. Verify no errors appear in the output

### Option B: Using Supabase CLI (Recommended for Production)

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   cd "c:/Users/dhiaf/OneDrive/Desktop/ISS PROJECT"
   supabase link --project-ref <your-project-ref>
   ```

4. Run migrations:
   ```bash
   supabase db push
   ```

## Step 4: Configure Authentication

1. In Supabase dashboard, go to **Authentication** → **Providers**
2. Enable **Email** provider (should be enabled by default)
3. Configure email settings:
   - **Enable email confirmations**: ON (recommended)
   - **Secure email change**: ON
   - **Enable email OTP**: Optional

4. (Optional) Customize email templates:
   - Go to **Authentication** → **Email Templates**
   - Customize confirmation, reset password, and magic link emails

## Step 5: Verify Database Setup

1. Go to **Table Editor** in Supabase dashboard
2. Verify all tables are created:
   - ✅ accounts
   - ✅ children
   - ✅ game_progress
   - ✅ practice_sessions
   - ✅ character_mastery

3. Check RLS policies:
   - Each table should have a green shield icon (RLS enabled)
   - Click on a table → **Policies** to view RLS rules

4. Go to **Database** → **Functions**
   - Verify functions are created:
     - ✅ update_updated_at_column
     - ✅ calculate_mastery_level
     - ✅ update_character_mastery_after_practice
     - ✅ update_game_progress_after_practice
     - ✅ initialize_game_progress

## Step 6: Configure Environment Variables

Create environment configuration for your Flutter app:

### For Flutter (Development)

Create `mobile_app/.env`:
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### For Flutter (Production)

Use Flutter's build-time environment variables:
```bash
flutter build apk --dart-define=SUPABASE_URL=https://xxxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Step 7: Install Supabase Flutter Package

1. Add Supabase to `mobile_app/pubspec.yaml`:
   ```yaml
   dependencies:
     supabase_flutter: ^2.0.0
   ```

2. Run:
   ```bash
   cd mobile_app
   flutter pub get
   ```

3. Initialize Supabase in your Flutter app (`lib/main.dart`):
   ```dart
   import 'package:supabase_flutter/supabase_flutter.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Supabase.initialize(
       url: 'YOUR_SUPABASE_URL',
       anonKey: 'YOUR_SUPABASE_ANON_KEY',
     );

     runApp(MyApp());
   }

   // Access Supabase client anywhere in your app
   final supabase = Supabase.instance.client;
   ```

## Step 8: Test Database Connection

### Test 1: Create Test Account

Run this in Supabase SQL Editor:

```sql
-- This will be done through Supabase Auth in production
-- For testing, create a test user first through Auth UI or API

-- Then insert account data
INSERT INTO accounts (id, email, parent_first_name, parent_last_name)
VALUES (
  'test-uuid-from-auth',  -- Replace with actual auth.users UUID
  'test@example.com',
  'Test',
  'Parent'
);
```

### Test 2: Create Test Child

```sql
INSERT INTO children (account_id, child_name, age)
VALUES (
  'test-uuid-from-auth',  -- Same as above
  'Test Child',
  7
);
```

### Test 3: Verify Game Progress Auto-Creation

```sql
-- This should automatically exist due to trigger
SELECT * FROM game_progress
WHERE child_id = (
  SELECT id FROM children WHERE child_name = 'Test Child'
);
```

### Test 4: Create Practice Session

```sql
INSERT INTO practice_sessions (
  child_id,
  character_type,
  character_value,
  score,
  xp_earned,
  stars_earned,
  duration_seconds
)
VALUES (
  (SELECT id FROM children WHERE child_name = 'Test Child'),
  'letter',
  'A',
  85.5,
  10,
  2,
  120
);
```

### Test 5: Verify Automatic Updates

```sql
-- Check game_progress was updated
SELECT total_xp, current_level, total_stars
FROM game_progress
WHERE child_id = (SELECT id FROM children WHERE child_name = 'Test Child');

-- Check character_mastery was created
SELECT * FROM character_mastery
WHERE child_id = (SELECT id FROM children WHERE child_name = 'Test Child')
  AND character_value = 'A';
```

## Step 9: Test RLS Policies

1. Create two test accounts through Supabase Auth
2. Try to query another user's data
3. Verify access is denied

Example test in Flutter:
```dart
// Should only return current user's children
final children = await supabase
    .from('children')
    .select()
    .execute();

print('My children: ${children.data}');
```

## Troubleshooting

### Error: "permission denied for table X"

**Solution**: RLS is enabled but you're not authenticated. Make sure to:
1. Sign in through Supabase Auth
2. Use the authenticated client for queries

### Error: "relation X does not exist"

**Solution**: Migration didn't run successfully. Re-run the migration file.

### Error: "insert or update on table violates foreign key constraint"

**Solution**: You're trying to insert a child_id or account_id that doesn't exist. Create the parent record first.

### Trigger not firing

**Solution**: 
1. Verify trigger exists: `SELECT * FROM pg_trigger WHERE tgname LIKE '%practice%';`
2. Check function exists: `SELECT * FROM pg_proc WHERE proname LIKE '%practice%';`
3. Re-run migration 007

## Security Best Practices

### ✅ DO:
- Use `anon` key for client-side Flutter app
- Keep `service_role` key secret (never in client code)
- Enable RLS on all tables
- Use Supabase Auth for authentication
- Validate data on client and server side

### ❌ DON'T:
- Commit API keys to version control
- Disable RLS in production
- Use `service_role` key in client code
- Store sensitive data unencrypted
- Allow public access to tables

## Next Steps

1. ✅ Database schema created
2. ✅ RLS policies configured
3. ✅ Triggers and functions working
4. 🔲 Integrate with Flutter app
5. 🔲 Implement authentication flow
6. 🔲 Create data access layer
7. 🔲 Test with real users

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Database Schema Reference](file:///c:/Users/dhiaf/OneDrive/Desktop/ISS%20PROJECT/docs/database/DATABASE_SCHEMA.md)

## Support

For issues or questions:
1. Check [Supabase Discord](https://discord.supabase.com)
2. Review [Supabase GitHub Issues](https://github.com/supabase/supabase/issues)
3. Consult project documentation
