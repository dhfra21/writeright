import supabase from '../config/supabase.js';

/**
 * Get all children for authenticated user
 */
export const getChildren = async (req, res, next) => {
    try {
        const userId = req.user.id;

        const { data, error } = await supabase
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

        const { data, error } = await supabase
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

        const { data, error } = await supabase
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

        const { data, error } = await supabase
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

        const { error } = await supabase
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
