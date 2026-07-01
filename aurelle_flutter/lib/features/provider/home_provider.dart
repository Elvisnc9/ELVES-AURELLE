/// ─────────────────────────────────────────────────────────────────────────────
/// home_provider.dart
/// Riverpod state notifier for the Home screen.
/// Currently seeded with mock data — swap the _fetchHome() body for real
/// API calls (via Dio) when the backend is ready. The UI never changes.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final homeProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) => HomeNotifier());

// ── Notifier ──────────────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(_initialState) {
    _fetchHome();
  }

  /// Called on screen init and on pull-to-refresh.
  Future<void> refresh() async => _fetchHome();

  Future<void> _fetchHome() async {
    state = state.copyWith(isLoading: true);

    // 🔁 Replace with: final data = await ApiService.getHomeData();
    await Future.delayed(const Duration(milliseconds: 600)); // simulated delay

    state = _initialState.copyWith(isLoading: false);
  }
}

// ── Mock seed data ────────────────────────────────────────────────────────────

const _initialState = HomeState(
  isLoading: true,
  bagCount: 1,

  heroBanner: HeroBannerModel(
    headline: 'NEW ARRIVALS',
    subline: 'THE EDIT — SS25',
    videoUrl: 'assets/anim/Asos-women_Video.mp4',
  ),

  brandSection: HomeBrandSectionModel(
    sectionNumber: '007',
    sectionLabel: 'NEW FROM',
    brands: [
      'MARINE SERRE',
      'VIVIENNE WESTWOOD',
      'GANNI',
      'MM6 MAISON MARGIELA',
      'OFF-WHITE',
      'AMINA MUADDI',
      'PALM ANGELS',
    ],
  ),

  recentlyViewed: [
    HomeProductModel(
      id: 'rv1',
      brand: 'Marine Serre',
      price: 300,
    ),
    HomeProductModel(
      id: 'rv2',
      brand: 'YMC',
      price: 223,
      originalPrice: 290,
    ),
    HomeProductModel(
      id: 'rv3',
      brand: 'Paloma Wool',
      price: 160,
      originalPrice: 190,
    ),
    HomeProductModel(
      id: 'rv4',
      brand: 'Ganni',
      price: 185,
    ),
    HomeProductModel(
      id: 'rv5',
      brand: 'Off-White',
      price: 420,
      originalPrice: 680,
    ),
  ],

  productSections: [
    HomeProductSectionModel(
      sectionNumber: '040',
      sectionLabel: 'TRENDING NOW',
      useGrid: false,
      products: [
        HomeProductModel(id: 's1p1', brand: 'Palm Angels', price: 133, originalPrice: 170),
        HomeProductModel(id: 's1p2', brand: 'Marine Serre', price: 94, originalPrice: 230),
        HomeProductModel(id: 's1p3', brand: 'Marine Serre', price: 139, originalPrice: 235),
        HomeProductModel(id: 's1p4', brand: 'Palm Angels', price: 108, originalPrice: 130),
        HomeProductModel(id: 's1p5', brand: 'Ganni', price: 210),
      ],
    ),
    HomeProductSectionModel(
      sectionNumber: '040',
      sectionLabel: 'FOR YOU',
      useGrid: true,
      products: [
        HomeProductModel(id: 's2p1', brand: 'Adidas Originals', price: 84, originalPrice: 105),
        HomeProductModel(id: 's2p2', brand: 'Adidas Originals', price: 81, originalPrice: 90),
        HomeProductModel(id: 's2p3', brand: 'Marine Serre', price: 207, originalPrice: 230),
        HomeProductModel(id: 's2p4', brand: 'Marine Serre', price: 100, originalPrice: 205),
        HomeProductModel(id: 's2p5', brand: 'Off-White', price: 315),
        HomeProductModel(id: 's2p6', brand: 'Jacquemus', price: 420),
      ],
    ),
    HomeProductSectionModel(
      sectionNumber: '040',
      sectionLabel: 'EDITORS PICK',
      useGrid: false,
      products: [
        HomeProductModel(id: 's3p1', brand: 'Anine Bing', price: 140, originalPrice: 265),
        HomeProductModel(id: 's3p2', brand: 'Anine Bing', price: 125, originalPrice: 265),
        HomeProductModel(id: 's3p3', brand: 'Anine Bing', price: 103, originalPrice: 265),
        HomeProductModel(id: 's3p4', brand: 'Martine Rose', price: 344, originalPrice: 465),
      ],
    ),
  ],
);