import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:aurelle_flutter/features/provider/product_detail_provider.dart';
import 'package:aurelle_flutter/features/provider/search_provider.dart';
import 'package:aurelle_flutter/features/screens/searchScreen.dart';
import 'package:aurelle_flutter/shared/widget/Product/size_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late final DraggableScrollableController _sheetController;
  late final PageController _pageController;

  // Whether the sheet is slid fully off screen (fullscreen image view)
  bool _isFullscreen = false;

  static const double _peekSheet = 0.58;
  static const double _maxSheet = 0.60;
  // minChildSize must be > 0 — we use AnimatedSlide to fully hide the sheet
  static const double _minSheet = 0.57;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ── Image tap: toggle fullscreen (sheet slides off / back) ────────────────
  void _onImageTap() {
    setState(() => _isFullscreen = !_isFullscreen);

    // When coming back from fullscreen, reset sheet to peek
    if (!_isFullscreen && _sheetController.isAttached) {
      _sheetController.animateTo(
        _peekSheet,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ── Jump carousel to a specific image index ───────────────────────────────
  void _jumpToImage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider(widget.productId));
    final _selectedSizeProvider = StateProvider.family<String?, String>(
      (ref, productId) => null,
    );
    final notifier = ref.read(productDetailProvider(widget.productId).notifier);
    final textTheme = Theme.of(context).textTheme;

    // When variant changes → reset carousel to first image
    ref.listen(productDetailProvider(widget.productId), (prev, next) {
      if (prev?.selectedVariantIndex != next.selectedVariantIndex) {
        _jumpToImage(0);
      }
    });

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

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // ── 1. Full-screen vertical image carousel ────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onTap: _onImageTap,
              behavior: HitTestBehavior.opaque,
              child: _ImageCarousel(
                images: variant.images,
                currentIndex: state.selectedImageIndex,
                pageController: _pageController,
                onPageChanged: (i) {
                  notifier.selectImage(i);
                },
              ),
            ),
          ),

          // ── 2. Top bar ────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _TopBar(isFullscreen: _isFullscreen),
            ),
          ),

          // ── 3. Vertical image scrubber (right side) ───────────────────────
          if (variant.images.length > 1)
            Positioned(
              right: 3.w,
              top: 18.h,
              child: _ImageScrubber(
                total: variant.images.length,
                current: state.selectedImageIndex,
              ),
            ),

          // ── 4. DraggableScrollableSheet ───────────────────────────────────
          // AnimatedSlide moves it off the bottom when fullscreen is active.
          // Tapping the image again slides it back up.
          AnimatedSlide(
            offset: _isFullscreen ? const Offset(0, 1) : Offset.zero,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: _peekSheet,
              minChildSize: _minSheet,
              maxChildSize: _maxSheet,
              snap: true,
              snapSizes: const [_peekSheet, _maxSheet],
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      // Drag handle
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

                      // ── Thumbnail strip ────────────────────────────────
                      // Tapping a thumbnail:
                      //   1. Switches the active variant
                      //   2. Carousel listener above resets to image 0
                      SliverToBoxAdapter(
                        child: _ThumbnailStrip(
                          variants: state.variants,
                          selectedIndex: state.selectedVariantIndex,
                          onTap: (i) {
                            notifier.selectVariant(i);
                            // Jump is handled by ref.listen above
                          },
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                      // Brand + name + price
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: _ProductInfo(
                            variant: variant,
                            productId: widget.productId,
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 1.5.h)),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: SizeSelector(productId: widget.productId),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 0.5.h)),

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
                            child: _SupplierColor(
                              color: variant.supplierColor!,
                            ),
                          ),
                        ),
                      // CTA row
                      SliverToBoxAdapter(child: SizedBox(height: 2.h)),
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

                      SliverToBoxAdapter(child: SizedBox(height: 5.h)),

                      // // Divider
                      // SliverToBoxAdapter(
                      //   child: Container(
                      //     height: 0.5,
                      //     color: AppColors.divider,
                      //     margin: EdgeInsets.symmetric(horizontal: 4.w),
                      //   ),
                      // ),

                      // Share
                      // SliverToBoxAdapter(
                      //   child: Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: 4.w),
                      //     child: _ShareRow(itemCode: variant.itemCode ?? ''),
                      //   ),
                      // ),

                      // Item info

                      // Recently viewed
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar — hides BACK text in fullscreen so image is truly unobstructed
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.isFullscreen});
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontSize: 11.sp, letterSpacing: 1.4);
    return SizedBox(
      height: 6.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: AnimatedOpacity(
                opacity: isFullscreen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text('BACK', style: style),
              ),
            ),
            // Tap hint — only shows in fullscreen
            AnimatedOpacity(
              opacity: isFullscreen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                'TAP TO CLOSE',
                style: style?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 9.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical image carousel — scrolls UP/DOWN between images
// ─────────────────────────────────────────────────────────────────────────────
class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.images,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
  });

  final List<String> images;
  final int currentIndex;
  final PageController pageController;
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
      controller: pageController,
      scrollDirection: Axis.vertical, // ← vertical scroll
      itemCount: images.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, i) => Image.asset(
        images[i],
        fit: BoxFit.contain,
        alignment: Alignment.topCenter, // model's face/upper body first
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            Container(color: AppColors.productPlaceholder),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unchanged widgets below
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
      height: 11.w + 1,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: variants.length,
        separatorBuilder: (_, __) => SizedBox(width: 2.w),
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
                  ? Image.asset(variants[i].thumbnailUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.lightTextSecondary.withOpacity(0.3),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductInfo extends ConsumerStatefulWidget {
  const _ProductInfo({required this.variant, required this.productId});

  final ProductVariant variant;
  final String productId;

  @override
  ConsumerState<_ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends ConsumerState<_ProductInfo> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isInWishlist = ref
        .watch(productDetailProvider(widget.productId))
        .isInWishlist;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.variant.brand,
          style: t.labelLarge?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.variant.productName,
                style: t.titleMedium?.copyWith(
                  fontSize: 25.sp,
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ref
                  .read(productDetailProvider(widget.productId).notifier)
                  .toggleWishlist(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isInWishlist ? Icons.star : Icons.star_border,
                  key: ValueKey(isInWishlist),
                  color: isInWishlist
                      ? AppColors.gold
                      : AppColors.lightTextSecondary,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.8.h),
        Row(
          children: [
            Text(
              '\$${widget.variant.price.toStringAsFixed(0)} USD',
              style: t.labelLarge?.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.variant.originalPrice != null) ...[
              SizedBox(width: 2.w),
              Text(
                '\$${widget.variant.originalPrice!.toStringAsFixed(0)} USD',
                style: t.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.priceStrike,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 2.w),
              if (widget.variant.salePercent != null)
                Text(
                  '${widget.variant.salePercent}% OFF',
                  style: t.labelLarge?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFCC0000),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

final wishlistProvider =
    StateNotifierProvider.family<WishlistNotifier, bool, String>(
      (ref, productId) => WishlistNotifier(),
    );

class WishlistNotifier extends StateNotifier<bool> {
  WishlistNotifier() : super(false);
  void toggle() => state = !state;
}

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
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
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
                style: t.labelLarge?.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
        // SizedBox(width: 3.w),
        // Expanded(
        //   flex: 5,
        //   child: GestureDetector(
        //     onTap: onWishlist,
        //     behavior: HitTestBehavior.opaque,
        //     child: SizedBox(
        //       height: 6.h,
        //       child: Align(
        //         alignment: Alignment.centerLeft,
        //         child: Text(
        //           isInWishlist ? 'SAVED ♥' : 'ADD TO WISHLIST',
        //           style: t.labelLarge?.copyWith(
        //               fontSize: 10.sp,
        //               fontWeight: FontWeight.w500,
        //               letterSpacing: 0.8,
        //               color: isInWishlist
        //                   ? AppColors.gold
        //                   : AppColors.lightTextPrimary),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class _ItemInfo extends StatelessWidget {
  const _ItemInfo({required this.info});
  final String info;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ITEM INFO',
          style: t.labelLarge?.copyWith(fontSize: 11.sp, letterSpacing: 1.2),
        ),
        SizedBox(height: 1.h),
        Text(
          info,
          style: t.bodyMedium?.copyWith(
            fontSize: 11.sp,
            color: AppColors.lightTextSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _SupplierColor extends StatelessWidget {
  const _SupplierColor({required this.color});
  final String color;
  @override
  Widget build(BuildContext context) {
    return Text(
      'Supplier color: $color',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: 11.sp,
        color: AppColors.lightTextSecondary,
      ),
    );
  }
}
