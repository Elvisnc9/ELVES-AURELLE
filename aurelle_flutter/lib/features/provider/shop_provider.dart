import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Shop provider ─────────────────────────────────────────────────────────────

final shopProvider =
    StateNotifierProvider<ShopNotifier, ShopState>((ref) => ShopNotifier());

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier()
      : super(const ShopState(products: [], isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // 🔁 Replace with: final data = await ApiService.getShopProducts();
    state = ShopState(products: _mockProducts, isLoading: false);
  }

    Future<void> refresh() async => _fetchMoreProduct();

  Future<void> _fetchMoreProduct() async {
    state = state.copyWith(isLoading: true);

    // 🔁 Replace with: final data = await ApiService.getHomeData();
    await Future.delayed(const Duration(milliseconds: 600)); // simulated delay

    state = state.copyWith(products: _mockProducts, isLoading: false);
  }

  void selectCategory(ShopCategory cat) =>
      state = state.copyWith(selectedCategory: cat, saleOnly: false);

  void toggleSaleOnly() =>
      state = state.copyWith(saleOnly: !state.saleOnly);
}

// ── Mock data ─────────────────────────────────────────────────────────────────

const _mockProducts = [
  ShopProductModel(id: 'w1',  brand: 'Rick Owens',  price: 1710, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w2',  brand: 'Rick Owens',  price: 1070, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w3',  brand: 'Rick Owens',  price: 2950, category: ShopCategory.womenswear),
    ShopProductModel(id: 'w7',  brand: 'Willy Cha.',  price: 275,  category: ShopCategory.womenswear, originalPrice: 420),
  ShopProductModel(id: 'w8',  brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580),
  ShopProductModel(id: 'w9',  brand: 'Marine Serre',price: 305,  category: ShopCategory.womenswear, originalPrice: 490),
  ShopProductModel(id: 'w4',  brand: 'Rick Owens',  price: 3315, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w5',  brand: 'Rick Owens',  price: 375,  category: ShopCategory.womenswear),
    ShopProductModel(id: 'w7',  brand: 'Willy Cha.',  price: 275,  category: ShopCategory.womenswear, originalPrice: 420),
  ShopProductModel(id: 'w8',  brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580),
  ShopProductModel(id: 'w9',  brand: 'Marine Serre',price: 305,  category: ShopCategory.womenswear, originalPrice: 490),
  ShopProductModel(id: 'w6',  brand: 'Rick Owens',  price: 1405, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w7',  brand: 'Willy Cha.',  price: 275,  category: ShopCategory.womenswear, originalPrice: 420),
  ShopProductModel(id: 'w8',  brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580),
  ShopProductModel(id: 'w9',  brand: 'Marine Serre',price: 305,  category: ShopCategory.womenswear, originalPrice: 490),
    ShopProductModel(id: 'w1',  brand: 'Rick Owens',  price: 1710, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w2',  brand: 'Rick Owens',  price: 1070, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w3',  brand: 'Rick Owens',  price: 2950, category: ShopCategory.womenswear),
    ShopProductModel(id: 'w7',  brand: 'Willy Cha.',  price: 275,  category: ShopCategory.womenswear, originalPrice: 420),
  ShopProductModel(id: 'w8',  brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580),
  ShopProductModel(id: 'w9',  brand: 'Marine Serre',price: 305,  category: ShopCategory.womenswear, originalPrice: 490),
  ShopProductModel(id: 'w4',  brand: 'Rick Owens',  price: 3315, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w5',  brand: 'Rick Owens',  price: 375,  category: ShopCategory.womenswear),
    ShopProductModel(id: 'w7',  brand: 'Willy Cha.',  price: 275,  category: ShopCategory.womenswear, originalPrice: 420),
  ShopProductModel(id: 'w8',  brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580),
  ShopProductModel(id: 'w9',  brand: 'Marine Serre',price: 305,  category: ShopCategory.womenswear, originalPrice: 490),
  ShopProductModel(id: 'w6',  brand: 'Rick Owens',  price: 1405, category: ShopCategory.womenswear),
  ShopProductModel(id: 'w7',  brand: 'Willy Cha.',  price: 275,  category: ShopCategory.womenswear, originalPrice: 420),
  ShopProductModel(id: 'w8',  brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580),
  ShopProductModel(id: 'w9',  brand: 'Marine Serre',price: 305,  category: ShopCategory.womenswear, originalPrice: 490),
  ShopProductModel(id: 'm1',  brand: 'Rick Owens',  price: 890,  category: ShopCategory.menswear),
  ShopProductModel(id: 'm1',  brand: 'Rick Owens',  price: 890,  category: ShopCategory.menswear),
  ShopProductModel(id: 'm2',  brand: 'Off-White',   price: 560,  category: ShopCategory.menswear),
    ShopProductModel(id: 'm1',  brand: 'Rick Owens',  price: 890,  category: ShopCategory.menswear),
  ShopProductModel(id: 'm2',  brand: 'Off-White',   price: 560,  category: ShopCategory.menswear),
  ShopProductModel(id: 'm3',  brand: 'Palm Angels', price: 320,  category: ShopCategory.menswear, originalPrice: 450),
    ShopProductModel(id: 'm1',  brand: 'Rick Owens',  price: 890,  category: ShopCategory.menswear),
  ShopProductModel(id: 'm2',  brand: 'Off-White',   price: 560,  category: ShopCategory.menswear),
  ShopProductModel(id: 'm3',  brand: 'Palm Angels', price: 320,  category: ShopCategory.menswear, originalPrice: 450),
  ShopProductModel(id: 'm3',  brand: 'Palm Angels', price: 320,  category: ShopCategory.menswear, originalPrice: 450),
  ShopProductModel(id: 'e1',  brand: 'Jacquemus',   price: 180,  category: ShopCategory.everythingElse),
  ShopProductModel(id: 'e2',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.everythingElse),
    ShopProductModel(id: 'e1',  brand: 'Jacquemus',   price: 180,  category: ShopCategory.everythingElse),
  ShopProductModel(id: 'e2',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.everythingElse),
    ShopProductModel(id: 'e1',  brand: 'Jacquemus',   price: 180,  category: ShopCategory.everythingElse),
  ShopProductModel(id: 'e2',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.everythingElse),
];