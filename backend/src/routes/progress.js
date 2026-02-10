import express from 'express';
import {
    getGameProgress,
    getCharacterMastery,
    getCharacterStats
} from '../controllers/progressController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Progress routes
router.get('/:childId/game-progress', getGameProgress);
router.get('/:childId/character-mastery', getCharacterMastery);
router.get('/:childId/character-stats', getCharacterStats);

export default router;
