import  mongoose from 'mongoose';

// ── Variant sub-schema ────────────────────────────────────────────────────────
// Each variant = one colour of the same product
// e.g. "Unisex Abella" in Black, White, Pink = 3 variants
const variantSchema = new mongoose.Schema({
  color:        { type: String, required: true }, // e.g. 'Midnight Black'
  colorHex:     { type: String, default: null },  // e.g. '#1A1A1A'
  images:       { type: [String], default: [] },  // Cloudinary image URLs
  thumbnailUrl: { type: String,  default: null }, // small thumbnail for strip
  stock:        { type: Number,  default: 0 },
});

// ── Size sub-schema ───────────────────────────────────────────────────────────
const sizeSchema = new mongoose.Schema({
  label:     { type: String, required: true }, // 'XS', 'S', 'M', 'L', 'XL'
  isSoldOut: { type: Boolean, default: false },
});

// ── Product schema ────────────────────────────────────────────────────────────
const productSchema = new mongoose.Schema(
  {
    name:  { type: String, required: [true, 'Product name is required'], trim: true },
    brand: {
      type: mongoose.Schema.Types.ObjectId,
      ref:  'Brand',
      required: true,
    },

    // ── Pricing ───────────────────────────────────────────────────────────────
    price:         { type: Number, required: [true, 'Price is required'] },
    originalPrice: { type: Number, default: null }, // null = not on sale

    // ── Category ──────────────────────────────────────────────────────────────
    category: {
      type:     String,
      enum:     ['womenswear', 'menswear', 'everythingElse'],
      required: true,
    },

    // ── Details ───────────────────────────────────────────────────────────────
    description:   { type: String, default: '' },
    itemInfo:      { type: String, default: '' }, // bullet point details
    itemCode:      { type: String, default: null },
    supplierColor: { type: String, default: null },
    tags:          { type: [String], default: [] }, // for search: ['jacket', 'moon print']

    // ── Sizes + Variants ──────────────────────────────────────────────────────
    sizes:    { type: [sizeSchema],   default: [] },
    variants: { type: [variantSchema], default: [] },

    isActive: { type: Boolean, default: true },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
  },
);

// ── Virtual: is this product on sale? ─────────────────────────────────────────
productSchema.virtual('isOnSale').get(function () {
  return this.originalPrice != null && this.originalPrice > this.price;
});

// ── Virtual: sale percentage ──────────────────────────────────────────────────
productSchema.virtual('salePercent').get(function () {
  if (!this.isOnSale) return null;
  return Math.round((1 - this.price / this.originalPrice) * 100);
});

// ── Indexes ───────────────────────────────────────────────────────────────────
// Text index powers the search endpoint
productSchema.index({ name: 'text', tags: 'text' });
productSchema.index({ category: 1, price: 1 });
productSchema.index({ brand: 1 });
productSchema.index({ isActive: 1 });


const Product = mongoose.model('Product', productSchema);
export default Product;
