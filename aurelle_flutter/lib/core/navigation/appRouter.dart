import 'package:aurelle_flutter/config/appshell.dart';
import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/navigation/pageTransition.dart';
import 'package:aurelle_flutter/features/screens/QA.dart';
import 'package:aurelle_flutter/features/screens/authScreen/Login.dart';
import 'package:aurelle_flutter/features/screens/authScreen/Signup.dart';
import 'package:aurelle_flutter/features/screens/cart.dart';
import 'package:aurelle_flutter/features/screens/category.dart';
import 'package:aurelle_flutter/features/screens/homescreen.dart';
import 'package:aurelle_flutter/features/screens/oder.dart';
import 'package:aurelle_flutter/features/screens/onboarding.dart';
import 'package:aurelle_flutter/features/screens/product.dart';
import 'package:aurelle_flutter/features/screens/profile.dart';
import 'package:aurelle_flutter/features/screens/setting.dart';
import 'package:aurelle_flutter/features/screens/shop.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' hide NoTransitionPage;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../shell/app_shell.dart';
// import '../shell/page_transitions.dart';
// import '../features/auth/screens/splash_screen.dart';
// import '../features/auth/screens/onboarding_screen.dart';
// import '../features/auth/screens/login_screen.dart';
// import '../features/auth/screens/signup_screen.dart';
// import '../features/home/screens/home_screen.dart';
// import '../features/shop/screens/shop_screen.dart';
// import '../features/shop/screens/product_detail_screen.dart';
// import '../features/shop/screens/category_screen.dart';
// import '../features/cart/screens/cart_screen.dart';
// import '../features/profile/screens/profile_screen.dart';
// import '../features/profile/screens/orders_screen.dart';
// import '../features/profile/screens/order_detail_screen.dart';
// import '../features/profile/screens/settings_screen.dart';
// import '../features/profile/screens/qa_screen.dart';
// import 'app_routes.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
/// Expose the router as a Riverpod provider so it can be refreshed
/// (e.g. on auth-state change) without rebuilding the widget tree.
final routerProvider = Provider<GoRouter>((ref) {
  // 🔁 Swap this with your real auth provider when ready.
  // final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true, // disable in prod
    // refreshListenable: GoRouterRefreshStream(auth.stream),

    // ── Global redirect ─────────────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      // Example auth-guard skeleton:
      // final isLoggedIn = auth.isLoggedIn;
      // final goingToAuth = state.matchedLocation.startsWith('/login') ||
      //     state.matchedLocation == AppRoutes.splash ||
      //     state.matchedLocation == AppRoutes.onboarding;
      // if (!isLoggedIn && !goingToAuth) return AppRoutes.login;
      // if (isLoggedIn && goingToAuth) return AppRoutes.home;
      return null; // no redirect
    },

    routes: [
      // ── Splash ──────────────────────────────────────────────────────────
  

      // ── Onboarding ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => SlideUpTransitionPage(
            key: state.pageKey, child: const OnboardingScreen()),
      ),

      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => FadeTransitionPage(
            key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => SlideUpTransitionPage(
            key: state.pageKey, child: const SignUpScreen()),
      ),

      // ── Shell (tabs) ────────────────────────────────────────────────────
      ShellRoute(
        // AppShell is the persistent Scaffold that hosts the bottom nav
        // and swaps only the body via the `child` argument.
        builder: (context, state, child) => AppShell(child: child),

        routes: [
          // ── Home ──────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const Homescreen(),
            ),
          ),

          // ── Shop (with nested routes) ─────────────────────────────────
          GoRoute(
            path: AppRoutes.shop,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ShopScreen(),
            ),
            routes: [
              // /shop/product/:productId
              GoRoute(
                path: AppRoutes.productDetail,
                pageBuilder: (context, state) {
                  final productId = state.pathParameters['productId']!;
                  return SlideRightTransitionPage(
                    key: state.pageKey,
                    child: ProductDetailScreen(productId: productId),
                  );
                },
              ),

              // /shop/category/:categorySlug
              GoRoute(
                path: AppRoutes.category,
                pageBuilder: (context, state) {
                  final slug = state.pathParameters['categorySlug']!;
                  return SlideRightTransitionPage(
                    key: state.pageKey,
                    child: CategoryScreen(categorySlug: slug),
                  );
                },
              ),
            ],
          ),

          // ── Cart ──────────────────────────────────────────────────────
          GoRoute(
            path: AppRoutes.cart,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CartScreen(),
            ),
          ),

          // ── Profile (with nested routes) ──────────────────────────────
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
            routes: [
              // /profile/orders
              GoRoute(
                path: AppRoutes.orders,
                pageBuilder: (context, state) => SlideRightTransitionPage(
                  key: state.pageKey,
                  child: const OrderScreen(),
                ),
                routes: [
                  // /profile/orders/:orderId
                  // GoRoute(
                  //   path: 'orders/:orderId',
                  //   pageBuilder: (context, state) {
                  //     final orderId = state.pathParameters['orderId']!;
                  //     return SlideRightTransitionPage(
                  //       key: state.pageKey,
                  //       child: OrderDetailScreen(orderId: orderId),
                  //     );
                  //   },
                  // ),
                ],
              ),

              // /profile/settings
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => SlideRightTransitionPage(
                  key: state.pageKey,
                  child: const SettingScreen(),
                ),
              ),

              // /profile/qa
              GoRoute(
                path: AppRoutes.qa,
                pageBuilder: (context, state) => SlideRightTransitionPage(
                  key: state.pageKey,
                  child: const InterviewScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // ── 404 ────────────────────────────────────────────────────────────────
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    ),
  );
});