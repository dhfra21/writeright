-- Migration: Database Functions and Triggers
-- Description: Helper functions and triggers for automated data management
-- Created: 2026-02-05

-- ============================================================================
-- FUNCTION: Update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at column
CREATE TRIGGER update_accounts_updated_at
    BEFORE UPDATE ON accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_children_updated_at
    BEFORE UPDATE ON children
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_game_progress_updated_at
    BEFORE UPDATE ON game_progress
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_character_mastery_updated_at
    BEFORE UPDATE ON character_mastery
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTION: Calculate mastery level based on average score and practice count
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_mastery_level(
    avg_score DECIMAL,
    practice_count INTEGER
)
RETURNS TEXT AS $$
BEGIN
    -- Master: 90+ average score with at least 10 practices
    IF avg_score >= 90 AND practice_count >= 10 THEN
        RETURN 'master';
    -- Advanced: 75+ average score with at least 7 practices
    ELSIF avg_score >= 75 AND practice_count >= 7 THEN
        RETURN 'advanced';
    -- Intermediate: 60+ average score with at least 5 practices
    ELSIF avg_score >= 60 AND practice_count >= 5 THEN
        RETURN 'intermediate';
    -- Beginner: everything else
    ELSE
        RETURN 'beginner';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FUNCTION: Update character mastery after practice session
-- ============================================================================

CREATE OR REPLACE FUNCTION update_character_mastery_after_practice()
RETURNS TRIGGER AS $$
DECLARE
    current_avg DECIMAL;
    current_best DECIMAL;
    current_count INTEGER;
BEGIN
    -- Insert or update character mastery record
    INSERT INTO character_mastery (
        child_id,
        character_type,
        character_value,
        practice_count,
        average_score,
        best_score,
        last_practiced
    )
    VALUES (
        NEW.child_id,
        NEW.character_type,
        NEW.character_value,
        1,
        NEW.score,
        NEW.score,
        NEW.session_date
    )
    ON CONFLICT (child_id, character_type, character_value)
    DO UPDATE SET
        practice_count = character_mastery.practice_count + 1,
        average_score = (
            (character_mastery.average_score * character_mastery.practice_count + NEW.score) /
            (character_mastery.practice_count + 1)
        ),
        best_score = GREATEST(character_mastery.best_score, NEW.score),
        last_practiced = NEW.session_date,
        updated_at = NOW()
    RETURNING average_score, best_score, practice_count
    INTO current_avg, current_best, current_count;

    -- Update mastery level
    UPDATE character_mastery
    SET mastery_level = calculate_mastery_level(current_avg, current_count)
    WHERE child_id = NEW.child_id
        AND character_type = NEW.character_type
        AND character_value = NEW.character_value;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update character mastery after each practice session
CREATE TRIGGER update_mastery_after_practice
    AFTER INSERT ON practice_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_character_mastery_after_practice();

-- ============================================================================
-- FUNCTION: Update game progress after practice session
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
    ELSIF DATE(NEW.session_date) = last_date + INTERVAL '1 day' THEN
        -- Next day, increment streak
        current_streak := current_streak + 1;
    ELSE
        -- Streak broken, reset to 1
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
        total_xp = game_progress.total_xp + NEW.xp_earned,
        total_stars = game_progress.total_stars + NEW.stars_earned,
        last_practice_date = DATE(NEW.session_date),
        streak_days = current_streak,
        updated_at = NOW();

    -- Calculate new level (every 100 XP = 1 level)
    SELECT FLOOR((total_xp / 100.0)) + 1
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

-- Trigger to update game progress after each practice session
CREATE TRIGGER update_progress_after_practice
    AFTER INSERT ON practice_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_game_progress_after_practice();

-- ============================================================================
-- FUNCTION: Initialize game progress when child is created
-- ============================================================================

CREATE OR REPLACE FUNCTION initialize_game_progress()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO game_progress (child_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create game progress record when child is created
CREATE TRIGGER create_game_progress_for_child
    AFTER INSERT ON children
    FOR EACH ROW
    EXECUTE FUNCTION initialize_game_progress();
