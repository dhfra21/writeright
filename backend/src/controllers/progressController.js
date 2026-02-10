import supabase from '../config/supabase.js';

/**
 * Get game progress for a child
 */
export const getGameProgress = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Verify child belongs to user
        const { data: child } = await supabase
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

        const { data, error } = await supabase
            .from('game_progress')
            .select('*')
            .eq('child_id', childId)
            .single();

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
 * Get character mastery for a child
 */
export const getCharacterMastery = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Verify child belongs to user
        const { data: child } = await supabase
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

        const { data, error } = await supabase
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
 * Get character mastery statistics
 */
export const getCharacterStats = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;

        // Verify child belongs to user
        const { data: child } = await supabase
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

        const { data, error } = await supabase
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
