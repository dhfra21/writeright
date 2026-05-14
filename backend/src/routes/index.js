import express from 'express';
import authRoutes from './auth.js';
import childrenRoutes from './children.js';
import practiceRoutes from './practice.js';
import progressRoutes from './progress.js';
import adminRoutes from './admin.js';
import evaluateRoutes from './evaluate.js';

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
router.use('/auth', authRoutes);
router.use('/children', childrenRoutes);
router.use('/practice', practiceRoutes);
router.use('/progress', progressRoutes);
router.use('/admin', adminRoutes);
router.use('/evaluate', evaluateRoutes);

export default router;
