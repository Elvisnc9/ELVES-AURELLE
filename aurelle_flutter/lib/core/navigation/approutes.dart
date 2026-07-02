/// Central registry of all named routes.
/// Use these constants everywhere — never hard-code path strings.
abstract class AppRoutes {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // ── Shell tabs (root paths) ───────────────────────────────────────────────
  static const String home = '/home';
  static const String shop = '/shop';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String reels = '/reels';

  // ── Nested: Shop ─────────────────────────────────────────────────────────
  static const String productDetail = 'product/:productId'; // relative
  static const String category = 'category/:categorySlug'; // relative

  // ── Nested: Profile ──────────────────────────────────────────────────────
  static const String orders = 'orders'; // relative
  static const String orderDetail = 'orders/:orderId'; // relative
  static const String settings = 'settings'; // relative
  static const String qa = 'qa'; // relative

  // ── Helpers ───────────────────────────────────────────────────────────────
  /// Build an absolute product-detail path ready for context.go()
  static String productPath(String productId) => '/shop/product/$productId';

  /// Build an absolute category path
  static String categoryPath(String slug) => '/shop/category/$slug';

  /// Build an absolute order-detail path
  static String orderDetailPath(String orderId) =>
      '/profile/orders/$orderId';
}