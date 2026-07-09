import User from '../../models/user.js';

// ── GET /api/auth/me ──────────────────────────────────────────────────────────
// Returns the currently logged-in user.
// Passport's deserializeUser already fetched them — they're on req.user.
export const getMe = (req, res) => {
  res.json({
    success: true,
    user: req.user,
  });
};

// ── POST /api/auth/preferences ────────────────────────────────────────────────
// Called by Flutter right after the user logs in for the first time.
// Flutter sends the preferences that were saved locally during onboarding.
// We merge them into the user's MongoDB profile.
export const savePreferences = async (req, res) => {
  const { styles = [], brands = [], discovery = [] } = req.body;

  const user = await User.findByIdAndUpdate(
    req.user._id,
    {
      preferences: { styles, brands, discovery },
      onboardingComplete: true,
    },
    { new: true },
  );

  res.json({
    success: true,
    message: 'Preferences saved',
    user,
  });
};

// ── POST /api/auth/logout ─────────────────────────────────────────────────────
// Destroys the session on the server.
// Passport's req.logout() clears req.user.
export const logout = (req, res, next) => {
  req.logout((err) => {
    if (err) return next(err);
    req.session.destroy(() => {
      res.json({ success: true, message: 'Logged out' });
    });
  });
};