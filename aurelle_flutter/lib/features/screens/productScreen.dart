/// ─────────────────────────────────────────────────────────────────────────────
/// product_detail_screen.dart
///
/// Layout:
///   • Fixed background: full-screen image carousel (PageView)
///   • Right side: vertical image scrubber indicator
///   • Thumbnail strip: horizontal scroll, tap = swap entire variant
///   • DraggableScrollableSheet: peeks from bottom, drag up for full info
///
/// Sheet snap points:
///   • min  = 0.36 → peek (brand, name, price, CTAs visible)
///   • mid  = 0.36 → same as min (no mid snap needed)
///   • max  = 0.92 → full info (share, item code, item info, bullets)
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:aurelle_flutter/features/provider/product_detail_provider.dart';
import 'package:aurelle_flutter/features/provider/search_provider.dart';
import 'package:aurelle_flutter/features/screens/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId, required bool fromReels});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailProvider(productId));
    final notifier = ref.read(productDetailProvider(productId).notifier);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.black,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    final variant = state.activeVariant;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // ── 1. Full-screen image carousel (fixed behind sheet) ──────────
          Positioned.fill(
            child: _ImageCarousel(
              images: variant.images,
              currentIndex: state.selectedImageIndex,
              onPageChanged: notifier.selectImage,
            ),
          ),

          // ── 2. Top bar: BACK · BAG ──────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _TopBar(),
            ),
          ),

          // ── 3. Right scrubber indicator ─────────────────────────────────
          if (variant.images.length > 1)
            Positioned(
              right: 3.w,
              top: 18.h,
              child: _ImageScrubber(
                total: variant.images.length,
                current: state.selectedImageIndex,
              ),
            ),

          // ── 4. DraggableScrollableSheet ─────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.38,
            maxChildSize: 0.93,
            snap: true,
            snapSizes: const [0.38, 0.93],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // ── Drag handle ─────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 1.2.h),
                          width: 10.w,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    // ── Thumbnail strip ─────────────────────────────────
                    SliverToBoxAdapter(
                      child: _ThumbnailStrip(
                        variants: state.variants,
                        selectedIndex: state.selectedVariantIndex,
                        onTap: notifier.selectVariant,
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                    // ── Brand + name + price ─────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _ProductInfo(variant: variant),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                    // ── CTA buttons ──────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _CTARow(
                          isInWishlist: state.isInWishlist,
                          onAddToBag: () {
                            // 🔁 Wire to cart provider
                          },
                          onWishlist: notifier.toggleWishlist,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                    // ── Divider ──────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        height: 0.5,
                        color: AppColors.divider,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                    // ── Share item ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _ShareRow(
                          itemCode: variant.itemCode ?? '',
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 2.5.h)),

                    // ── Item info ────────────────────────────────────────
                    if (variant.itemInfo != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: _ItemInfo(info: variant.itemInfo!),
                        ),
                      ),

                    if (variant.supplierColor != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
                          child: _SupplierColor(color: variant.supplierColor!),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 4.h)),

           SliverToBoxAdapter(child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Padding(
                                       padding: EdgeInsets.symmetric(horizontal: 4.w),
                                       child: Text(
                                         'RECENTLY VIEWED',
                                         style: textTheme.titleSmall?.copyWith(
                                           fontSize: 10.sp,
                                           letterSpacing: 1.4,
                                         ),
                                       ),
                                     ),
                           
                                     SizedBox(height: 1.5.h),
                           
                                     // ── Recently viewed horizontal scroll ───────────────────────
                                     SizedBox(
                                       height: (40.w * 1.35) + 6.h,
                                       child: ListView.separated(
                                         scrollDirection: Axis.horizontal,
                                         padding: EdgeInsets.symmetric(horizontal: 4.w),
                                         itemCount: mockRecentlyViewed.length,
                                         separatorBuilder: (_, __) => SizedBox(width: 3.w),
                                         itemBuilder: (context, i) {
                                           final p = mockRecentlyViewed[i];
                                           return MiniProductCard(product: p);
                                         },
                                       ),
                                     ),
                         ],
                       ),),

                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.labelLarge?.copyWith(
      fontSize: 11.sp,
      letterSpacing: 1.4,
    );
    return SizedBox(
      height: 6.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Text('BACK', style: style),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen image carousel
// ─────────────────────────────────────────────────────────────────────────────
class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.productPlaceholder,
        child: Center(
          child: Icon(
            Icons.person_outline,
            size: 60,
            color: AppColors.lightTextSecondary.withOpacity(0.2),
          ),
        ),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, i) => Image.network(
        images[i],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.productPlaceholder,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical image scrubber (right side indicator)
// ─────────────────────────────────────────────────────────────────────────────
class _ImageScrubber extends StatelessWidget {
  const _ImageScrubber({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return Container(
          width: isActive ? 1.5 : 1,
          height: isActive ? 5.h : 3.h,
          margin: EdgeInsets.symmetric(vertical: 0.4.h),
          color: isActive
              ? AppColors.lightTextPrimary
              : AppColors.lightTextSecondary.withOpacity(0.4),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Thumbnail strip — tapping swaps entire variant
// ─────────────────────────────────────────────────────────────────────────────
class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({
    required this.variants,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<ProductVariant> variants;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 11.w + 1, // thumbnail size + border
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: variants.length,
        separatorBuilder: (_, _) => SizedBox(width: 2.w),
        itemBuilder: (context, i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                color: AppColors.productPlaceholder,
                border: Border.all(
                  color: isSelected
                      ? AppColors.lightTextPrimary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: variants[i].thumbnailUrl != null
                  ? Image.network(
                      variants[i].thumbnailUrl!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 14,
                        color:
                            AppColors.lightTextSecondary.withOpacity(0.3),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product info block
// ─────────────────────────────────────────────────────────────────────────────
class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.variant});
  final ProductVariant variant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand — underlined
        Text(
          variant.brand,
          style: textTheme.labelLarge?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.lightTextPrimary,
            color: AppColors.lightTextPrimary,
          ),
        ),

        SizedBox(height: 0.5.h),

        // Product name
        Text(
          variant.productName,
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.lightTextPrimary,
          ),
        ),

        SizedBox(height: 0.8.h),

        // Price row
        Row(
          children: [
            Text(
              '\$${variant.price.toStringAsFixed(0)} USD',
              style: textTheme.labelLarge?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            if (variant.originalPrice != null) ...[
              SizedBox(width: 2.w),
              Text(
                '\$${variant.originalPrice!.toStringAsFixed(0)} USD',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.priceStrike,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.priceStrike,
                ),
              ),
              SizedBox(width: 2.w),
              if (variant.salePercent != null)
                Text(
                  '${variant.salePercent}% OFF',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFCC0000), // sale red
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA buttons — ADD TO BAG + ADD TO WISHLIST
// ─────────────────────────────────────────────────────────────────────────────
class _CTARow extends StatelessWidget {
  const _CTARow({
    required this.isInWishlist,
    required this.onAddToBag,
    required this.onWishlist,
  });

  final bool isInWishlist;
  final VoidCallback onAddToBag;
  final VoidCallback onWishlist;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // ADD TO BAG — solid black
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: onAddToBag,
            child: Container(
              height: 6.h,
              color: AppColors.black,
              alignment: Alignment.center,
              child: Text(
                'ADD TO BAG',
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 3.w),

        // ADD TO WISHLIST — text only
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: onWishlist,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 6.h,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isInWishlist ? 'SAVED ♥' : 'ADD TO WISHLIST',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                    color: isInWishlist
                        ? AppColors.gold
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Share item row
// ─────────────────────────────────────────────────────────────────────────────
class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.itemCode});
  final String itemCode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {}, // 🔁 Wire to share
          child: Text(
            'SHARE ITEM',
            style: textTheme.labelLarge?.copyWith(
              fontSize: 11.sp,
              letterSpacing: 1.2,
              color: AppColors.lightTextSecondary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.lightTextSecondary,
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          itemCode,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 11.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item info block
// ─────────────────────────────────────────────────────────────────────────────
class _ItemInfo extends StatelessWidget {
  const _ItemInfo({required this.info});
  final String info;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ITEM INFO',
          style: textTheme.labelLarge?.copyWith(
            fontSize: 11.sp,
            letterSpacing: 1.2,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          info,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 11.sp,
            color: AppColors.lightTextSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supplier color
// ─────────────────────────────────────────────────────────────────────────────
class _SupplierColor extends StatelessWidget {
  const _SupplierColor({required this.color});
  final String color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      'Supplier color: $color',
      style: textTheme.bodyMedium?.copyWith(
        fontSize: 11.sp,
        color: AppColors.lightTextSecondary,
      ),
    );
  }
}