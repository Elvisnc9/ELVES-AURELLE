import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Custom Page Transitions
// Luxury apps use restrained, fast transitions — no over-animated slides.
// Each transition class wraps CustomTransitionPage for clean semantics.
// ─────────────────────────────────────────────────────────────────────────────

/// No animation — used for tab switches inside the shell.
/// Instant swap feels native on bottom-nav taps.
class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({required super.key, required super.child})
      : super(
          transitionsBuilder: _build,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );

  static Widget _build(_, _, _, Widget child) => child;
}

/// Fade — used for splash / auth screens. Soft and premium.
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({required super.key, required super.child})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        );
}

/// Slide from right — used for detail / nested pages (product, order, etc.).
/// Mirrors the iOS "push" feel without the heavy spring physics.
class SlideRightTransitionPage<T> extends CustomTransitionPage<T> {
  SlideRightTransitionPage({required super.key, required super.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));

            // Subtle fade on the outgoing page for depth
            final fadeOut = Tween<double>(begin: 1.0, end: 0.92)
                .chain(CurveTween(curve: curve))
                .animate(secondaryAnimation);

            return FadeTransition(
              opacity: fadeOut,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        );
}

/// Slide from bottom — used for modal-like screens (onboarding, quick views).
class SlideUpTransitionPage<T> extends CustomTransitionPage<T> {
  SlideUpTransitionPage({required super.key, required super.child})
      : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;

            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeOutQuart));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}