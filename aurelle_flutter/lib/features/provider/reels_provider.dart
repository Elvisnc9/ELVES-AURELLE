/// ─────────────────────────────────────────────────────────────────────────────
/// reels_provider.dart
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:aurelle_flutter/features/provider/product_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Reels provider ────────────────────────────────────────────────────────────

final reelsProvider =
    StateNotifierProvider<ReelsNotifier, ReelsState>((ref) => ReelsNotifier());

class ReelsNotifier extends StateNotifier<ReelsState> {
  ReelsNotifier() : super(const ReelsState(reels: [], isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // 🔁 Replace with: final data = await ApiService.getReels();
    state = ReelsState(reels: _mockReels, isLoading: false);
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentIndex: index, cardVisible: true);
  }

  void toggleCard() {
    state = state.copyWith(cardVisible: !state.cardVisible);
  }

  void toggleLike(String reelId) {
    state = state.copyWith(
      reels: state.reels.map((r) {
        if (r.id != reelId) return r;
        return r.copyWith(
          isLiked: !r.isLiked,
          likes: r.isLiked ? r.likes - 1 : r.likes + 1,
        );
      }).toList(),
    );
  }

  void toggleSave(String reelId) {
    state = state.copyWith(
      reels: state.reels.map((r) {
        if (r.id != reelId) return r;
        return r.copyWith(isSaved: !r.isSaved);
      }).toList(),
    );
  }
}

// ── Per-reel ProductDetailState provider ─────────────────────────────────────
// When user swipes left, ProductDetailScreen watches this provider
// (keyed by reelId) to get its fully-populated state from the reel data.

final reelProductDetailProvider = StateNotifierProvider.family<
    ProductDetailNotifier, ProductDetailState, String>(
  (ref, reelId) {
    final reels = ref.watch(reelsProvider).reels;
    final reel = reels.firstWhere(
      (r) => r.id == reelId,
      orElse: () => _mockReels.first,
    );
    return ReelProductDetailNotifier(reel);
  },
);

