/// ─────────────────────────────────────────────────────────────────────────────
/// reels_model.dart
/// Data models for the Reels screen. Pure containers — zero logic.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// A single size option on the product card
class ReelSizeOption {
  const ReelSizeOption({
    required this.label,
    this.isSoldOut = false,
  });

  final String label;
  final bool isSoldOut;
}

/// A single colour swatch on the product card
class ReelColorOption {
  const ReelColorOption({
    required this.id,
    required this.color,
  });

  final String id;
  final Color color;
}

/// The product card data attached to a reel
class ReelProductModel {
  const ReelProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.sizes,
    required this.colors,
    this.description,
    this.material,
    this.length,
    this.washingInstructions,
    this.cardColor = const Color.fromARGB(255, 239, 104, 104), // white default; API sets per-product
  });

  final String id;
  final String name;
  final String brand;
  final double price;
  final List<ReelSizeOption> sizes;
  final List<ReelColorOption> colors;
  final String? description;
  final String? material;
  final String? length;
  final String? washingInstructions;

  /// Dominant colour extracted from the product image.
  /// Defaults to white — will be set dynamically from the API/cloud
  /// (e.g. palette extraction from the product photo) so the card
  /// background matches the product's aesthetic.
  final Color cardColor;
}

/// A single reel (video + associated product)
class ReelModel {
  const ReelModel({
    required this.id,
    required this.product,
    this.videoAsset,
    this.videoUrl,
    this.thumbnailUrl,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  final String id;
  final ReelProductModel product;
  final String? videoAsset;   // local asset path
  final String? videoUrl;     // remote URL (used when backend is ready)
  final String? thumbnailUrl;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isSaved;

  ReelModel copyWith({
    bool? isLiked,
    bool? isSaved,
    int? likes,
    int? comments,
  }) {
    return ReelModel(
      id: id,
      product: product,
      videoAsset: videoAsset,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Root state for the Reels screen
class ReelsState {
  const ReelsState({
    required this.reels,
    this.currentIndex = 0,
    this.selectedSizeIndex = 0,
    this.selectedColorIndex = 0,
    this.cardVisible = true,
    this.isLoading = false,
  });

  final List<ReelModel> reels;
  final int currentIndex;
  final int selectedSizeIndex;
  final int selectedColorIndex;
  final bool cardVisible;
  final bool isLoading;

  ReelModel? get currentReel =>
      reels.isEmpty ? null : reels[currentIndex];

  ReelsState copyWith({
    List<ReelModel>? reels,
    int? currentIndex,
    int? selectedSizeIndex,
    int? selectedColorIndex,
    bool? cardVisible,
    bool? isLoading,
  }) {
    return ReelsState(
      reels: reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedSizeIndex: selectedSizeIndex ?? this.selectedSizeIndex,
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      cardVisible: cardVisible ?? this.cardVisible,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}