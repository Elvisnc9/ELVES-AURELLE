/// ─────────────────────────────────────────────────────────────────────────────
/// reels_provider.dart
/// Riverpod StateNotifier for the Reels screen.
/// All UI interactions (like, save, page change, size/color select, card
/// toggle) are handled here. UI reads state only — zero logic in widgets.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final reelsProvider =
    StateNotifierProvider<ReelsNotifier, ReelsState>((ref) => ReelsNotifier());

// ── Notifier ──────────────────────────────────────────────────────────────────

class ReelsNotifier extends StateNotifier<ReelsState> {
  ReelsNotifier() : super(const ReelsState(reels: [], isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 400));
    state = ReelsState(reels: _mockReels, isLoading: false);
  }

  // ── Page changed (user swiped to next/prev reel) ──────────────────────────
  void onPageChanged(int index) {
    state = state.copyWith(
      currentIndex: index,
      // Reset selections when reel changes
      selectedSizeIndex: 0,
      selectedColorIndex: 0,
      cardVisible: true,
    );
  }

  // ── Product card visibility toggle (tap on video) ─────────────────────────
  void toggleCard() {
    state = state.copyWith(cardVisible: !state.cardVisible);
  }

  // ── Size selection ────────────────────────────────────────────────────────
  void selectSize(int index) {
    final sizes = state.currentReel?.product.sizes ?? [];
    if (index < sizes.length && !sizes[index].isSoldOut) {
      state = state.copyWith(selectedSizeIndex: index);
    }
  }

  // ── Color selection ───────────────────────────────────────────────────────
  void selectColor(int index) {
    state = state.copyWith(selectedColorIndex: index);
  }

  // ── Like toggle ───────────────────────────────────────────────────────────
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

  // ── Save toggle ───────────────────────────────────────────────────────────
  void toggleSave(String reelId) {
    state = state.copyWith(
      reels: state.reels.map((r) {
        if (r.id != reelId) return r;
        return r.copyWith(isSaved: !r.isSaved);
      }).toList(),
    );
  }
}

// ── Mock data ─────────────────────────────────────────────────────────────────

