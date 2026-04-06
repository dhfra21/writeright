import express from 'express';
import {
    getGameProgress,
    updateGameProgress,
    getCharacterMastery,
    getCharacterStats,
    insertPracticeSession
} from '../controllers/progressController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Progress routes
router.get('/:childId', getGameProgress); // GET /progress/:childId
router.put('/:childId', updateGameProgress); // PUT /progress/:childId
router.get('/:childId/game-progress', getGameProgress); // Alternative route
router.get('/:childId/character-mastery', getCharacterMastery);
router.get('/:childId/character-stats', getCharacterStats);
router.post('/:childId/sessions', insertPracticeSession); // POST /progress/:childId/sessions

export default router;
