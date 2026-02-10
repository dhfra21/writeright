import express from 'express';
import childrenRoutes from './children.js';
import practiceRoutes from './practice.js';
import progressRoutes from './progress.js';

const router = express.Router();

// Health check endpoint
router.get('/health', (req, res) => {
    res.json({
        success: true,
        message: 'API is running',
        timestamp: new Date().toISOString()
    });
});

// API routes
router.use('/children', childrenRoutes);
router.use('/practice', practiceRoutes);
router.use('/progress', progressRoutes);

export default router;
