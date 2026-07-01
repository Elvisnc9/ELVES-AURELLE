/// ─────────────────────────────────────────────────────────────────────────────
/// homescreen.dart
/// Aurelle Home Screen — SSENSE-style editorial layout.
///
/// Layout (top → bottom, all in a single CustomScrollView):
///   1. HomeAppBar          (SEARCH · BAG 01)
///   2. HeroBanner          (full-bleed black, bold headline)
///   3. BrandListSection    (stacked brand names)
///   4. RecentlyViewedSection
///   5. ProductRowSection × N  (repeating curated sections)
///
/// Rules followed:
///   ✅ Zero logic — all state from homeProvider via ref.watch
///   ✅ All colours from AppColors
///   ✅ All sizing via the_responsive_builder (.w / .h / .sp)
///   ✅ Text styles from Theme.of(context).textTheme
///   ✅ flutter_animate for subtle entrance animations
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/provider/home_provider.dart';
import 'package:aurelle_flutter/shared/widget/Home/brand_list_section.dart';
import 'package:aurelle_flutter/shared/widget/Home/home_appbar.dart';
import 'package:aurelle_flutter/shared/widget/Home/home_banner.dart';
import 'package:aurelle_flutter/shared/widget/Home/product_row_section.dart';
import 'package:aurelle_flutter/shared/widget/Home/recently_viewed_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class Homescreen extends ConsumerWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      // ── Custom AppBar (not a real AppBar — lives in scroll) ───────────────
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.black,
          strokeWidth: 1.5,
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── 1. App Bar ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: HomeAppBar(
                  bagCount: state.bagCount,
                  // Navigation callbacks are wired by the parent shell /
                  // router — passed down here as no-ops until connected.
                  onSearchTap: () {},
                  onBagTap: () {},
                ).animate().fadeIn(duration: 300.ms),
              ),

              // ── Hairline below app bar ─────────────────────────────────
              SliverToBoxAdapter(
                child: Container(height: 0.5, color: AppColors.divider),
              ),

              // ── 2. Hero Banner ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: state.isLoading
                    ? _HeroSkeleton()
                    : HeroBanner(banner: state.heroBanner),
              ),

              // ── 3. Brand list section ──────────────────────────────────
              SliverToBoxAdapter(
                child: state.isLoading
                    ? _SectionSkeleton(height: 32.h)
                    : BrandListSection(
                        section: state.brandSection,
                        onBrandTap: (_) {
                          // 🔁 Wire to: context.push(AppRoutes.brandDetail(brand))
                        },
                        onHeaderTap: () {
                          // 🔁 Wire to: context.push(AppRoutes.shop)
                        },
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 2.h)),

              // ── 4. Recently Viewed ─────────────────────────────────────
              SliverToBoxAdapter(
                child: state.isLoading
                    ? _SectionSkeleton(height: 55.h)
                    : RecentlyViewedSection(
                        products: state.recentlyViewed,
                        onProductTap: (_) {
                          // 🔁 Wire to: context.push(AppRoutes.productDetail(p.id))
                        },
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),

              // ── 5. Curated product sections ────────────────────────────
              if (!state.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = state.productSections[index];
                      return ProductRowSection(
                        section: section,
                        onProductTap: (_) {
                          // 🔁 Wire to: context.push(AppRoutes.productDetail(p.id))
                        },
                        onHeaderTap: () {
                          // 🔁 Wire to: context.push(AppRoutes.category(section.sectionLabel))
                        },
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 350 + (index * 80)),
                            duration: 400.ms,
                          );
                    },
                    childCount: state.productSections.length,
                  ),
                ),

              // ── Loading skeleton for product sections ──────────────────
              if (state.isLoading)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _SectionSkeleton(height: 55.h),
                      SizedBox(height: 2.h),
                      _SectionSkeleton(height: 55.h),
                    ],
                  ),
                ),

              // ── Bottom padding (clear of nav bar) ──────────────────────
              SliverToBoxAdapter(child: SizedBox(height: 4.h)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton loaders — shown while isLoading = true
// Minimal shimmer-free: just grey boxes matching section proportions
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45.h,
      color: AppColors.productPlaceholder,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 1200.ms,
          color: AppColors.lightSurface,
        );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            height: 2.h,
            width: 40.w,
            color: AppColors.productPlaceholder,
          ),
          SizedBox(height: 1.5.h),
          // Content skeleton
          Container(
            height: height,
            width: double.infinity,
            color: AppColors.productPlaceholder,
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 1200.ms,
          color: AppColors.lightSurface,
        );
  }
}