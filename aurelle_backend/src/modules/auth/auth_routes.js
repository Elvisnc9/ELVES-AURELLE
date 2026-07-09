import express from 'express';
import passport from 'passport';
import { getMe, savePreferences, logout } from './auth.controller.js';
import { protect } from '../../middleware/auth.js';

const router = express.Router();

// ── Google ────────────────────────────────────────────────────────────────────

// Step 1: Flutter opens this URL in a web view / browser
// Passport redirects the user to Google's consent screen
router.get('/google',
  passport.authenticate('google', { scope: ['profile', 'email'] }),
);

// Step 2: Google redirects back here after user approves
// Passport runs the GoogleStrategy callback, finds/creates the user,
// creates a session, then we redirect back to Flutter
router.get('/google/callback',
  passport.authenticate('google', {
    failureRedirect: `${process.env.CLIENT_URL}/auth/failed`,
  }),
  (req, res) => {
    // Success — redirect Flutter to a deep link or success screen
    res.redirect(`${process.env.CLIENT_URL}/auth/success`);
  },
);

// ── Facebook ──────────────────────────────────────────────────────────────────

router.get('/facebook',
  passport.authenticate('facebook', { scope: ['email'] }),
);

router.get('/facebook/callback',
  passport.authenticate('facebook', {
    failureRedirect: `${process.env.CLIENT_URL}/auth/failed`,
  }),
  (req, res) => {
    res.redirect(`${process.env.CLIENT_URL}/auth/success`);
  },
);

// ── Session routes (require login) ────────────────────────────────────────────

// Flutter calls this after redirect to get the full user object
router.get('/me', protect, getMe);

// Flutter calls this right after first login to sync onboarding preferences
router.post('/preferences', protect, savePreferences);

// Logout
router.post('/logout', protect, logout);

export default router;