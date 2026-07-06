require('express-async-errors');
const express = require('express');
const helmet  = require('helmet');
const cors    = require('cors');
const morgan  = require('morgan');
const rateLimit = require('express-rate-limit');

const errorHandler = require('./middleware/errorHandler');

// ── Route imports ─────────────────────────────────────────────────────────────
const authRoutes     = require('./modules/auth/auth.routes');
const userRoutes     = require('./modules/users/user.routes');
const productRoutes  = require('./modules/products/product.routes');
const reelRoutes     = require('./modules/reels/reel.routes');
const cartRoutes     = require('./modules/cart/cart.routes');
const wishlistRoutes = require('./modules/wishlist/wishlist.routes');
const orderRoutes    = require('./modules/orders/order.routes');

const app = express();

// ── Security & utilities ──────────────────────────────────────────────────────
app.use(helmet());
app.use(cors({ origin: process.env.CLIENT_URL, credentials: true }));
app.use(morgan(process.env.NODE_ENV === 'development' ? 'dev' : 'combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Rate limiting — 100 requests per 15 minutes per IP ───────────────────────
app.use('/api', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { success: false, message: 'Too many requests — slow down' },
}));

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({ status: 'ok', env: process.env.NODE_ENV }));

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth',     authRoutes);
app.use('/api/users',    userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/reels',    reelRoutes);
app.use('/api/cart',     cartRoutes);
app.use('/api/wishlist', wishlistRoutes);
app.use('/api/orders',   orderRoutes);

// ── 404 ───────────────────────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` }));

// ── Global error handler ──────────────────────────────────────────────────────
app.use(errorHandler);

module.exports = app;