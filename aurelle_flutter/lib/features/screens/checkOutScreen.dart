/// ─────────────────────────────────────────────────────────────────────────────
/// checkout_screen.dart
/// SSENSE-style checkout screen.
///   • BACK · CONTACT US top bar
///   • Large CHECKOUT heading (Cormorant Garamond)
///   • SHIPPING / DELIVERY / PAYMENT info rows with hairline dividers
///   • ITEMS table — same CartItemRow pattern as cart screen
///   • Sticky PLACE ORDER button
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/cart_model.dart';
import 'package:aurelle_flutter/features/provider/address_provider.dart';
import 'package:aurelle_flutter/features/provider/cart_provider.dart';
import 'package:aurelle_flutter/shared/widget/checkOut/shipping_address_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartProvider);
    final address = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            _CheckoutTopBar(),
            _Hairline(),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // CHECKOUT heading
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
                      child: Text(
                        'CHECKOUT',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),

                  _HairlineSliver(),

                  // SHIPPING row
               

                  // DELIVERY row
                  SliverToBoxAdapter(
                    child: _CheckoutInfoRow(
                      label: 'DELIVERY',
                      content:
                          '\$42.00 USD (Express)\nDelivery by Thursday, July 9 – Tuesday, July 14',
                      isPlaceholder: false,
                    ).animate().fadeIn(delay: 140.ms, duration: 300.ms),
                  ),

                  _HairlineSliver(),

                  // PAYMENT row
                  SliverToBoxAdapter(
                    child:ShippingRow(
  address: address,
  onTap: () => context.push('/address/add'),
).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                  ),

                  _HairlineSliver(),
                  SliverToBoxAdapter(child: SizedBox(height: 1.h)),

                  // ITEMS table header
                  SliverToBoxAdapter(
                    child: _ItemsTableHeader(
                      itemCount: state.items.length,
                    ).animate().fadeIn(delay: 260.ms, duration: 300.ms),
                  ),

                  _HairlineSliver(),

                  // Items list — reuses same row pattern as cart screen
                  if (state.isLoading)
                    SliverToBoxAdapter(child: _CheckoutItemsSkeleton())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final item = state.items[i];
                          final delay =
                              Duration(milliseconds: 300 + (80 * i));
                          return _CheckoutItemRow(item: item)
                              .animate()
                              .fadeIn(delay: delay, duration: 350.ms);
                        },
                        childCount: state.items.length,
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 4.h)),
                ],
              ),
            ),

            // ── Sticky PLACE ORDER ─────────────────────────────────────────
            _PlaceOrderButton(
              onTap: () {
                context.push('/payment?total=${state.orderTotal}');
              }, // 🔁 Wire to order confirmation / payment gateway
            ),

       
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _CheckoutTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
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
              onTap: () {

                context.pop();
},
              child: Text('BACK', style: style),
            ),
            GestureDetector(
              onTap: () {}, // 🔁 Wire to contact us
              child: Text('CONTACT US', style: style),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info row — used for SHIPPING / DELIVERY / PAYMENT
// ─────────────────────────────────────────────────────────────────────────────
class _CheckoutInfoRow extends StatelessWidget {
  const _CheckoutInfoRow({
    required this.label,
    required this.content,
    this.isPlaceholder = false,
    this.showChevron = false,
    this.onTap,
  });

  final String label;
  final String content;
  final bool isPlaceholder;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label column — fixed width so all labels align
            SizedBox(
              width: 22.w,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),

            // Content
            Expanded(
              child: Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: isPlaceholder
                      ? AppColors.lightTextSecondary
                      : AppColors.lightTextPrimary,
                  height: 1.5,
                ),
              ),
            ),

            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: AppColors.lightTextSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Items table header — "ITEMS 03  DESCRIPTION  PRICE"
// ─────────────────────────────────────────────────────────────────────────────
class _ItemsTableHeader extends StatelessWidget {
  const _ItemsTableHeader({required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.lightTextSecondary,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          Text(
            'ITEMS ${itemCount.toString().padLeft(2, '0')}',
            style: style,
          ),
          SizedBox(width: 4.w),
          Text('DESCRIPTION', style: style),
          const Spacer(),
          Text('PRICE', style: style),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkout item row — same visual as cart but no swipe-to-dismiss
// ─────────────────────────────────────────────────────────────────────────────
class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 30.w,
                height: 15.h,
                color: AppColors.productPlaceholder,
                child: item.imageUrl != null
                    ? Image.asset(item.imageUrl!, fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          Icons.person_outline,
                          size: 20,
                          color:
                              AppColors.lightTextSecondary.withOpacity(0.3),
                        ),
                      ),
              ),

              SizedBox(width: 3.w),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.brand,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      item.productName,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.lightTextPrimary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.4.h),
                    Row(
                      children: [
                        Text(
                          item.size,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        if (item.isLowStock)
                          Text(
                            '  One Item Left',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                      ],
                    ),
                    if (item.isOnSale) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        '${item.discountPercent}% OFF',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD94F3D),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 2.w),

              // Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  if (item.isOnSale) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      '\$${item.originalPrice!.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
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
        _Hairline(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkout items skeleton
// ─────────────────────────────────────────────────────────────────────────────
class _CheckoutItemsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22.w,
                height: 16.h,
                color: AppColors.productPlaceholder,
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 1200.ms, color: AppColors.lightSurface),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                            height: 1.4.h,
                            width: 28.w,
                            color: AppColors.productPlaceholder)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(
                            duration: 1200.ms, color: AppColors.lightSurface),
                    SizedBox(height: 0.8.h),
                    Container(
                            height: 1.2.h,
                            width: 40.w,
                            color: AppColors.productPlaceholder)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(
                            duration: 1200.ms, color: AppColors.lightSurface),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky place order button
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:  EdgeInsets.all(3.h),
        child: Container(
          width: double.infinity,
          height: 7.h,
          color: AppColors.black,
          alignment: Alignment.center,
          child: Text(
            'PLACE ORDER',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
class _Hairline extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: AppColors.divider);
}

class _HairlineSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: _Hairline());
}