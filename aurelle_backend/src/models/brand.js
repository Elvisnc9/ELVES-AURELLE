import  mongoose from 'mongoose';

// ── Brand model ───────────────────────────────────────────────────────────────
// Mock data only — no admin panel creates these.
// We seed them directly into MongoDB via a seed script in a later milestone.

const brandSchema = new mongoose.Schema(
  {
    name: {
      type:     String,
      required: [true, 'Brand name is required'],
      unique:   true,
      trim:     true,
    },
    slug: {
      // URL-friendly version of name: 'Marine Serre' → 'marine-serre'
      // Used for routes like GET /api/brands/marine-serre
      type:     String,
      required: true,
      unique:   true,
      lowercase: true,
    },
    logo:        { type: String, default: null }, // Cloudinary URL
    coverImage:  { type: String, default: null }, // Cloudinary URL
    description: { type: String, default: '' },
    origin:      { type: String, default: '' },   // e.g. 'Paris, France'

    followerCount: { type: Number, default: 0 },
  },
  { timestamps: true },
);

const Brand = mongoose.model('Brand', brandSchema);
export default Brand;