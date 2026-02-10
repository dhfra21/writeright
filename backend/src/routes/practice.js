import express from 'express';
import {
    getPracticeSessions,
    createPracticeSession,
    getPracticeStats
} from '../controllers/practiceController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Practice session routes
router.get('/:childId/sessions', getPracticeSessions);
router.post('/:childId/sessions', createPracticeSession);
router.get('/:childId/stats', getPracticeStats);

export default router;
