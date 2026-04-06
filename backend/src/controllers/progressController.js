import supabase, { supabaseAdmin } from '../config/supabase.js';

/**
 * Insert a practice session — triggers auto-update game_progress + character_mastery
 */
export const insertPracticeSession = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;
        const { character_type, character_value, score, xp_earned, stars_earned, duration_seconds } = req.body;

        const client = supabaseAdmin || supabase;

        const { data: child } = await client
            .from('children')
            .select('id')
            .eq('id', childId)
            .eq('account_id', userId)
            .single();

        if (!child) {
            return res.status(404).json({ success: false, error: 'Child not found' });
        }

        const { data, error } = await client
            .from('practice_sessions')
            .insert({
                child_id: childId,
                character_type,
                character_value,
                score,
                xp_earned,
                stars_earned,
                duration_seconds: duration_seconds ?? null,
                session_date: new Date().toISOString(),
            })
            .select()
            .single();

        if (error) throw error;

        res.status(201).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

/**
 * Get game progress for a child
 */
export const getGameProgress = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        // Verify child belongs to user
        const { data: child, error: childError } = await client
            .from('children')
            .select('id')
            .eq('id', childId)
            .eq('account_id', userId)
            .single();

        if (childError) {
            console.error('Error fetching child:', childError);
        }

        if (!child) {
            console.log(`Child not found: childId=${childId}, userId=${userId}`);
            return res.status(404).json({
                success: false,
                error: 'Child not found'
            });
        }

        const { data, error } = await client
            .from('game_progress')
            .select('*')
            .eq('child_id', childId)
            .single();

        if (error) {
            console.error('Error fetching game progress:', error);
            throw error;
        }

        if (!data) {
            console.log(`No game progress found for child: ${childId}`);
            return res.status(404).json({
                success: false,
                error: 'Game progress not found'
            });
        }

        res.json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get character mastery for a child
 */
export const getCharacterMastery = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        // Verify child belongs to user
        const { data: child } = await client
            .from('children')
            .select('id')
            .eq('id', childId)
            .eq('account_id', userId)
            .single();

        if (!child) {
            return res.status(404).json({
                success: false,
                error: 'Child not found'
            });
        }

        const { data, error } = await client
            .from('character_mastery')
            .select('*')
            .eq('child_id', childId)
            .order('mastery_level', { ascending: false })
            .order('average_score', { ascending: false });

        if (error) throw error;

        res.json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update game progress for a child
 */
export const updateGameProgress = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;
        const { total_xp, current_level, total_stars, streak_days, badges } = req.body;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        // Verify child belongs to user
        const { data: child } = await client
            .from('children')
            .select('id')
            .eq('id', childId)
            .eq('account_id', userId)
            .single();

        if (!child) {
            return res.status(404).json({
                success: false,
                error: 'Child not found'
            });
        }

        // Update game progress
        const updatePayload = {
            total_xp,
            current_level,
            total_stars,
            streak_days,
            updated_at: new Date().toISOString(),
            ...(badges !== undefined && { badges }),
        };

        const { data, error } = await client
            .from('game_progress')
            .update(updatePayload)
            .eq('child_id', childId)
            .select()
            .single();

        if (error) {
            console.error('Error updating game progress:', error);
            throw error;
        }

        res.json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get character mastery statistics
 */
export const getCharacterStats = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        // Verify child belongs to user
        const { data: child } = await client
            .from('children')
            .select('id')
            .eq('id', childId)
            .eq('account_id', userId)
            .single();

        if (!child) {
            return res.status(404).json({
                success: false,
                error: 'Child not found'
            });
        }

        const { data, error } = await client
            .from('character_mastery')
            .select('character_type, mastery_level')
            .eq('child_id', childId);

        if (error) throw error;

        // Calculate statistics
        const stats = {
            total_characters: data.length,
            by_type: {},
            by_mastery: {
                beginner: 0,
                intermediate: 0,
                advanced: 0,
                master: 0
            }
        };

        data.forEach(item => {
            // Count by type
            if (!stats.by_type[item.character_type]) {
                stats.by_type[item.character_type] = 0;
            }
            stats.by_type[item.character_type]++;

            // Count by mastery level
            stats.by_mastery[item.mastery_level]++;
        });

        res.json({
            success: true,
            data: stats
        });
    } catch (error) {
        next(error);
    }
};
