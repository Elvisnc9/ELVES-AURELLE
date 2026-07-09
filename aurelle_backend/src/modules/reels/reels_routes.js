import express from 'express';
import { getReels, getReel, likeReel, unlikeReel } from './reel.controller.js';
import { protect } from '../../middleware/auth.js';

const router = express.Router();

// Public
router.get('/',    getReels);
router.get('/:id', getReel);

// Protected — must be logged in
router.post('/:id/like',   protect, likeReel);
router.delete('/:id/like', protect, unlikeReel);

export default router;