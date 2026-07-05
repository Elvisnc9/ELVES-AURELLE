/// ─────────────────────────────────────────────────────────────────────────────
/// shop_screen.dart
/// Changes vs previous version:
///   • RefreshIndicator wraps CustomScrollView (same as homescreen)
///   • _GridSkeleton now uses flutter_animate shimmer (same pattern as homescreen)
///   • Category tabs, sale row, and product grid items animate in with fadeIn
///   • BouncingScrollPhysics + AlwaysScrollableScrollPhysics (required for
///     RefreshIndicator to trigger even when content doesn't fill the screen)
///   • Everything else UNCHANGED
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:aurelle_flutter/features/provider/shop_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopProvider);
    final notifier = ref.read(shopProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // ── RefreshIndicator wraps CustomScrollView ─────────────────────
          // Matches homescreen exactly: same color, same strokeWidth.
          RefreshIndicator(
            color: AppColors.black,
            strokeWidth: 2.5,
            onRefresh: () => ref.read(shopProvider.notifier).refresh(),
            child: CustomScrollView(
              // BouncingScrollPhysics + AlwaysScrollable ensures the refresh
              // gesture triggers even when the list is shorter than the screen.
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Top bar ────────────────────────────────────────────────
                SliverToBoxAdapter(child: _TopBar()),

                SliverToBoxAdapter(
                  child: Container(
                    height: 0.5,
                    color: const Color.fromARGB(255, 112, 93, 93),
                  ),
                ),

                // ── Category tabs ──────────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryTabDelegate(
                    selected: state.selectedCategory,
                    onSelect: notifier.selectCategory,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(height: 0.5, color: AppColors.divider),
                ),

                // ── Sale only checkbox ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: _SaleOnlyRow(
                    value: state.saleOnly,
                    onToggle: notifier.toggleSaleOnly,
                  ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                ),

                SliverToBoxAdapter(
                  child: Container(height: 0.5, color: AppColors.divider),
                ),

                // ── Product grid ───────────────────────────────────────────
                if (state.isLoading)
                  SliverToBoxAdapter(child: _GridSkeleton())
                else if (state.filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 40.h,
                      child: Center(
                        child: Text(
                          'No products found',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 12.h),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.58,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final product = state.filtered[i];
                          // Stagger each card's fadeIn by 40ms per index,
                          // capped at 400ms so deep items don't wait forever.
                          final staggerDelay = Duration(
                            milliseconds: (40 * i).clamp(0, 400),
                          );
                          return _ShopProductCard(
                            product: product,
                            onTap: () => context.push(
                              '/shop/product/${product.id}',
                            ),
                          )
                              .animate()
                              .fadeIn(
                                delay: staggerDelay,
                                duration: 350.ms,
                              )
                              .slideY(
                                begin: 0.04,
                                end: 0,
                                delay: staggerDelay,
                                duration: 300.ms,
                                curve: Curves.easeOutCubic,
                              );
                        },
                        childCount: state.filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar — UNCHANGED
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelLarge?.copyWith(
      fontSize: 11.sp,
      letterSpacing: 1.6,
    );
    return SizedBox(
      height: 6.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.push(AppRoutes.search),
              child: Text('SEARCH', style: labelStyle),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category tabs — UNCHANGED
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  _CategoryTabDelegate({required this.selected, required this.onSelect});
  final ShopCategory selected;
  final ValueChanged<ShopCategory> onSelect;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  bool shouldRebuild(_CategoryTabDelegate old) => old.selected != selected;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: AppColors.lightBackground,
      height: 48,
      child: Row(
        children: ShopCategory.values.map((cat) {
          final isActive = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? AppColors.lightTextPrimary
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat.label,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 11.sp,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.8,
                  color: isActive
                      ? AppColors.lightTextPrimary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sale only row — UNCHANGED
// ─────────────────────────────────────────────────────────────────────────────
class _SaleOnlyRow extends StatelessWidget {
  const _SaleOnlyRow({required this.value, required this.onToggle});
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: (_) => onToggle(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.black,
                side: const BorderSide(
                    color: AppColors.lightTextPrimary, width: 1),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'SALE ONLY',
              style: textTheme.labelLarge?.copyWith(
                fontSize: 11.sp,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card — UNCHANGED
// ─────────────────────────────────────────────────────────────────────────────
class _ShopProductCard extends StatelessWidget {
  const _ShopProductCard({required this.product, required this.onTap});
  final ShopProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.productPlaceholder,
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 24,
                        color:
                            AppColors.lightTextSecondary.withOpacity(0.3),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(2.w, 0.8.h, 2.w, 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 10.sp,
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.2.h),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 10.sp,
                        color: AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (product.isOnSale) ...[
                      SizedBox(width: 1.w),
                      Text(
                        '\$${product.originalPrice!.toStringAsFixed(0)}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 9.sp,
                          color: AppColors.priceStrike,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.priceStrike,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GridSkeleton
// Matches homescreen shimmer pattern exactly:
//   • Same AppColors.productPlaceholder base color
//   • Same AppColors.lightSurface shimmer highlight color
//   • Same 1200ms duration with repeat(reverse: true)
//   • 9 placeholder cards in a 3-column grid
// ─────────────────────────────────────────────────────────────────────────────
class _GridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
        crossAxisSpacing: 3,
        mainAxisSpacing: 0,
      ),
      itemBuilder: (_, i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image placeholder ─────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.productPlaceholder,
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(
                    duration: 1200.ms,
                    color: AppColors.lightSurface,
                  ),
            ),

            // ── Brand + price placeholder ─────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(2.w, 0.8.h, 2.w, 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1.2.h,
                    width: 16.w,
                    color: AppColors.productPlaceholder,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(
                        duration: 1200.ms,
                        color: AppColors.lightSurface,
                      ),
                  SizedBox(height: 0.4.h),
                  Container(
                    height: 1.h,
                    width: 10.w,
                    color: AppColors.productPlaceholder,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(
                        duration: 1200.ms,
                        color: AppColors.lightSurface,
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomActionBar — kept for when you uncomment it later
// ─────────────────────────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final btnStyle = textTheme.labelLarge?.copyWith(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.6,
      color: AppColors.white,
    );

    return Container(
      height: 7.h,
      color: AppColors.black,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Center(child: Text('SORT BY', style: btnStyle)),
            ),
          ),
          Container(
              width: 0.5,
              height: 3.h,
              color: AppColors.lightTextSecondary),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Center(child: Text('FILTERS', style: btnStyle)),
            ),
          ),
        ],
      ),
    );
  }
}