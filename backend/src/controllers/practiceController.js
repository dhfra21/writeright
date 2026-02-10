import supabase from '../config/supabase.js';

/**
 * Get practice sessions for a child
 */
export const getPracticeSessions = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;
        const { limit = 20, offset = 0, character_type, character_value } = req.query;

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

        let query = supabase
            .from('practice_sessions')
            .select('*')
            .eq('child_id', childId)
            .order('session_date', { ascending: false })
            .range(offset, offset + limit - 1);

        // Optional filters
        if (character_type) {
            query = query.eq('character_type', character_type);
        }
        if (character_value) {
            query = query.eq('character_value', character_value);
        }

        const { data, error } = await query;

        if (error) throw error;

        res.json({
            success: true,
            data,
            pagination: {
                limit: parseInt(limit),
                offset: parseInt(offset)
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Create new practice session
 */
export const createPracticeSession = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;
        const {
            character_type,
            character_value,
            score,
            xp_earned,
            stars_earned,
            duration_seconds
        } = req.body;

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

        // Validate required fields
        if (!character_type || !character_value || score === undefined) {
            return res.status(400).json({
                success: false,
                error: 'character_type, character_value, and score are required'
            });
        }

        // Validate character_type
        if (!['letter', 'number'].includes(character_type)) {
            return res.status(400).json({
                success: false,
                error: 'character_type must be "letter" or "number"'
            });
        }

        // Validate score range
        if (score < 0 || score > 100) {
            return res.status(400).json({
                success: false,
                error: 'score must be between 0 and 100'
            });
        }

        const { data, error } = await supabase
            .from('practice_sessions')
            .insert({
                child_id: childId,
                character_type,
                character_value,
                score,
                xp_earned: xp_earned || 0,
                stars_earned: stars_earned || 0,
                duration_seconds
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
 * Get practice session statistics
 */
export const getPracticeStats = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const { childId } = req.params;
        const { days = 30 } = req.query;

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

        // Get sessions from last N days
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        const { data, error } = await supabase
            .from('practice_sessions')
            .select('character_type, score, xp_earned, stars_earned, session_date')
            .eq('child_id', childId)
            .gte('session_date', startDate.toISOString());

        if (error) throw error;

        // Calculate statistics
        const stats = {
            total_sessions: data.length,
            total_xp: data.reduce((sum, s) => sum + s.xp_earned, 0),
            total_stars: data.reduce((sum, s) => sum + s.stars_earned, 0),
            average_score: data.length > 0
                ? data.reduce((sum, s) => sum + s.score, 0) / data.length
                : 0,
            by_character_type: {}
        };

        // Group by character type
        data.forEach(session => {
            if (!stats.by_character_type[session.character_type]) {
                stats.by_character_type[session.character_type] = {
                    count: 0,
                    total_score: 0,
                    average_score: 0
                };
            }
            const typeStats = stats.by_character_type[session.character_type];
            typeStats.count++;
            typeStats.total_score += session.score;
            typeStats.average_score = typeStats.total_score / typeStats.count;
        });

        res.json({
            success: true,
            data: stats,
            period_days: parseInt(days)
        });
    } catch (error) {
        next(error);
    }
};
