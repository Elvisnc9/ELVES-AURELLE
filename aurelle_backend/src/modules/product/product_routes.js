import express from 'express';
import { getProducts, searchProducts, getProduct } from './product.controller.js';

const router = express.Router();

// Specific routes must come before /:id
router.get('/search', searchProducts);
router.get('/',       getProducts);
router.get('/:id',    getProduct);

export default router;