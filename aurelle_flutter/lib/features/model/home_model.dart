/// ─────────────────────────────────────────────────────────────────────────────
/// home_model.dart
/// Pure data models for the Home screen. No logic — just typed containers
/// that the UI reads from providers.
/// ─────────────────────────────────────────────────────────────────────────────

/// A single product card (used in horizontal scroll rows & grids)
class HomeProductModel {
  const HomeProductModel({
    required this.id,
    required this.brand,
    required this.price,
    this.originalPrice,
    this.imageUrl,
  });

  final String id;
  final String brand;
  final double price;

  /// Non-null when the item is on sale
  final double? originalPrice;

  /// Remote URL or local asset path — UI handles both
  final String? imageUrl;

  bool get isOnSale => originalPrice != null && originalPrice! > price;
}

/// A curated brand-list section (the big stacked names below the hero)
class HomeBrandSectionModel {
  const HomeBrandSectionModel({
    required this.sectionNumber,
    required this.sectionLabel,
    required this.brands,
  });

  /// e.g. "007"
  final String sectionNumber;

  /// e.g. "NEW FROM"
  final String sectionLabel;

  /// Ordered list of brand names to stack
  final List<String> brands;
}

/// A curated product-row section (horizontal scroll)
class HomeProductSectionModel {
  const HomeProductSectionModel({
    required this.sectionNumber,
    required this.sectionLabel,
    required this.products,
    this.useGrid = false,
  });

  final String sectionNumber;
  final String sectionLabel;
  final List<HomeProductModel> products;

  /// When true, renders a 2-row grid instead of a single row
  final bool useGrid;
}

/// Hero banner data
class HeroBannerModel {
  const HeroBannerModel({
    required this.headline,
    required this.subline,
    required this.videoUrl,
    this.imageUrl,
  });

  final String headline;
  final String subline;
  final String? imageUrl;
  final String videoUrl;
}

/// Root state object for the entire Home screen
class HomeState {
  const HomeState({
    required this.heroBanner,
    required this.bagCount,
    required this.brandSection,
    required this.recentlyViewed,
    required this.productSections,
    this.isLoading = false,
  });

  final HeroBannerModel heroBanner;
  final int bagCount;
  final HomeBrandSectionModel brandSection;
  final List<HomeProductModel> recentlyViewed;
  final List<HomeProductSectionModel> productSections;
  final bool isLoading;

  HomeState copyWith({
    HeroBannerModel? heroBanner,
    int? bagCount,
    HomeBrandSectionModel? brandSection,
    List<HomeProductModel>? recentlyViewed,
    List<HomeProductSectionModel>? productSections,
    bool? isLoading,
  }) {
    return HomeState(
      heroBanner: heroBanner ?? this.heroBanner,
      bagCount: bagCount ?? this.bagCount,
      brandSection: brandSection ?? this.brandSection,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      productSections: productSections ?? this.productSections,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}