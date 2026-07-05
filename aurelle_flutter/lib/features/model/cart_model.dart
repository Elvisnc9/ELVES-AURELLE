/// ─────────────────────────────────────────────────────────────────────────────
/// cart_model.dart
/// ─────────────────────────────────────────────────────────────────────────────

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.brand,
    required this.productName,
    required this.size,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.isLowStock = false,
  });

  final String id;
  final String brand;
  final String productName;
  final String size;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final bool isLowStock;

  bool get isOnSale =>
      originalPrice != null && originalPrice! > price && discountPercent != null;
}

class CartState {
  const CartState({
    this.isLoading = true,
    this.items = const [],
    this.shippingCost = 41.99,
    this.taxes = 0.0,
  });

  final bool isLoading;
  final List<CartItemModel> items;
  final double shippingCost;
  final double taxes;

  bool get isEmpty => !isLoading && items.isEmpty;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price);

  double get orderTotal => subtotal + shippingCost + taxes;

  CartState copyWith({
    bool? isLoading,
    List<CartItemModel>? items,
    double? shippingCost,
    double? taxes,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      shippingCost: shippingCost ?? this.shippingCost,
      taxes: taxes ?? this.taxes,
    );
  }
}