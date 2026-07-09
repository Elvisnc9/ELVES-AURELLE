/// ─────────────────────────────────────────────────────────────────────────────
/// product_detail_provider.dart
///
/// Architecture:
///   • productDetailProvider(productId) is the single source of truth for
///     ProductDetailScreen — used whether navigated from Shop OR Reels.
///   • reelProductCacheProvider holds reel product data written by ReelsScreen
///     before it navigates. productDetailProvider checks this cache first
///     before falling back to the API fetch.
///   • This means no separate provider, no fromReels flag, no duplicate screen.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Reel product cache ────────────────────────────────────────────────────────
// ReelsScreen writes reel variant data here (keyed by variantId) before
// pushing the product route. productDetailProvider reads it first.
// When backend is wired, real product API responses will populate this same
// cache, so the flow stays identical.

final reelProductCacheProvider =
    StateProvider<Map<String, ProductDetailState>>((ref) => {});

// ── Main provider ─────────────────────────────────────────────────────────────

final productDetailProvider = StateNotifierProvider.family<
    ProductDetailNotifier, ProductDetailState, String>(
  (ref, productId) {
    // Check reel cache first — populated by ReelsScreen before navigation
    final cached = ref.read(reelProductCacheProvider)[productId];
    if (cached != null) return ProductDetailNotifier.fromState(cached);
    return ProductDetailNotifier(productId);
  },
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier(this.productId)
      : super(const ProductDetailState(variants: [], isLoading: true)) {
    _load();
  }

  ProductDetailNotifier.fromState(ProductDetailState initialState)
      : productId = '',
        super(initialState);

  final String productId;

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 350));
    // 🔁 Replace with: final data = await ApiService.getProductDetail(productId);
    state = ProductDetailState(
      variants: _mockVariants[productId] ?? _fallbackVariants,
      isLoading: false,
    );
  }

  void selectVariant(int index) {
    state = state.copyWith(
      selectedVariantIndex: index,
      selectedImageIndex: 0,
    );
  }

  void selectImage(int index) {
    state = state.copyWith(selectedImageIndex: index);
  }

  void toggleWishlist() {
    state = state.copyWith(isInWishlist: !state.isInWishlist);
  }
}

// ── Mock data (unchanged) ─────────────────────────────────────────────────────

const _fallbackVariants = [
  ProductVariant(
    id: 'v1',
    brand: 'YMC',
    productName: 'Green Atomic Cardigan',
    price: 195,
    originalPrice: 325,
    salePercent: 40,
    images: [],
    itemCode: '261161F095003',
    itemInfo:
        'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
    supplierColor: 'Green',
  ),
  ProductVariant(
    id: 'v2',
    brand: 'YMC',
    productName: 'Blue Atomic Cardigan',
    price: 195,
    originalPrice: 325,
    salePercent: 40,
    images: [],
    itemCode: '261161F095004',
    itemInfo:
        'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout',
    supplierColor: 'Blue',
  ),
];

const Map<String, List<ProductVariant>> _mockVariants = {
  'w2': _fallbackVariants,
};