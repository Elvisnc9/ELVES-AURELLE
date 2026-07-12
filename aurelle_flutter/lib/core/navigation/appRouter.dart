import 'package:aurelle_flutter/config/appshell.dart';
import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/navigation/pageTransition.dart';
import 'package:aurelle_flutter/features/screens/QA.dart';
import 'package:aurelle_flutter/features/screens/address_screen.dart';
import 'package:aurelle_flutter/features/screens/authScreen/Login.dart';
import 'package:aurelle_flutter/features/screens/cartScreen.dart';
import 'package:aurelle_flutter/features/screens/category.dart';
import 'package:aurelle_flutter/features/screens/homescreen.dart';
import 'package:aurelle_flutter/features/screens/checkOutScreen.dart';
import 'package:aurelle_flutter/features/screens/onboarding.dart';
import 'package:aurelle_flutter/features/screens/payScreen.dart';
import 'package:aurelle_flutter/features/screens/productScreen.dart';
import 'package:aurelle_flutter/features/screens/profile.dart';
import 'package:aurelle_flutter/features/screens/reelScreen.dart';
import 'package:aurelle_flutter/features/screens/searchScreen.dart';
import 'package:aurelle_flutter/features/screens/setting.dart';
import 'package:aurelle_flutter/features/screens/shopScreen.dart';
import 'package:aurelle_flutter/features/screens/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart' hide NoTransitionPage;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) => null,

    routes: [

      // ── Pre-shell screens ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => SlideUpTransitionPage(
            key: state.pageKey, child: const SplashScreen()),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => FadeTransitionPage(
            key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey, child: const SearchScreen()),
      ),
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey, child: const CartScreen()),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) => SlideUpTransitionPage(
            key: state.pageKey, child: const CheckoutScreen()),
      ),
      GoRoute(
  path: '/address/add',
  pageBuilder: (context, state) => SlideRightTransitionPage(
    key: state.pageKey,
    child: const AddAddressScreen(),
  ),
),
      GoRoute(
  path: '/payment',
  pageBuilder: (context, state) {
    final total = double.tryParse(
      state.uri.queryParameters['total'] ?? '0') ?? 0;
    return SlideUpTransitionPage(
      key: state.pageKey,
      child: PaymentScreen(orderTotal: total),
    );
  },
),

      // ── Product detail — outside ShellRoute so NO bottom nav bar shows ─────
      // Both the Shop grid and the Reels "View Product" button push this same
      // route via AppRoutes.productPath(id). One screen, one route, always.
      GoRoute(
        path: AppRoutes.productDetail,
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: productId, ),
          );
        },
      ),

      // ── Shell (tabs with persistent bottom nav) ────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [

          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey, child: const Homescreen()),
          ),

          GoRoute(
            path: AppRoutes.shop,
            pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey, child: const ShopScreen()),
            routes: [
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

          

          GoRoute(
            path: AppRoutes.reels,
            pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey, child: const ReelsScreen()),
          ),

          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey, child: const ProfileScreen()),
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                pageBuilder: (context, state) => SlideRightTransitionPage(
                    key: state.pageKey, child: const CheckoutScreen()),
              ),
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => SlideRightTransitionPage(
                    key: state.pageKey, child: const SettingScreen()),
              ),
              GoRoute(
                path: AppRoutes.qa,
                pageBuilder: (context, state) => SlideRightTransitionPage(
                    key: state.pageKey, child: const InterviewScreen()),
              ),
            ],
          ),

        ],
      ),
    ],

    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    ),
  );
});