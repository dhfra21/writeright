import supabase, { supabaseAdmin } from '../config/supabase.js';

/**
 * Get all children for authenticated user
 */
export const getChildren = async (req, res, next) => {
    try {
        const userId = req.user.id;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        const { data, error } = await client
            .from('children')
            .select('*')
            .eq('account_id', userId)
            .order('created_at', { ascending: false });

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
 * Get single child by ID
 */
export const getChildById = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        const { data, error } = await client
            .from('children')
            .select('*')
            .eq('id', childId)
            .eq('account_id', userId)
            .single();

        if (error) throw error;

        if (!data) {
            return res.status(404).json({
                success: false,
                error: 'Child not found'
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
 * Create new child profile
 */
export const createChild = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { child_name, age, avatar_url } = req.body;

        if (!child_name) {
            return res.status(400).json({
                success: false,
                error: 'child_name is required'
            });
        }

        // Use admin client to bypass RLS (user is already authenticated by middleware)
        const client = supabaseAdmin || supabase;

        const { data, error } = await client
            .from('children')
            .insert({
                account_id: userId,
                child_name,
                age,
                avatar_url
            })
            .select()
            .single();

        if (error) throw error;

        // Manually create game_progress record for the new child
        // (in case the database trigger doesn't exist)
        const { error: progressError } = await client
            .from('game_progress')
            .insert({
                child_id: data.id,
                total_xp: 0,
                current_level: 1,
                total_stars: 0,
                streak_days: 0
            });

        if (progressError) {
            console.error('Failed to create game progress:', progressError);
            // Don't fail the request, progress might already exist
        }

        res.status(201).json({
            success: true,
            data
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update child profile
 */
export const updateChild = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;
        const { child_name, age, avatar_url } = req.body;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        const { data, error } = await client
            .from('children')
            .update({
                child_name,
                age,
                avatar_url
            })
            .eq('id', childId)
            .eq('account_id', userId)
            .select()
            .single();

        if (error) throw error;

        if (!data) {
            return res.status(404).json({
                success: false,
                error: 'Child not found'
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
 * Delete child profile
 */
export const deleteChild = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Use admin client to bypass RLS
        const client = supabaseAdmin || supabase;

        const { error } = await client
            .from('children')
            .delete()
            .eq('id', childId)
            .eq('account_id', userId);

        if (error) throw error;

        res.json({
            success: true,
            message: 'Child deleted successfully'
        });
    } catch (error) {
        next(error);
    }
};