final _mockReels = [
  ReelModel(
    id: 'r1',
    videoAsset: 'assets/anim/Models_video1.mp4',
    likes: 2400,
    comments: 138,
    product: ReelProductModel(
      id: 'p1',
      name: 'UNISEX ABELLA',
      brand: 'Jux Label',
      price: 97.00,
      description:
          'UNISEX EXCLUSIVELY DESIGNED BY US FOR YOU. A cropped zip-up sweatshirt cut in an oversized fit. This zip-up features a hood with a drawstring, front side kangaroo pocket, silver zipper and is embellished with ribbed hankerings at the cuffs and hem.',
      material: '100% Cotton',
      length: '14 in',
      
      washingInstructions: 'Wash Cold, Dry Low',
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
        ReelColorOption(id: 'c5', color: const Color(0xFF9C27B0)),
      ],
    ),
  ),
  ReelModel(
    id: 'r2',
    videoAsset: 'assets/anim/Models_video2.mp4',
    likes: 1800,
    comments: 95,
    product: ReelProductModel(
      id: 'p2',
      name: 'SANTON MIDI DRESS',
      brand: 'Jacquemus',
      price: 420.00,
      description:
          'The La Robe Santon in 100% linen. A summer staple crafted in lightweight fabric with a relaxed silhouette and signature Jacquemus detailing.',
      material: '100% Linen',
      cardColor: Color(0XFF614051),
      length: '42 in',
      washingInstructions: 'Dry Clean Only',
      sizes: const [
        ReelSizeOption(label: 'XS'),
        ReelSizeOption(label: 'S'),
        ReelSizeOption(label: 'M'),
        ReelSizeOption(label: 'L', isSoldOut: true),
        ReelSizeOption(label: 'XL'),
      ],
      colors: [
        ReelColorOption(id: 'c1', color: const Color(0xFFF5E6CC)),
        ReelColorOption(id: 'c2', color: const Color(0xFF1A1A1A)),
        ReelColorOption(id: 'c3', color: const Color(0xFF8B6B4A)),
        ReelColorOption(id: 'c4', color: const Color(0xFFC4B5A0)),
      ],
    ),
  ),
  ReelModel(
    id: 'r3',
    videoAsset: 'assets/anim/Models_video3.mp4',
    likes: 3100,
    comments: 212,
    product: ReelProductModel(
      id: 'p3',
      name: 'CRESCENT CROP JACKET',
      brand: 'Marine Serre',
      price: 680.00,
      cardColor: Color(0XFF964B00),
      description:
          'Iconic Marine Serre moon print cropped jacket in regenerated fabric. Features front zip closure, ribbed cuffs and hem, and the signature crescent moon motif throughout.',
      material: '95% Regenerated Polyamide, 5% Elastane',
      length: '22 in',
      washingInstructions: 'Hand Wash Cold',
      sizes: const [
        ReelSizeOption(label: 'XS', isSoldOut: true),
        ReelSizeOption(label: 'S'),
        ReelSizeOption(label: 'M'),
        ReelSizeOption(label: 'L'),
      ],
      colors: [
        ReelColorOption(id: 'c1', color: const Color(0xFF0D0D0D)),
        ReelColorOption(id: 'c2', color: const Color(0xFFB0BEC5)),
        ReelColorOption(id: 'c3', color: const Color(0xFF37474F)),
      ],
    ),
  ),

    ReelModel(
    id: 'r3',
    videoAsset: 'assets/anim/Models_video4.mp4',
    likes: 3100,
    comments: 212,
    product: ReelProductModel(
      id: 'p3',
      name: 'CRESCENT CROP JACKET',
      brand: 'Marine Serre',
      price: 680.00,
      cardColor: Color(0XFF9966CC),
      description:
          'Iconic Marine Serre moon print cropped jacket in regenerated fabric. Features front zip closure, ribbed cuffs and hem, and the signature crescent moon motif throughout.',
      material: '95% Regenerated Polyamide, 5% Elastane',
      length: '22 in',
      washingInstructions: 'Hand Wash Cold',
      sizes: const [
        ReelSizeOption(label: 'XS', isSoldOut: true),
        ReelSizeOption(label: 'S'),
        ReelSizeOption(label: 'M'),
        ReelSizeOption(label: 'L'),
      ],
      colors: [
        ReelColorOption(id: 'c1', color: const Color(0xFF0D0D0D)),
        ReelColorOption(id: 'c2', color: const Color(0xFFB0BEC5)),
        ReelColorOption(id: 'c3', color: const Color(0xFF37474F)),
      ],
    ),
  ),

    ReelModel(
    id: 'r3',
    videoAsset: 'assets/anim/Models_video5.mp4',
    likes: 3100,
    comments: 212,
    product: ReelProductModel(
      id: 'p3',
      name: 'CRESCENT CROP JACKET',
      brand: 'Marine Serre',
      price: 680.00,
      cardColor: Color(0XFF004225),
      description:
          'Iconic Marine Serre moon print cropped jacket in regenerated fabric. Features front zip closure, ribbed cuffs and hem, and the signature crescent moon motif throughout.',
      material: '95% Regenerated Polyamide, 5% Elastane',
      length: '22 in',
      washingInstructions: 'Hand Wash Cold',
      sizes: const [
        ReelSizeOption(label: 'XS', isSoldOut: true),
        ReelSizeOption(label: 'S'),
        ReelSizeOption(label: 'M'),
        ReelSizeOption(label: 'L'),
      ],
      colors: [
        ReelColorOption(id: 'c1', color: const Color(0xFF0D0D0D)),
        ReelColorOption(id: 'c2', color: const Color(0xFFB0BEC5)),
        ReelColorOption(id: 'c3', color: const Color(0xFF37474F)),
      ],
    ),
  ),
];