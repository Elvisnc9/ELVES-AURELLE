/// ─────────────────────────────────────────────────────────────────────────────
/// reels_model.dart
///
/// ReelModel now carries ALL data needed to populate ProductDetailScreen.
/// When user swipes left from a reel, the horizontal PageView shows
/// ProductDetailScreen — driven entirely by ReelModel fields converted
/// to ProductDetailState via reelToProductDetailState().
///
/// No new screen. ProductDetailScreen is reused as-is.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:flutter/material.dart';

// ── Size option ───────────────────────────────────────────────────────────────

class ReelSizeOption {
  const ReelSizeOption({required this.label, this.isSoldOut = false});
  final String label;
  final bool isSoldOut;
}

// ── Color option ──────────────────────────────────────────────────────────────

class ReelColorOption {
  const ReelColorOption({required this.id, required this.color});
  final String id;
  final Color color;
}

// ── Product variant (for the thumbnail strip in ProductDetailScreen) ──────────

class ReelProductVariant {
  const ReelProductVariant({
    required this.id,
    required this.brand,
    required this.productName,
    required this.price,
    required this.images,       // carousel images for this variant
    this.originalPrice,
    this.salePercent,
    this.thumbnailUrl,
    this.sizes = const [],
    this.colors = const [],
    this.itemCode,
    this.itemInfo,
    this.supplierColor,
  });

  final String id;
  final String brand;
  final String productName;
  final double price;
  final double? originalPrice;
  final int? salePercent;
  final List<String> images;
  final String? thumbnailUrl;
  final List<ReelSizeOption> sizes;
  final List<ReelColorOption> colors;
  final String? itemCode;
  final String? itemInfo;
  final String? supplierColor;
}

// ── Main ReelModel ────────────────────────────────────────────────────────────

class ReelModel {
  const ReelModel({
    required this.id,
    required this.variants,         // index 0 = primary product shown on reel
    this.videoAsset,
    this.videoUrl,
    this.likes = 0,
    this.salesCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  }) : assert(variants.length > 0, 'ReelModel must have at least one variant');

  final String id;

  /// variants[0] is the primary product shown on the reel card.
  /// All variants populate the thumbnail strip in ProductDetailScreen.
  final List<ReelProductVariant> variants;

  // Video
  final String? videoAsset;
  final String? videoUrl;

  // Social proof — shown on the minimal reel card
  final int likes;
  final int salesCount;
  final double rating;
  final int reviewCount;

  // User interaction state
  final bool isLiked;
  final bool isSaved;

  /// Convenience getter — the primary variant
  ReelProductVariant get primaryVariant => variants.first;

  ReelModel copyWith({
    bool? isLiked,
    bool? isSaved,
    int? likes,
  }) {
    return ReelModel(
      id: id,
      variants: variants,
      videoAsset: videoAsset,
      videoUrl: videoUrl,
      likes: likes ?? this.likes,
      salesCount: salesCount,
      rating: rating,
      reviewCount: reviewCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

// ── Reels screen state ────────────────────────────────────────────────────────

class ReelsState {
  const ReelsState({
    required this.reels,
    this.currentIndex = 0,
    this.cardVisible = true,
    this.isLoading = false,
  });

  final List<ReelModel> reels;
  final int currentIndex;
  final bool cardVisible;
  final bool isLoading;

  ReelModel? get currentReel =>
      reels.isEmpty ? null : reels[currentIndex];

  ReelsState copyWith({
    List<ReelModel>? reels,
    int? currentIndex,
    bool? cardVisible,
    bool? isLoading,
  }) {
    return ReelsState(
      reels: reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
      cardVisible: cardVisible ?? this.cardVisible,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Adapter: ReelProductVariant → ProductVariant (for ProductDetailScreen) ────

/// Converts a ReelProductVariant into the ProductVariant model that
/// ProductDetailScreen already knows how to render.
/// This is the bridge — no new screen needed.
ProductVariant reelVariantToProductVariant(ReelProductVariant v) {
  return ProductVariant(
    id: v.id,
    brand: v.brand,
    productName: v.productName,
    price: v.price,
    originalPrice: v.originalPrice,
    salePercent: v.salePercent,
    images: v.images,
    thumbnailUrl: v.thumbnailUrl,
    itemCode: v.itemCode,
    itemInfo: v.itemInfo,
    supplierColor: v.supplierColor,
  );
}