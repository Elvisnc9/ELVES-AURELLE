import Product from '../../models/Product.js';
import Brand from '../../models/Brand.js';

// ── Helper: parse comma-separated query param ─────────────────────────────────
// '?brands=Jacquemus,Ganni' → ['Jacquemus', 'Ganni']
// '?brands=' or missing    → []
const parseList = (param) =>
  param ? param.split(',').map((s) => s.trim()).filter(Boolean) : [];

// ── GET /api/products ─────────────────────────────────────────────────────────
// Public. Supports filtering, sorting, pagination + preference params.
//
// Query params:
//   category   = womenswear | menswear | everythingElse
//   saleOnly   = true
//   brands     = Jacquemus,Ganni          ← from onboarding preferences
//   styles     = minimalist,streetwear    ← from onboarding preferences (matched via tags)
//   sort       = price_asc | price_desc | newest
//   page       = 1
//   limit      = 20
export const getProducts = async (req, res) => {
  const {
    category,
    saleOnly,
    sort,
    page  = 1,
    limit = 20,
  } = req.query;

  const brandNames = parseList(req.query.brands);
  const styles     = parseList(req.query.styles);

  // ── Build filter ────────────────────────────────────────────────────────────
  const filter = { isActive: true };

  if (category) filter.category = category;
  if (saleOnly === 'true') filter.originalPrice = { $ne: null };

  // If user has preferred styles, match against product tags
  // e.g. style 'minimalist' matches products tagged 'minimalist'
  if (styles.length > 0) {
    filter.tags = { $in: styles };
  }

  // If user has preferred brands, look up their ObjectIds first
  if (brandNames.length > 0) {
    const brands = await Brand.find({
      name: { $in: brandNames.map((b) => new RegExp(`^${b}$`, 'i')) },
    }).select('_id');

    if (brands.length > 0) {
      filter.brand = { $in: brands.map((b) => b._id) };
    }
  }

  // ── Sort ────────────────────────────────────────────────────────────────────
  const sortMap = {
    price_asc:  { price: 1 },
    price_desc: { price: -1 },
    newest:     { createdAt: -1 },
  };
  const sortQuery = sortMap[sort] || { createdAt: -1 };

  // ── Paginate ────────────────────────────────────────────────────────────────
  const skip = (Number(page) - 1) * Number(limit);

  const [products, total] = await Promise.all([
    Product.find(filter)
      .sort(sortQuery)
      .skip(skip)
      .limit(Number(limit))
      .populate('brand', 'name slug logo'), // pull in brand name + logo
    Product.countDocuments(filter),
  ]);

  res.json({
    success:  true,
    total,
    page:     Number(page),
    pages:    Math.ceil(total / Number(limit)),
    products,
  });
};

// ── GET /api/products/search ──────────────────────────────────────────────────
// Public. Full-text search using MongoDB text index on name + tags.
//
// Query params:
//   q        = search term (required)
//   category = optional filter
//   saleOnly = true | false
export const searchProducts = async (req, res) => {
  const { q, category, saleOnly } = req.query;

  if (!q || q.trim() === '') {
    return res.status(400).json({ success: false, message: 'Search query is required' });
  }

  const filter = {
    isActive: true,
    $text:    { $search: q },
  };

  if (category) filter.category = category;
  if (saleOnly === 'true') filter.originalPrice = { $ne: null };

  const products = await Product.find(filter, { score: { $meta: 'textScore' } })
    .sort({ score: { $meta: 'textScore' } }) // best match first
    .limit(40)
    .populate('brand', 'name slug logo');

  res.json({ success: true, count: products.length, products });
};

// ── GET /api/products/:id ─────────────────────────────────────────────────────
// Public. Full product detail including all variants.
export const getProduct = async (req, res) => {
  const product = await Product.findById(req.params.id)
    .populate('brand', 'name slug logo description');

  if (!product || !product.isActive) {
    return res.status(404).json({ success: false, message: 'Product not found' });
  }

  res.json({ success: true, product });
};

export default { getProducts, searchProducts, getProduct };