import Reel from '../../models/Reel.js';
import Brand from '../../models/Brand.js';

const parseList = (param) =>
  param ? param.split(',').map((s) => s.trim()).filter(Boolean) : [];

// ── GET /api/reels ────────────────────────────────────────────────────────────
// Public. Chronological feed, newest first.
// Preference params filter which products appear in the feed.
//
// Query params:
//   brands   = Jacquemus,Ganni   ← preference filter
//   styles   = minimalist        ← preference filter (matches product tags)
//   page     = 1
//   limit    = 10
export const getReels = async (req, res) => {
  const { page = 1, limit = 10 } = req.query;
  const brandNames = parseList(req.query.brands);
  const styles     = parseList(req.query.styles);

  const skip = (Number(page) - 1) * Number(limit);

  // ── Build product filter for the populate + match ──────────────────────────
  // We filter on the populated product's fields using aggregation
  // For simplicity with populate: fetch reels then filter in JS
  // (for production scale you'd use $lookup aggregation — fine for portfolio)

  let reels = await Reel.find({ isActive: true })
    .sort({ createdAt: -1 })
    .populate({
      path:   'product',
      select: 'name brand price originalPrice category tags variants sizes',
      populate: { path: 'brand', select: 'name slug logo' },
    });

  // ── Apply preference filters ───────────────────────────────────────────────
  if (styles.length > 0) {
    reels = reels.filter((reel) => {
      const tags = reel.product?.tags || [];
      return styles.some((style) => tags.includes(style));
    });
  }

  if (brandNames.length > 0) {
    const normalised = brandNames.map((b) => b.toLowerCase());
    reels = reels.filter((reel) => {
      const brandName = reel.product?.brand?.name?.toLowerCase() || '';
      return normalised.includes(brandName);
    });
  }

  // ── Paginate after filter ──────────────────────────────────────────────────
  const total       = reels.length;
  const paginated   = reels.slice(skip, skip + Number(limit));

  // ── Flag isLiked if user is logged in ─────────────────────────────────────
  const userId = req.user?._id;
  const result = paginated.map((reel) => ({
    ...reel.toJSON(),
    isLiked: userId
      ? reel.likedBy.some((id) => id.toString() === userId.toString())
      : false,
  }));

  res.json({
    success: true,
    total,
    page:    Number(page),
    pages:   Math.ceil(total / Number(limit)),
    reels:   result,
  });
};

// ── GET /api/reels/:id ────────────────────────────────────────────────────────
// Public. Single reel with full product detail.
export const getReel = async (req, res) => {
  const reel = await Reel.findById(req.params.id).populate({
    path:   'product',
    populate: { path: 'brand', select: 'name slug logo' },
  });

  if (!reel || !reel.isActive) {
    return res.status(404).json({ success: false, message: 'Reel not found' });
  }

  const userId  = req.user?._id;
  const isLiked = userId
    ? reel.likedBy.some((id) => id.toString() === userId.toString())
    : false;

  res.json({ success: true, reel: { ...reel.toJSON(), isLiked } });
};

// ── POST /api/reels/:id/like ──────────────────────────────────────────────────
// Protected — must be logged in to like.
export const likeReel = async (req, res) => {
  const reel = await Reel.findById(req.params.id);
  if (!reel) return res.status(404).json({ success: false, message: 'Reel not found' });

  const alreadyLiked = reel.likedBy.some(
    (id) => id.toString() === req.user._id.toString(),
  );

  if (alreadyLiked) {
    return res.status(400).json({ success: false, message: 'Already liked' });
  }

  reel.likedBy.push(req.user._id);
  reel.likes += 1;
  await reel.save();

  res.json({ success: true, likes: reel.likes });
};

// ── DELETE /api/reels/:id/like ────────────────────────────────────────────────
// Protected.
export const unlikeReel = async (req, res) => {
  const reel = await Reel.findById(req.params.id);
  if (!reel) return res.status(404).json({ success: false, message: 'Reel not found' });

  reel.likedBy = reel.likedBy.filter(
    (id) => id.toString() !== req.user._id.toString(),
  );
  reel.likes = Math.max(0, reel.likes - 1);
  await reel.save();

  res.json({ success: true, likes: reel.likes });
};

export default { getReels, getReel, likeReel, unlikeReel };