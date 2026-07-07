import  mongoose from 'mongoose';

// ── Order item sub-schema ─────────────────────────────────────────────────────
// Snapshot of what was purchased — product details won't change
// even if the product is later updated or deleted
const orderItemSchema = new mongoose.Schema({
  product:     { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
  productName: { type: String, required: true }, // snapshot
  brandName:   { type: String, required: true }, // snapshot
  imageUrl:    { type: String, default: null  }, // snapshot
  variantId:   { type: String, default: null  },
  size:        { type: String, default: null  },
  quantity:    { type: Number, required: true },
  price:       { type: Number, required: true }, // price at time of purchase
});

// ── Order schema ──────────────────────────────────────────────────────────────
const orderSchema = new mongoose.Schema(
  {
    user: {
      type:     mongoose.Schema.Types.ObjectId,
      ref:      'User',
      required: true,
    },
    items: {
      type:     [orderItemSchema],
      required: true,
    },
    total:    { type: Number, required: true },

    // ── Payment ───────────────────────────────────────────────────────────────
    stripePaymentIntentId: { type: String, default: null },
    paymentStatus: {
      type:    String,
      enum:    ['pending', 'paid', 'failed', 'refunded'],
      default: 'pending',
    },

    // ── Order lifecycle ───────────────────────────────────────────────────────
    status: {
      type:    String,
      enum:    ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
      default: 'pending',
    },

    shippingAddress: {
      street:  { type: String },
      city:    { type: String },
      country: { type: String },
      zip:     { type: String },
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
  },
);

// ── Virtual: total item count ─────────────────────────────────────────────────
orderSchema.virtual('itemCount').get(function () {
  return this.items.reduce((sum, i) => sum + i.quantity, 0);
});

// ── Index: user's orders newest first ────────────────────────────────────────
orderSchema.index({ user: 1, createdAt: -1 });



const Order = mongoose.model('Order', orderSchema);
export default Order;