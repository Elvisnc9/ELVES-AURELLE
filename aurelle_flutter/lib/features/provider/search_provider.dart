/// ─────────────────────────────────────────────────────────────────────────────
/// search_provider.dart
/// Handles query updates, category switching, sale filter, and result
/// filtering. All UI reads state only — zero logic in widgets.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:aurelle_flutter/features/model/search_model.dart';
import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) => SearchNotifier());

// ── Notifier ──────────────────────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  // ── Query update ──────────────────────────────────────────────────────────
  Future<void> updateQuery(String query) async {
    state = state.copyWith(query: query, isSearching: query.trim().isNotEmpty);

    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }

    // 🔁 Replace with: final results = await ApiService.search(query, category, saleOnly);
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    final filtered = _mockProducts.where((p) {
      final matchQuery = p.brand.toLowerCase().contains(q);
      final matchCat = _categoryMatches(p.category, state.selectedCategory);
      final matchSale = !state.saleOnly || p.isOnSale;
      return matchQuery && matchCat && matchSale;
    }).toList();

    if (mounted) {
      state = state.copyWith(results: filtered, isSearching: false);
    }
  }

  // ── Suggestion tapped ─────────────────────────────────────────────────────
  Future<void> applySuggestion(String suggestion) async {
    await updateQuery(suggestion);
  }

  // ── Category ──────────────────────────────────────────────────────────────
  void selectCategory(SearchCategory cat) {
    state = state.copyWith(selectedCategory: cat);
    if (state.hasQuery) updateQuery(state.query);
  }

  // ── Sale only ─────────────────────────────────────────────────────────────
  void toggleSaleOnly() {
    state = state.copyWith(saleOnly: !state.saleOnly);
    if (state.hasQuery) updateQuery(state.query);
  }

  // ── Clear ─────────────────────────────────────────────────────────────────
  void clear() {
    state = const SearchState();
  }

  bool _categoryMatches(ShopCategory productCat, SearchCategory selected) {
    switch (selected) {
      case SearchCategory.womenswear:    return productCat == ShopCategory.womenswear;
      case SearchCategory.menswear:      return productCat == ShopCategory.menswear;
      case SearchCategory.everythingElse: return productCat == ShopCategory.everythingElse;
    }
  }
}

// ── Suggested searches (static for now) ──────────────────────────────────────

const suggestedSearches = [
  'MARINE SERRE',
  'VIVIENNE WESTWOOD',
  'LOW TOP SNEAKERS',
  'T-SHIRTS',
];

// ── Recently viewed (reuse from home model) ───────────────────────────────────
// 🔁 Replace with: ref.watch(recentlyViewedProvider)
const mockRecentlyViewed = [
  HomeProductModel(id: 'rv1', brand: 'YMC',             price: 195, originalPrice: 325),
  HomeProductModel(id: 'rv2', brand: 'Marine Serre',    price: 207, originalPrice: 230),
  HomeProductModel(id: 'rv3', brand: 'Gimaguas',        price: 110, originalPrice: 215),
  HomeProductModel(id: 'rv4', brand: 'Adidas Originals',price: 95),
  HomeProductModel(id: 'rv5', brand: 'Hunza G',         price: 280),
];

// ── Mock product pool for search ──────────────────────────────────────────────
const _mockProducts = [
  ShopProductModel(id: 'w1', brand: 'Marine Serre',     price: 207, originalPrice: 230, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w2', brand: 'Vivienne Westwood',price: 340, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w3', brand: 'Ganni',            price: 180, originalPrice: 290, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w4', brand: 'Rick Owens',       price: 1710, category: ShopCategory.womenswear),
  ShopProductModel(id: 'm1', brand: 'Rick Owens',       price: 890, category: ShopCategory.menswear),
  ShopProductModel(id: 'm2', brand: 'Off-White',        price: 560, category: ShopCategory.menswear),
  ShopProductModel(id: 'e1', brand: 'Adidas Originals', price: 95,  category: ShopCategory.everythingElse),
];