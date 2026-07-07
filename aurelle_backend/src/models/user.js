import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    name: {
      type:     String,
      required: [true, 'Name is required'],
      trim:     true,
    },
    email: {
      type:      String,
      required:  [true, 'Email is required'],
      unique:    true,
      lowercase: true,
      trim:      true,
    },

    // ── OAuth IDs ─────────────────────────────────────────────────────────────
    googleId:   { type: String, default: null },
    facebookId: { type: String, default: null },

    avatar: { type: String, default: null },

    // ── Onboarding preferences ────────────────────────────────────────────────
    // Sent from Flutter SharedPreferences when user first authenticates
    preferences: {
      styles:    { type: [String], default: [] },
      brands:    { type: [String], default: [] },
      discovery: { type: [String], default: [] },
    },

    followedBrands: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Brand' }],

    onboardingComplete: { type: Boolean, default: false },
  },
  { timestamps: true },
);


const user = mongoose.model('User', userSchema);
export default user;