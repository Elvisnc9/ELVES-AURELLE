/// ─────────────────────────────────────────────────────────────────────────────
/// cart_screen.dart
/// SSENSE-style cart screen.
///   • RefreshIndicator — same pattern as home + shop screens
///   • Shimmer skeleton on loading (matches homescreen .shimmer() pattern)
///   • flutter_animate staggered fadeIn on items
///   • Empty state with CTA to shop
///   • Swipe-to-dismiss to remove items
///   • Order summary + IMPORTANT NOTICE + PLACE ORDER sticky button
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/cart_model.dart';
import 'package:aurelle_flutter/features/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartProvider);

    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────────
              _CartTopBar(
                onCheckoutTap: state.isEmpty || state.isLoading
                    ? null
                    : () => context.push(AppRoutes.checkout),
              ),
              _Hairline(),
      
              // ── Body ───────────────────────────────────────────────────────
              Expanded(
                child: state.isLoading
                    ? _CartSkeleton()
                    : state.isEmpty
                        ? _EmptyCart()
                        : _CartBody(state: state),
              ),
      
              // ── Sticky PLACE ORDER button ───────────────────────────────────
              if (!state.isLoading && !state.isEmpty)
                _PlaceOrderButton(
                  onTap: () => context.push(AppRoutes.checkout),
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
class _CartTopBar extends StatelessWidget {
  const _CartTopBar({this.onCheckoutTap});
  final VoidCallback? onCheckoutTap;

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
              onTap: () => context.pop(),
              child: Text('BACK', style: style),
            ),
            GestureDetector(
              onTap: onCheckoutTap,
              child: Text(
                'CHECKOUT',
                style: style?.copyWith(
                  color: onCheckoutTap == null
                      ? AppColors.lightTextSecondary
                      : AppColors.lightTextPrimary,
                ),
              ),
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
// Cart body — RefreshIndicator + items list + summary
// ─────────────────────────────────────────────────────────────────────────────
class _CartBody extends ConsumerWidget {
  const _CartBody({required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.black,
      strokeWidth: 2.5,
      onRefresh: () => ref.read(cartProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Cart items ───────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final item = state.items[i];
                final delay = Duration(milliseconds: 80 * i);
                return _CartItemRow(
                  item: item,
                  onDismiss: () =>
                      ref.read(cartProvider.notifier).removeItem(item.id),
                )
                    .animate()
                    .fadeIn(delay: delay, duration: 350.ms)
                    .slideX(
                      begin: 0.03,
                      end: 0,
                      delay: delay,
                      duration: 300.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
              childCount: state.items.length,
            ),
          ),

          // ── Order summary ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _OrderSummary(state: state)
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 80 * state.items.length),
                  duration: 400.ms,
                ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 4.h)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart item row — swipe to dismiss removes the item
// ─────────────────────────────────────────────────────────────────────────────
class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item, required this.onDismiss});
  final CartItemModel item;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.black,
        padding: EdgeInsets.only(right: 5.w),
        child: Text(
          'REMOVE',
          style: textTheme.labelLarge?.copyWith(
            fontSize: 10.sp,
            letterSpacing: 1.4,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Product image ──────────────────────────────────────
                Container(
                  width: 30.w,
                  height: 15.h,
                  color: AppColors.productPlaceholder,
                  child: item.imageUrl != null
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 20,
                            color: AppColors.lightTextSecondary
                                .withOpacity(0.3),
                          ),
                        ),
                ),

                SizedBox(width: 3.w),

                // ── Product info ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      Text(
                        item.brand,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 0.4.h),

                      // Product name
                      Text(
                        item.productName,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightTextPrimary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.4.h),

                      // Size + low stock
                      Row(
                        children: [
                          Text(
                            item.size,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          if (item.isLowStock) ...[
                            Text(
                              '  One Item Left',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Discount badge
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

                // ── Prices ─────────────────────────────────────────────
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order summary — subtotal, shipping, taxes, order total + notice + address
// ─────────────────────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.state});
  final CartState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = GoogleFonts.inter(
      fontSize: 12.sp,
      color: AppColors.lightTextPrimary,
      fontWeight: FontWeight.w400,
    );
    final valueStyle = GoogleFonts.inter(
      fontSize: 12.sp,
      color: AppColors.lightTextPrimary,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 3.h),

          // ── Summary rows ─────────────────────────────────────────────
          _SummaryRow(
            label: 'Subtotal (${state.items.length})',
            value: '\$${state.subtotal.toStringAsFixed(2)}',
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          SizedBox(height: 1.h),
          _SummaryRow(
            label: 'Shipping Total',
            value: '\$${state.shippingCost.toStringAsFixed(2)}',
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          SizedBox(height: 1.h),
          _SummaryRow(
            label: 'Taxes',
            value: '\$${state.taxes.toStringAsFixed(2)}',
            labelStyle: labelStyle,
            valueStyle: valueStyle,
          ),
          SizedBox(height: 1.h),
          _SummaryRow(
            label: 'Order Total (USD)',
            value: '\$${state.orderTotal.toStringAsFixed(2)}',
            labelStyle: labelStyle.copyWith(fontWeight: FontWeight.w600),
            valueStyle: valueStyle.copyWith(fontWeight: FontWeight.w700),
          ),

          SizedBox(height: 3.h),
          _Hairline(),
          SizedBox(height: 2.h),

          // ── Important notice ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IMPORTANT\nNOTICE',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.lightTextPrimary,
                  height: 1.5,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'Our prices do not include Duty and VAT. Please consult your country/region\'s customs legislation for more information about potential additional charges.',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // ── Store address ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'AURELLE',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Lagos, Nigeria',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms and Conditions',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          decoration: TextDecoration.underline,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Privacy Policy',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          decoration: TextDecoration.underline,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty cart state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 12.w,
            color: AppColors.lightTextSecondary.withOpacity(0.4),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),

          SizedBox(height: 2.h),

          Text(
            'YOUR BAG IS EMPTY',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: AppColors.lightTextPrimary,
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

          SizedBox(height: 1.h),

          Text(
            'Discover new arrivals and\nadd your favourites here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.lightTextSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

          SizedBox(height: 3.h),

          SizedBox(
            width: 60.w,
            height: 6.h,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.shop),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                'START SHOPPING',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer skeleton — matches homescreen pattern exactly
// ─────────────────────────────────────────────────────────────────────────────
class _CartSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, i) => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: 22.w,
                  height: 16.h,
                  color: AppColors.productPlaceholder,
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 1200.ms, color: AppColors.lightSurface),

                SizedBox(width: 3.w),

                // Text lines placeholder
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 1.4.h,
                        width: 28.w,
                        color: AppColors.productPlaceholder,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(
                              duration: 1200.ms,
                              color: AppColors.lightSurface),
                      SizedBox(height: 0.8.h),
                      Container(
                        height: 1.2.h,
                        width: 44.w,
                        color: AppColors.productPlaceholder,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(
                              duration: 1200.ms,
                              color: AppColors.lightSurface),
                      SizedBox(height: 0.8.h),
                      Container(
                        height: 1.2.h,
                        width: 20.w,
                        color: AppColors.productPlaceholder,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(
                              duration: 1200.ms,
                              color: AppColors.lightSurface),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Hairline(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky PLACE ORDER button
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceOrderButton extends StatelessWidget {
  const _PlaceOrderButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(3.h),
      child: GestureDetector(
        onTap: onTap,
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
// Shared hairline divider
// ─────────────────────────────────────────────────────────────────────────────
class _Hairline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: AppColors.divider);
  }
}