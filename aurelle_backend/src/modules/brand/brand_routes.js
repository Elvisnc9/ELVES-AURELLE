import express from 'express';
import { getBrands, getBrand, followBrand, unfollowBrand } from './brand.controller.js';
import { protect } from '../../middleware/auth.js';

const router = express.Router();

// Public
router.get('/',       getBrands);
router.get('/:slug',  getBrand);

// Protected
router.post('/:id/follow',   protect, followBrand);
router.delete('/:id/follow', protect, unfollowBrand);

export default router;