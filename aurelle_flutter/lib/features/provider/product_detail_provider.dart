import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider (takes productId so each product gets its own state) ─────────────

final productDetailProvider = StateNotifierProvider.family<
    ProductDetailNotifier, ProductDetailState, String>(
  (ref, productId) => ProductDetailNotifier(productId),
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier(this.productId)
      : super(const ProductDetailState(variants: [], isLoading: true)) {
    _load();
  }

  final String productId;

  /// Named constructor used by ReelProductDetailNotifier to inject
  /// pre-built state directly — no async load needed.
  ProductDetailNotifier.fromState(ProductDetailState initialState)
      : productId = '',
        super(initialState);

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 350));
    // 🔁 Replace with: final data = await ApiService.getProductDetail(productId);
    state = ProductDetailState(
      variants: _mockVariants[productId] ?? _fallbackVariants,
      isLoading: false,
    );
  }

  /// User tapped a thumbnail — swap the entire active variant
  void selectVariant(int index) {
    state = state.copyWith(
      selectedVariantIndex: index,
      selectedImageIndex: 0, // reset to first image of new variant
    );
  }

  /// User swiped the main image carousel
  void selectImage(int index) {
    state = state.copyWith(selectedImageIndex: index);
  }

  void toggleWishlist() {
    state = state.copyWith(isInWishlist: !state.isInWishlist);
  }
}

// ── Mock variant data ─────────────────────────────────────────────────────────

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
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
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
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
    supplierColor: 'Blue',
  ),
  ProductVariant(
    id: 'v3',
    brand: 'YMC',
    productName: 'Beige Atomic Cardigan',
    price: 210,
    originalPrice: 325,
    salePercent: 35,
    images: [],
    itemCode: '261161F095005',
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
    supplierColor: 'Beige',
  ),
    ProductVariant(
    id: 'v1',
    brand: 'YMC',
    productName: 'Green Atomic Cardigan',
    price: 195,
    originalPrice: 325,
    salePercent: 40,
    images: [],
    itemCode: '261161F095003',
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
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
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
    supplierColor: 'Blue',
  ),
  ProductVariant(
    id: 'v3',
    brand: 'YMC',
    productName: 'Beige Atomic Cardigan',
    price: 210,
    originalPrice: 325,
    salePercent: 35,
    images: [],
    itemCode: '261161F095005',
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
    supplierColor: 'Beige',
  ),
    ProductVariant(
    id: 'v1',
    brand: 'YMC',
    productName: 'Green Atomic Cardigan',
    price: 195,
    originalPrice: 325,
    salePercent: 40,
    images: [],
    itemCode: '261161F095003',
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
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
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
    supplierColor: 'Blue',
  ),
  ProductVariant(
    id: 'v3',
    brand: 'YMC',
    productName: 'Beige Atomic Cardigan',
    price: 210,
    originalPrice: 325,
    salePercent: 35,
    images: [],
    itemCode: '261161F095005',
    itemInfo: 'Garter-stitch knit cotton cardigan.\n\n· Colorblocking and loose threads throughout\n· Rib-knit crewneck, hem, and cuffs\n· Button closure\n· Raglan sleeves\n· Corozo hardware',
    supplierColor: 'Beige',
  ),
];

// 🔁 Keyed by productId — swap with API response
const Map<String, List<ProductVariant>> _mockVariants = {
  'w2': _fallbackVariants,
};