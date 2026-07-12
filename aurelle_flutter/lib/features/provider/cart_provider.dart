/// ─────────────────────────────────────────────────────────────────────────────
/// cart_provider.dart
/// Stub implementation — swap fetch calls for real API calls when backend
/// is wired. Shape is identical to shop_provider / home_provider so the
/// pattern stays consistent across all screens.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/cart_model.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);

    // 🔁 Replace with: final items = await CartRepository.fetchCart();
    await Future.delayed(const Duration(milliseconds: 900));

    state = state.copyWith(
      isLoading: false,
      items: const [
        CartItemModel(
          id: '1',
          brand: 'Aurellian',
          productName: 'Khaki Total 90 Shox Magia Sneakers',
          size: 'Size US 6',
          imageUrl: 'assets/images/shop/shop1.png',
          price: 145.00,
          isLowStock: true,
        ),
        CartItemModel(
          id: '2',
          brand: 'MARINE SERRE',
          productName: 'SSENSE Exclusive Black Moon Printed Jersey Biker...',
          size: 'Size XS',
          imageUrl: 'assets/images/shop/shop11.png',
          price: 207.00,
          originalPrice: 230.00,
          discountPercent: 10,
        ),
        CartItemModel(
          id: '3',
          brand: 'YMC',
          productName: 'Green Atomic Cardigan',
          size: 'Size L',
          imageUrl: 'assets/images/shop/trnd.png',
          price: 195.00,
          originalPrice: 325.00,
          discountPercent: 40,
          isLowStock: true,
        ),
         CartItemModel(
          id: '4',
          brand: 'YMC',
          productName: 'Green Atomic Cardigan',
          size: 'Size L',
          imageUrl: 'assets/images/shop/trill.png',
          price: 195.00,
          originalPrice: 325.00,
          discountPercent: 40,
          isLowStock: true,
        ),
         CartItemModel(
          id: '5',
          brand: 'YMC',
          productName: 'Green Atomic Cardigan',
          size: 'Size L',
          imageUrl: 'assets/images/shop/shop7.png',
          price: 195.00,
          originalPrice: 325.00,
          discountPercent: 40,
          isLowStock: true,
        ),
      ],
    );
  }

  Future<void> refresh() async => _load();

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
    // 🔁 Also call: await CartRepository.removeItem(id);
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier());