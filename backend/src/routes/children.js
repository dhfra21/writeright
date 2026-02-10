import express from 'express';
import {
    getChildren,
    getChildById,
    createChild,
    updateChild,
    deleteChild
} from '../controllers/childrenController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Children routes
router.get('/', getChildren);
router.get('/:childId', getChildById);
router.post('/', createChild);
router.put('/:childId', updateChild);
router.delete('/:childId', deleteChild);

export default router;
