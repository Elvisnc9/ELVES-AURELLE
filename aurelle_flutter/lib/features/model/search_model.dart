/// ─────────────────────────────────────────────────────────────────────────────
/// search_model.dart
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/shop_model.dart';

enum SearchCategory { womenswear, menswear, everythingElse }

extension SearchCategoryLabel on SearchCategory {
  String get label {
    switch (this) {
      case SearchCategory.womenswear:    return 'WOMENSWEAR';
      case SearchCategory.menswear:      return 'MENSWEAR';
      case SearchCategory.everythingElse: return 'EVERYTHING ELSE';
    }
  }
}

class SearchState {
  const SearchState({
    this.query = '',
    this.selectedCategory = SearchCategory.womenswear,
    this.saleOnly = false,
    this.isSearching = false,
    this.results = const [],
  });

  final String query;
  final SearchCategory selectedCategory;
  final bool saleOnly;
  final bool isSearching;
  final List<ShopProductModel> results;

  bool get hasQuery => query.trim().isNotEmpty;

  SearchState copyWith({
    String? query,
    SearchCategory? selectedCategory,
    bool? saleOnly,
    bool? isSearching,
    List<ShopProductModel>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      saleOnly: saleOnly ?? this.saleOnly,
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
    );
  }
}