// ── protect ───────────────────────────────────────────────────────────────────
// Middleware for routes that require the user to be logged in.
// Passport attaches req.user after deserializeUser runs.
// If req.isAuthenticated() is false, the session either doesn't exist
// or has expired — we return 401.

export const protect = (req, res, next) => {
  if (req.isAuthenticated()) return next();

  res.status(401).json({
    success: false,
    message: 'Not authorised — please log in',
  });
};