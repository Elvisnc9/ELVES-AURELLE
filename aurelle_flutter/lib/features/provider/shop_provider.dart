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
    ShopProductModel(id: 'w9',  brand: 'Rick Owens',  price: 1405, category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop8.png'),
  ShopProductModel(id: 'w1',  brand: 'Rick Owens',  price: 1710, category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/wool_red1.png'),
  ShopProductModel(id: 'w2',  brand: 'Rick Owens',  price: 1070, category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop.png'),
  ShopProductModel(id: 'w3',  brand: 'Rick Owens',  price: 2950, category: ShopCategory.womenswear, imageUrl:'assets/images/shop/shop1.png'),
  ShopProductModel(id: 'w4',  brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580, imageUrl: 'assets/images/shop/shop3.png'),
  ShopProductModel(id: 'w5',  brand: 'Marine Serre',price: 305,  category: ShopCategory.womenswear, originalPrice: 490, imageUrl: 'assets/images/shop/shop4.png'),
  ShopProductModel(id: 'w6',  brand: 'Rick Owens',  price: 3315, category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop5.png'),
  ShopProductModel(id: 'w7',  brand: 'Rick Owens',  price: 375,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop6.png'),
  ShopProductModel(id: 'w8',  brand: 'Rick Owens',  price: 1405, category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop7.png'),
  ShopProductModel(id: 'w9',  brand: 'Rick Owens',  price: 1405, category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop8.png'),
  ShopProductModel(id: 'w10', brand: 'Willy Cha.',  price: 275,  category: ShopCategory.womenswear, originalPrice: 420, imageUrl: 'assets/images/shop/shop9.png'),
  ShopProductModel(id: 'w11', brand: 'Ganni',       price: 405,  category: ShopCategory.womenswear, originalPrice: 580, imageUrl: 'assets/images/shop/shop10.png'),
    ShopProductModel(id: 'w12',  brand: 'Rick Owens',  price: 890,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop11.png'),
  ShopProductModel(id: 'w13',  brand: 'Off-White',   price: 560,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/shop12.png'),
    ShopProductModel(id: 'w14',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/trill.png'),
  ShopProductModel(id: 'w15',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/ups.png'),
  ShopProductModel(id: 'w16',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/jeans.png'),
  ShopProductModel(id: 'w17',  brand: 'Jacquemus',   price: 180,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/street.png'),
  ShopProductModel(id: 'w18',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/editors.png'),
    ShopProductModel(id: 'w15',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/dress1.png'),
  ShopProductModel(id: 'w16',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/rom.png'),
  ShopProductModel(id: 'w17',  brand: 'Jacquemus',   price: 180,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/old-school.png'),
  ShopProductModel(id: 'w18',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/red.png'),
    ShopProductModel(id: 'w18',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/new.png'),
      ShopProductModel(id: 'w18',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/style.png'),
        ShopProductModel(id: 'w18',  brand: 'Amina Muaddi',price: 750,  category: ShopCategory.womenswear, imageUrl: 'assets/images/shop/trnd.png'),









];