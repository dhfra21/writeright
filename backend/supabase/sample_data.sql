-- Sample Data for Testing
-- Description: Insert sample data to test database schema and triggers
-- Usage: Run this AFTER all migrations are complete

-- Note: You must first create a test user through Supabase Auth
-- Then replace 'YOUR_AUTH_UUID_HERE' with the actual UUID from auth.users

-- ============================================================================
-- SAMPLE ACCOUNT
-- ============================================================================

-- Insert sample parent account
-- Replace 'YOUR_AUTH_UUID_HERE' with actual UUID from Supabase Auth
INSERT INTO accounts (id, email, parent_first_name, parent_last_name)
VALUES (
  'YOUR_AUTH_UUID_HERE',
  'parent@example.com',
  'John',
  'Doe'
);

-- ============================================================================
-- SAMPLE CHILDREN
-- ============================================================================

-- Insert sample children
INSERT INTO children (id, account_id, child_name, age, avatar_url)
VALUES 
  (
    gen_random_uuid(),
    'YOUR_AUTH_UUID_HERE',
    'Emma',
    7,
    'avatars/girl_1.png'
  ),
  (
    gen_random_uuid(),
    'YOUR_AUTH_UUID_HERE',
    'Liam',
    5,
    'avatars/boy_1.png'
  );

-- ============================================================================
-- SAMPLE PRACTICE SESSIONS
-- ============================================================================

-- Get Emma's ID for practice sessions
DO $$
DECLARE
  emma_id UUID;
  liam_id UUID;
BEGIN
  -- Get child IDs
  SELECT id INTO emma_id FROM children WHERE child_name = 'Emma' LIMIT 1;
  SELECT id INTO liam_id FROM children WHERE child_name = 'Liam' LIMIT 1;

  -- Emma's practice sessions - Letter A
  INSERT INTO practice_sessions (child_id, character_type, character_value, score, xp_earned, stars_earned, duration_seconds, session_date)
  VALUES 
    (emma_id, 'letter', 'A', 95.5, 15, 3, 120, NOW() - INTERVAL '5 days'),
    (emma_id, 'letter', 'A', 88.0, 12, 2, 110, NOW() - INTERVAL '4 days'),
    (emma_id, 'letter', 'A', 92.0, 14, 3, 115, NOW() - INTERVAL '3 days');

  -- Emma's practice sessions - Letter B
  INSERT INTO practice_sessions (child_id, character_type, character_value, score, xp_earned, stars_earned, duration_seconds, session_date)
  VALUES 
    (emma_id, 'letter', 'B', 78.5, 10, 2, 130, NOW() - INTERVAL '3 days'),
    (emma_id, 'letter', 'B', 82.0, 11, 2, 125, NOW() - INTERVAL '2 days'),
    (emma_id, 'letter', 'B', 85.5, 12, 2, 120, NOW() - INTERVAL '1 day');

  -- Emma's practice sessions - Number 1
  INSERT INTO practice_sessions (child_id, character_type, character_value, score, xp_earned, stars_earned, duration_seconds, session_date)
  VALUES 
    (emma_id, 'number', '1', 90.0, 13, 3, 100, NOW() - INTERVAL '2 days'),
    (emma_id, 'number', '1', 93.5, 14, 3, 95, NOW() - INTERVAL '1 day'),
    (emma_id, 'number', '1', 96.0, 15, 3, 90, NOW());

  -- Liam's practice sessions - Letter A
  INSERT INTO practice_sessions (child_id, character_type, character_value, score, xp_earned, stars_earned, duration_seconds, session_date)
  VALUES 
    (liam_id, 'letter', 'A', 65.0, 8, 1, 150, NOW() - INTERVAL '3 days'),
    (liam_id, 'letter', 'A', 70.5, 9, 2, 145, NOW() - INTERVAL '2 days'),
    (liam_id, 'letter', 'A', 75.0, 10, 2, 140, NOW() - INTERVAL '1 day');

  -- Liam's practice sessions - Number 1
  INSERT INTO practice_sessions (child_id, character_type, character_value, score, xp_earned, stars_earned, duration_seconds, session_date)
  VALUES 
    (liam_id, 'number', '1', 80.0, 11, 2, 120, NOW() - INTERVAL '1 day'),
    (liam_id, 'number', '1', 85.0, 12, 2, 115, NOW());

END $$;

-- ============================================================================
-- VERIFY SAMPLE DATA
-- ============================================================================

-- View all children
SELECT * FROM children;

-- View game progress (should be auto-created and updated)
SELECT 
  c.child_name,
  gp.total_xp,
  gp.current_level,
  gp.total_stars,
  gp.streak_days,
  gp.last_practice_date
FROM game_progress gp
JOIN children c ON gp.child_id = c.id;

-- View character mastery (should be auto-created and updated)
SELECT 
  c.child_name,
  cm.character_type,
  cm.character_value,
  cm.practice_count,
  cm.average_score,
  cm.best_score,
  cm.mastery_level
FROM character_mastery cm
JOIN children c ON cm.child_id = c.id
ORDER BY c.child_name, cm.character_type, cm.character_value;

-- View practice sessions summary
SELECT 
  c.child_name,
  COUNT(*) as total_sessions,
  AVG(ps.score) as avg_score,
  SUM(ps.xp_earned) as total_xp,
  SUM(ps.stars_earned) as total_stars
FROM practice_sessions ps
JOIN children c ON ps.child_id = c.id
GROUP BY c.child_name;

-- ============================================================================
-- EXPECTED RESULTS
-- ============================================================================

-- Emma should have:
-- - Total XP: ~116 (from all sessions)
-- - Current Level: 2 (116 XP / 100 = level 2)
-- - Total Stars: 20
-- - 3 character mastery records (A, B, 1)
-- - Letter A: Master level (avg ~91.8, 3 practices)
-- - Letter B: Intermediate level (avg ~82, 3 practices)
-- - Number 1: Master level (avg ~93.2, 3 practices)

-- Liam should have:
-- - Total XP: ~50
-- - Current Level: 1
-- - Total Stars: 9
-- - 2 character mastery records (A, 1)
-- - Letter A: Intermediate level (avg ~70.2, 3 practices)
-- - Number 1: Intermediate level (avg ~82.5, 2 practices)
