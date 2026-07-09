import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import { Strategy as FacebookStrategy } from 'passport-facebook';
import User from '../models/user.js';

// ── Serialize ─────────────────────────────────────────────────────────────────
// Decides what gets stored in the session after login.
// We only store the user's MongoDB _id — small and enough to look them up.
passport.serializeUser((user, done) => {
  done(null, user._id);
});

// ── Deserialize ───────────────────────────────────────────────────────────────
// On every request, Passport reads the session, gets the _id,
// and fetches the full user from MongoDB. This becomes req.user.
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (err) {
    done(err, null);
  }
});

// ── Google Strategy ───────────────────────────────────────────────────────────
passport.use(
  new GoogleStrategy(
    {
      clientID:     process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL:  process.env.GOOGLE_CALLBACK_URL,
      // Ask Google for the user's profile + email
      scope: ['profile', 'email'],
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        // 1. Check if user already exists with this Google ID
        let user = await User.findOne({ googleId: profile.id });

        if (user) {
          // Already registered via Google — just return them
          return done(null, user);
        }

        // 2. Check if their email already exists (registered via Facebook)
        //    If so, link Google to that existing account
        const email = profile.emails?.[0]?.value;
        if (email) {
          user = await User.findOne({ email });
          if (user) {
            user.googleId = profile.id;
            if (!user.avatar) user.avatar = profile.photos?.[0]?.value || null;
            await user.save();
            return done(null, user);
          }
        }

        // 3. Brand new user — create their account
        user = await User.create({
          googleId: profile.id,
          name:     profile.displayName,
          email:    email || `google_${profile.id}@aurelle.app`,
          avatar:   profile.photos?.[0]?.value || null,
        });

        done(null, user);
      } catch (err) {
        done(err, null);
      }
    },
  ),
);

// ── Facebook Strategy ─────────────────────────────────────────────────────────
passport.use(
  new FacebookStrategy(
    {
      clientID:     process.env.FACEBOOK_APP_ID,
      clientSecret: process.env.FACEBOOK_APP_SECRET,
      callbackURL:  process.env.FACEBOOK_CALLBACK_URL,
      // Ask Facebook for email and profile photo
      profileFields: ['id', 'displayName', 'email', 'photos'],
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        // 1. Check if user already exists with this Facebook ID
        let user = await User.findOne({ facebookId: profile.id });

        if (user) {
          return done(null, user);
        }

        // 2. Check if email already exists (registered via Google)
        const email = profile.emails?.[0]?.value;
        if (email) {
          user = await User.findOne({ email });
          if (user) {
            user.facebookId = profile.id;
            if (!user.avatar) user.avatar = profile.photos?.[0]?.value || null;
            await user.save();
            return done(null, user);
          }
        }

        // 3. Brand new user
        user = await User.create({
          facebookId: profile.id,
          name:       profile.displayName,
          email:      email || `facebook_${profile.id}@aurelle.app`,
          avatar:     profile.photos?.[0]?.value || null,
        });

        done(null, user);
      } catch (err) {
        done(err, null);
      }
    },
  ),
);

export default passport;