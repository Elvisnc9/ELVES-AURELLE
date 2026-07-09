abstract class AppRoutes {
  // ── Pre-shell ──────────────────────────────────────────────────────────────
  static const String splash      = '/splash';
  static const String onboarding  = '/onboarding';
  static const String login       = '/login';
  static const String signup      = '/signup';
  static const String search      = '/search';
  static const String cart        = '/cart';
  static const String checkout    = '/checkout';
  static const String addAddress  = '/address/add';
  static const String payment     = '/payment';

  // ── Product detail — top-level, no shell, no bottom nav ───────────────────
  static const String productDetail = '/shop/product/:productId';

  // ── Shell tabs ─────────────────────────────────────────────────────────────
  static const String home    = '/home';
  static const String shop    = '/shop';
  static const String reels   = '/reels';
  static const String profile = '/profile';

  // ── Nested: Shop ──────────────────────────────────────────────────────────
  static const String category = 'category/:categorySlug'; // relative

  // ── Nested: Profile ───────────────────────────────────────────────────────
  static const String orders    = 'orders';           // relative
  static const String orderDetail = 'orders/:orderId'; // relative
  static const String settings  = 'settings';         // relative
  static const String qa        = 'qa';               // relative

  // ── Helpers ────────────────────────────────────────────────────────────────
  /// Single helper — used by both Shop grid and Reels overlay
  static String productPath(String productId) => '/shop/product/$productId';
  static String categoryPath(String slug)     => '/shop/category/$slug';
  static String orderDetailPath(String id)    => '/profile/orders/$id';
}