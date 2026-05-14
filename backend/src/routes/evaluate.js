import express from 'express';
import { evaluate } from '../controllers/evaluateController.js';

const router = express.Router();

// POST /api/v1/evaluate
// Public endpoint — no auth required so the app can call it without a session.
// Rate limiting is handled upstream (Nginx / Groq's own 429).
router.post('/', evaluate);

export default router;
