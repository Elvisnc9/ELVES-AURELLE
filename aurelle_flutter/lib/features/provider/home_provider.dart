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
  HomeNotifier() : super(_buildMockState(isLoading: true)) {
    _fetchHome();
  }

  /// Called on screen init and on pull-to-refresh.
  Future<void> refresh() async => _fetchHome();

  Future<void> _fetchHome() async {
    state = _buildMockState(isLoading: true);

    // 🔁 Replace with: final data = await ApiService.getHomeData();
    await Future.delayed(const Duration(milliseconds: 600)); // simulated delay

    state = _buildMockState(isLoading: false);
  }
}

// ── Mock seed data ────────────────────────────────────────────────────────────

const _mockRecentlyViewed = <HomeProductModel>[
  HomeProductModel(
    id: 'rv1',
    brand: 'Marine Serre',
    price: 300,
    imageUrl: 'assets/images/shop/rom.png',
  ),
  HomeProductModel(
    id: 'rv2',
    brand: 'YMC',
    price: 223,
    originalPrice: 290,
    imageUrl: 'assets/images/shop/shop1.png',
  ),
  HomeProductModel(
    id: 'rv3',
    brand: 'Paloma Wool',
    price: 160,
    originalPrice: 190,
    imageUrl: 'assets/images/shop/shop3.png',
  ),
  HomeProductModel(
    id: 'rv4',
    brand: 'Ganni',
    price: 185,
    imageUrl: 'assets/images/shop/shop4.png',
  ),
  HomeProductModel(
    id: 'rv5',
    brand: 'Off-White',
    price: 420,
    originalPrice: 680,
    imageUrl: 'assets/images/shop/shop5.png',
  ),
];

HomeState _buildMockState({required bool isLoading}) {
  return HomeState(
    isLoading: isLoading,
    bagCount: 1,
    heroBanner: const HeroBannerModel(
      headline: 'SUMMER DEALS',
      subline: 'THE EDIT — SS25',
      videoUrl: 'assets/anim/Asos-women_Video.mp4',
    ),
    brandSection: const HomeBrandSectionModel(
      sectionLabel: 'NEW FROM',
      brands: [
        'AURELIAN',
        'RICK OWENS',
        'C.I.T.S',
        'MARINE SERRE',
        'VIVIENNE WESTWOOD',
        'GANNI',
        'PALM ANGELS',
      ],
      sectionNumber: '',
    ),
    recentlyViewed: _mockRecentlyViewed,
    productSections: const [
    HomeProductSectionModel(
      sectionLabel: 'TRENDING NOW',
      useGrid: false,
      products: [
        HomeProductModel(id: 's1p1', brand: 'Palm Angels', price: 133, originalPrice: 170, imageUrl: 'assets/images/shop/shop1.png'),
        HomeProductModel(id: 's1p2', brand: 'Marine Serre', price: 94, originalPrice: 230, imageUrl: 'assets/images/shop/rom.png'),
        HomeProductModel(id: 's1p3', brand: 'Marine Serre', price: 139, originalPrice: 235, imageUrl: 'assets/images/shop/shop3.png'),
        HomeProductModel(id: 's1p4', brand: 'Palm Angels', price: 108, originalPrice: 130, imageUrl: 'assets/images/shop/shop4.png'),
        HomeProductModel(id: 's1p5', brand: 'Ganni', price: 210, imageUrl: 'assets/images/shop/shop5.png'),
      ], sectionNumber: '',
    ),
    HomeProductSectionModel(
      sectionLabel: 'FOR YOU',
      useGrid: true,
      products: [
        HomeProductModel(id: 's2p1', brand: 'Adidas Originals', price: 84, originalPrice: 105, imageUrl: 'assets/images/shop/shop6.png'),
        HomeProductModel(id: 's2p2', brand: 'Adidas Originals', price: 81, originalPrice: 90, imageUrl: 'assets/images/shop/shop7.png'),
        HomeProductModel(id: 's2p3', brand: 'Marine Serre', price: 207, originalPrice: 230, imageUrl: 'assets/images/shop/shop8.png'),
        HomeProductModel(id: 's2p4', brand: 'Marine Serre', price: 100, originalPrice: 205, imageUrl: 'assets/images/shop/shop9.png'),
        HomeProductModel(id: 's2p5', brand: 'Off-White', price: 315, imageUrl: 'assets/images/shop/shop10.png'),
        HomeProductModel(id: 's2p6', brand: 'Jacquemus', price: 420, imageUrl: 'assets/images/shop/shop11.png'),
                HomeProductModel(id: 's2p5', brand: 'Off-White', price: 315, imageUrl: 'assets/images/shop/street.png'),
        HomeProductModel(id: 's2p6', brand: 'Jacquemus', price: 420, imageUrl: 'assets/images/shop/trnd.png'),
      ], sectionNumber: '',
    ),
    HomeProductSectionModel(
      sectionLabel: 'EDITORS PICK',
      useGrid: false,
      products: [
        HomeProductModel(id: 's3p1', brand: 'Anine Bing', price: 140, originalPrice: 265, imageUrl: 'assets/images/shop/shop12.png'),
        HomeProductModel(id: 's3p2', brand: 'Anine Bing', price: 125, originalPrice: 265, imageUrl: 'assets/images/shop/shop3.png'),
        HomeProductModel(id: 's3p3', brand: 'Anine Bing', price: 103, originalPrice: 265, imageUrl: 'assets/images/shop/shop1.png'),
        HomeProductModel(id: 's3p4', brand: 'Martine Rose', price: 344, originalPrice: 465, imageUrl: 'assets/images/shop/wool_red1.png'),
      ], sectionNumber: '',
    ),
    ],
  );
}