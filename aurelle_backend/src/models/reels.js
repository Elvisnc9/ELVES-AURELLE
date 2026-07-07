import mongoose from 'mongoose';

const reelSchema = new mongoose.Schema(
  {
    // ── Core link ─────────────────────────────────────────────────────────────
    // Each reel is tied to one product
    product: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'Product',
      required: [true, 'Reel must be linked to a product'],
    },

    // ── Media (hosted on Cloudinary) ──────────────────────────────────────────
    videoUrl:       { type: String, required: [true, 'Video URL is required'] },
    videoPublicId:  { type: String, default: null }, // Cloudinary ID — needed to delete
    thumbnailUrl:   { type: String, default: null }, // auto-generated from video

    caption: { type: String, default: '' },

    // ── Social proof — shown on the reel card ─────────────────────────────────
    likes:       { type: Number, default: 0 },
    salesCount:  { type: Number, default: 0 }, // incremented when orders placed
    rating:      { type: Number, default: 0, min: 0, max: 5 },
    reviewCount: { type: Number, default: 0 },

    // ── Track who liked (to prevent double-liking) ────────────────────────────
    likedBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],

    isActive: { type: Boolean, default: true },
  },
  { timestamps: true },
);

// ── Index: newest first + active only ────────────────────────────────────────
// This is the chronological feed query: { isActive: true } sorted by createdAt desc
reelSchema.index({ createdAt: -1, isActive: 1 });

const Reel = mongoose.model('Reel', reelSchema);
export default Reel;