import mongoose from 'mongoose';

// ── Cart item sub-schema ──────────────────────────────────────────────────────
const cartItemSchema = new mongoose.Schema({
  product:   {
    type: mongoose.Schema.Types.ObjectId,
    ref:  'Product',
    required: true,
  },
  variantId: { type: String, default: null }, // which colour variant
  size:      { type: String, default: null }, // which size
  quantity:  { type: Number, default: 1, min: 1 },

  // Price snapshot — we store the price AT THE TIME the item was added.
  // This means if the price changes later, the cart shows the original price.
  price: { type: Number, required: true },
});

// ── Cart schema ───────────────────────────────────────────────────────────────
const cartSchema = new mongoose.Schema(
  {
    // One cart per user — null for guest (handled client-side in Flutter)
    user: {
      type:   mongoose.Schema.Types.ObjectId,
      ref:    'User',
      unique: true,
      default: null,
    },
    items: { type: [cartItemSchema], default: [] },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
  },
);

// ── Virtual: total number of items ───────────────────────────────────────────
cartSchema.virtual('itemCount').get(function () {
  return this.items.reduce((sum, item) => sum + item.quantity, 0); 
});

// ── Virtual: total price ──────────────────────────────────────────────────────
cartSchema.virtual('total').get(function () {
  return this.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
});


const Cart = mongoose.model('Cart', cartSchema);
export default Cart;

