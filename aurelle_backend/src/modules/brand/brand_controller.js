import Brand from '../../models/Brand.js';
import Product from '../../models/Product.js';
import User from '../../models/User.js';

// ── GET /api/brands ───────────────────────────────────────────────────────────
// Public. All brand profiles.
export const getBrands = async (req, res) => {
  const brands = await Brand.find().sort({ name: 1 });
  res.json({ success: true, count: brands.length, brands });
};

// ── GET /api/brands/:slug ─────────────────────────────────────────────────────
// Public. Single brand profile + their products.
export const getBrand = async (req, res) => {
  const brand = await Brand.findOne({ slug: req.params.slug });

  if (!brand) {
    return res.status(404).json({ success: false, message: 'Brand not found' });
  }

  // Fetch this brand's products
  const products = await Product.find({ brand: brand._id, isActive: true })
    .limit(20)
    .sort({ createdAt: -1 });

  res.json({ success: true, brand, products });
};

// ── POST /api/brands/:id/follow ───────────────────────────────────────────────
// Protected. User follows a brand.
export const followBrand = async (req, res) => {
  const brand = await Brand.findById(req.params.id);
  if (!brand) return res.status(404).json({ success: false, message: 'Brand not found' });

  const user = await User.findById(req.user._id);

  const alreadyFollowing = user.followedBrands.some(
    (b) => b.toString() === brand._id.toString(),
  );

  if (alreadyFollowing) {
    return res.status(400).json({ success: false, message: 'Already following this brand' });
  }

  user.followedBrands.push(brand._id);
  await user.save();

  // Increment follower count on brand
  brand.followerCount += 1;
  await brand.save();

  res.json({ success: true, message: `Now following ${brand.name}` });
};

// ── DELETE /api/brands/:id/follow ─────────────────────────────────────────────
// Protected. User unfollows a brand.
export const unfollowBrand = async (req, res) => {
  const brand = await Brand.findById(req.params.id);
  if (!brand) return res.status(404).json({ success: false, message: 'Brand not found' });

  const user = await User.findById(req.user._id);

  user.followedBrands = user.followedBrands.filter(
    (b) => b.toString() !== brand._id.toString(),
  );
  await user.save();

  brand.followerCount = Math.max(0, brand.followerCount - 1);
  await brand.save();

  res.json({ success: true, message: `Unfollowed ${brand.name}` });
};

export default { getBrands, getBrand, followBrand, unfollowBrand };