class ReelProductDetailNotifier extends ProductDetailNotifier {
  ReelProductDetailNotifier(ReelModel reel)
      : super.fromState(ProductDetailState(
          variants: reel.variants.map(reelVariantToProductVariant).toList(),
          isLoading: false,
        ));

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

// ── Mock data ─────────────────────────────────────────────────────────────────

final _mockReels = [
  ReelModel(
    id: 'r1',
    videoAsset: 'assets/anim/Models_video5.mp4',
    likes: 2400,
    salesCount: 318,
    rating: 4.7,
    reviewCount: 124,
    variants: [
      ReelProductVariant(
        id: 'r1v1',
        brand: 'Elves',
        productName: 'C.I.T.S Wear',
        price: 97.00,
        images: [],   // 🔁 real image URLs from API
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-001',
        itemInfo: ' A versatile and stylish piece, the Unisex Abella is crafted from premium materials for a comfortable fit. '
            'Its minimalist design makes it a perfect addition to any wardrobe, suitable for various occasions. '
            'Designed to elevate your wardrobe, it pairs effortlessly with both casual and formal looks. '
            'Every detail is carefully finished to deliver a refined and sophisticated experience.',
        supplierColor: 'Cream',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L'),
          ReelSizeOption(label: 'XL'),
          ReelSizeOption(label: 'XXL'),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFFE91E8C)),
          ReelColorOption(id: 'c2', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c3', color: const Color(0xFFD32F2F)),
          ReelColorOption(id: 'c4', color: const Color(0xFF6B4226)),
        ],
      ),
      ReelProductVariant(
        id: 'r1v2',
        brand: 'Jux Label',
        productName: 'UNISEX ABELLA — Black',
        price: 97.00,
        images: [],
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-002',
        itemInfo: 'Same cut, midnight black colourway.',
        supplierColor: 'Black',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L', isSoldOut: true),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c2', color: const Color(0xFF37474F)),
        ],
      ),
    ],
  ),
   ReelModel(
    id: 'r1',
    videoAsset: 'assets/anim/Models_video4.mp4',
    likes: 2400,
    salesCount: 318,
    rating: 4.7,
    reviewCount: 124,
    variants: [
      ReelProductVariant(
        id: 'r1v1',
        brand: 'Prada',
        productName: 'Kadence Jacket',
        price: 97.00,
        images: [],   // 🔁 real image URLs from API
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-001',
        itemInfo: ' A versatile and stylish piece, the Unisex Abella is crafted from premium materials for a comfortable fit. '
            'Its minimalist design makes it a perfect addition to any wardrobe, suitable for various occasions. '
            'Designed to elevate your wardrobe, it pairs effortlessly with both casual and formal looks. '
            'Every detail is carefully finished to deliver a refined and sophisticated experience.',
        supplierColor: 'Cream',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L'),
          ReelSizeOption(label: 'XL'),
          ReelSizeOption(label: 'XXL'),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFFE91E8C)),
          ReelColorOption(id: 'c2', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c3', color: const Color(0xFFD32F2F)),
          ReelColorOption(id: 'c4', color: const Color(0xFF6B4226)),
        ],
      ),
      ReelProductVariant(
        id: 'r1v2',
        brand: 'Jux Label',
        productName: 'UNISEX ABELLA — Black',
        price: 97.00,
        images: [],
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-002',
        itemInfo: 'Same cut, midnight black colourway.',
        supplierColor: 'Black',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L', isSoldOut: true),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c2', color: const Color(0xFF37474F)),
        ],
      ),
    ],
  ),
   ReelModel(
    id: 'r1',
    videoAsset: 'assets/anim/Models_video3.mp4',
    likes: 2400,
    salesCount: 318,
    rating: 4.7,
    reviewCount: 124,
    variants: [
      ReelProductVariant(
        id: 'r1v1',
        brand: 'Aurelle Pick',
        productName: 'Aurellian Woman',
        price: 97.00,
        images: [],   // 🔁 real image URLs from API
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-001',
        itemInfo: ' A versatile and stylish piece, the Unisex Abella is crafted from premium materials for a comfortable fit. '
            'Its minimalist design makes it a perfect addition to any wardrobe, suitable for various occasions. '
            'Designed to elevate your wardrobe, it pairs effortlessly with both casual and formal looks. '
            'Every detail is carefully finished to deliver a refined and sophisticated experience.',
        supplierColor: 'Cream',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L'),
          ReelSizeOption(label: 'XL'),
          ReelSizeOption(label: 'XXL'),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFFE91E8C)),
          ReelColorOption(id: 'c2', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c3', color: const Color(0xFFD32F2F)),
          ReelColorOption(id: 'c4', color: const Color(0xFF6B4226)),
        ],
      ),
      ReelProductVariant(
        id: 'r1v2',
        brand: 'Jux Label',
        productName: 'UNISEX ABELLA — Black',
        price: 97.00,
        images: [],
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-002',
        itemInfo: 'Same cut, midnight black colourway.',
        supplierColor: 'Black',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L', isSoldOut: true),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c2', color: const Color(0xFF37474F)),
        ],
      ),
    ],
  ),

   ReelModel(
    id: 'r1',
    videoAsset: 'assets/anim/Models_video2.mp4',
    likes: 2400,
    salesCount: 318,
    rating: 4.7,
    reviewCount: 124,
    variants: [
      ReelProductVariant(
        id: 'r1v1',
        brand: 'Gucci',
        productName: 'Iron Lady Kit',
        price: 97.00,
        images: [],   // 🔁 real image URLs from API
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-001',
        itemInfo: ' A versatile and stylish piece, the Unisex Abella is crafted from premium materials for a comfortable fit. '
            'Its minimalist design makes it a perfect addition to any wardrobe, suitable for various occasions. '
            'Designed to elevate your wardrobe, it pairs effortlessly with both casual and formal looks. '
            'Every detail is carefully finished to deliver a refined and sophisticated experience.',
        supplierColor: 'Cream',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L'),
          ReelSizeOption(label: 'XL'),
          ReelSizeOption(label: 'XXL'),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFFE91E8C)),
          ReelColorOption(id: 'c2', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c3', color: const Color(0xFFD32F2F)),
          ReelColorOption(id: 'c4', color: const Color(0xFF6B4226)),
        ],
      ),
      ReelProductVariant(
        id: 'r1v2',
        brand: 'Jux Label',
        productName: 'UNISEX ABELLA — Black',
        price: 97.00,
        images: [],
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-002',
        itemInfo: 'Same cut, midnight black colourway.',
        supplierColor: 'Black',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L', isSoldOut: true),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c2', color: const Color(0xFF37474F)),
        ],
      ),
    ],
  ),

   ReelModel(
    id: 'r1',
    videoAsset: 'assets/anim/Models_video1.mp4',
    likes: 2400,
    salesCount: 318,
    rating: 4.7,
    reviewCount: 124,
    variants: [
      ReelProductVariant(
        id: 'r1v1',
        brand: 'Lowie vitton',
        productName: 'Lowie Vintage Jacket',
        price: 97.00,
        images: [],   // 🔁 real image URLs from API
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-001',
        itemInfo: ' A versatile and stylish piece, the Lowie Vintage Jacket is crafted from premium materials for a comfortable fit. '
            'Its minimalist design makes it a perfect addition to any wardrobe, suitable for various occasions. '
            'Designed to elevate your wardrobe, it pairs effortlessly with both casual and formal looks. '
            'Every detail is carefully finished to deliver a refined and sophisticated experience.',
        supplierColor: 'Cream',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L'),
          ReelSizeOption(label: 'XL'),
          ReelSizeOption(label: 'XXL'),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFFE91E8C)),
          ReelColorOption(id: 'c2', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c3', color: const Color(0xFFD32F2F)),
          ReelColorOption(id: 'c4', color: const Color(0xFF6B4226)),
        ],
      ),
      ReelProductVariant(
        id: 'r1v2',
        brand: 'Lowie vitton',
        productName: 'Lowie Vintage Jacket — Black',
        price: 97.00,
        images: [],
        thumbnailUrl: null,
        itemCode: 'JUX-2025-AB-002',
        itemInfo: 'Same cut, midnight black colourway.',
        supplierColor: 'Black',
        sizes: const [
          ReelSizeOption(label: 'S'),
          ReelSizeOption(label: 'M'),
          ReelSizeOption(label: 'L', isSoldOut: true),
        ],
        colors: [
          ReelColorOption(id: 'c1', color: const Color(0xFF1A1A1A)),
          ReelColorOption(id: 'c2', color: const Color(0xFF37474F)),
        ],
      ),
    ],
  ),
];