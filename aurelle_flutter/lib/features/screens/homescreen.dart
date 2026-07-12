/// ─────────────────────────────────────────────────────────────────────────────
/// homescreen.dart
/// Changes vs previous version:
///   • HomeAppBar widget removed — top bar now lives inside HeroBanner
///   • SafeArea bottom:false so hero goes edge-to-edge at the top
///   • HeroBanner receives bagCount + callbacks directly
///   • Everything below the hero is UNCHANGED
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/provider/home_provider.dart';
import 'package:aurelle_flutter/shared/widget/Home/brand_list_section.dart';
import 'package:aurelle_flutter/shared/widget/Home/home_banner.dart';
import 'package:aurelle_flutter/shared/widget/Product/product_row_section.dart';
import 'package:aurelle_flutter/shared/widget/Home/recently_viewed_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class Homescreen extends ConsumerWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // No SafeArea — hero goes fully behind the status bar for the
      // full-bleed effect. HeroBanner reads MediaQuery.padding.top
      // internally to offset its floating icons below the status bar.
      body: RefreshIndicator(
        color: AppColors.black,
        strokeWidth: 2.5,
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [

            // ── 1. Hero Banner (contains floating app bar) ─────────────
            SliverToBoxAdapter(
              child: state.isLoading
                  ? _HeroSkeleton()
                  : HeroBanner(
                      banner: state.heroBanner,
                      bagCount: state.bagCount,
                      onProfileTap: () {
                        // 🔁 Wire to: context.push(AppRoutes.profile)
                      },
                      onSearchTap: () {
                       context.push(AppRoutes.search);
                      },
                      onBagTap: () {
                       context.push(AppRoutes.cart);
                      },
                      onShopNowTap: () {
                        // 🔁 Wire to: context.push(AppRoutes.shop)
                        context.go(AppRoutes.shop);
                      },
                    ),
            ),



            

            // ── 2. Brand list section ──────────────────────────────────
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

            // ── 3. Recently Viewed ─────────────────────────────────────
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

            // ── 4. Curated product sections ────────────────────────────
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

            SliverToBoxAdapter(child: SizedBox(height: 4.h)),
          ],
        ),
      ),
    );
  }
}

// ── Skeletons (unchanged) ─────────────────────────────────────────────────────

class _HeroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.h,
      color: AppColors.productPlaceholder,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1200.ms, color: AppColors.lightSurface);
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
          Container(height: 2.h, width: 40.w, color: AppColors.productPlaceholder),
          SizedBox(height: 1.5.h),
          Container(height: height, width: double.infinity, color: AppColors.productPlaceholder),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1200.ms, color: AppColors.lightSurface);
  }
}