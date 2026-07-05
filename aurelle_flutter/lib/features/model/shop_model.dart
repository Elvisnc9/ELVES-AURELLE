/// ─────────────────────────────────────────────────────────────────────────────
/// shop_model.dart
/// Pure data models for Shop screen and Product Detail screen.
/// ─────────────────────────────────────────────────────────────────────────────

enum ShopCategory { womenswear, menswear, everythingElse }

extension ShopCategoryLabel on ShopCategory {
  String get label {
    switch (this) {
      case ShopCategory.womenswear:   return 'WOMENSWEAR';
      case ShopCategory.menswear:     return 'MENSWEAR';
      case ShopCategory.everythingElse: return 'EVERYTHING ELSE';
    }
  }
}

/// Lightweight card shown in the 3-column shop grid
class ShopProductModel {
  const ShopProductModel({
    required this.id,
    required this.brand,
    required this.price,
    required this.category,
    this.originalPrice,
    this.imageUrl,
  });

  final String id;
  final String brand;
  final double price;
  final double? originalPrice;
  final ShopCategory category;
  final String? imageUrl;

  bool get isOnSale => originalPrice != null && originalPrice! > price;
}

/// A single product variant (shown in the thumbnail strip)
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.brand,
    required this.productName,
    required this.price,
    required this.images,
    this.originalPrice,
    this.salePercent,
    this.itemCode,
    this.itemInfo,
    this.supplierColor,
    this.thumbnailUrl,
  });

  final String id;
  final String brand;
  final String productName;
  final double price;
  final double? originalPrice;
  final int? salePercent;       // e.g. 40 → "40% OFF"
  final List<String> images;    // carousel images (URLs or asset paths)
  final String? thumbnailUrl;   // small square shown in the strip
  final String? itemCode;
  final String? itemInfo;
  final String? supplierColor;
}

/// Full product detail state
class ProductDetailState {
  const ProductDetailState({
    required this.variants,
    this.selectedVariantIndex = 0,
    this.selectedImageIndex = 0,
    this.isInWishlist = false,
    this.isLoading = false,
  });

  final List<ProductVariant> variants;
  final int selectedVariantIndex;
  final int selectedImageIndex;
  final bool isInWishlist;
  final bool isLoading;

  /// The currently active variant — driven by thumbnail tap
  ProductVariant get activeVariant => variants[selectedVariantIndex];

  ProductDetailState copyWith({
    List<ProductVariant>? variants,
    int? selectedVariantIndex,
    int? selectedImageIndex,
    bool? isInWishlist,
    bool? isLoading,
  }) {
    return ProductDetailState(
      variants: variants ?? this.variants,
      selectedVariantIndex: selectedVariantIndex ?? this.selectedVariantIndex,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Root state for the Shop screen
class ShopState {
  const ShopState({
    required this.products,
    this.selectedCategory = ShopCategory.womenswear,
    this.saleOnly = false,
    this.isLoading = false,
  });

  final List<ShopProductModel> products;
  final ShopCategory selectedCategory;
  final bool saleOnly;
  final bool isLoading;

  List<ShopProductModel> get filtered => products.where((p) {
        final catMatch = p.category == selectedCategory;
        final saleMatch = !saleOnly || p.isOnSale;
        return catMatch && saleMatch;
      }).toList();

  ShopState copyWith({
    List<ShopProductModel>? products,
    ShopCategory? selectedCategory,
    bool? saleOnly,
    bool? isLoading,
  }) {
    return ShopState(
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      saleOnly: saleOnly ?? this.saleOnly,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}