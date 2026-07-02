/// ─────────────────────────────────────────────────────────────────────────────
/// reels_product_card.dart
/// The always-visible product card overlaid on the reel video.
/// Matches the uploaded screen exactly:
///   • Warm blush/salmon card background (AppColors.reelsCardBackground)
///   • Product name + price on same row (bold)
///   • Brand name below in secondary colour
///   • Description text, material, length, washing instructions
///   • Size chips row — selected = black fill, sold out = greyed strike
///   • Colour swatches row — active has black ring
///   • Cart icon button (square) + Buy Now button (flex)
///
/// Zero logic — all state and callbacks come from the parent screen.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ReelsProductCard extends StatelessWidget {
  const ReelsProductCard({
    super.key,
    required this.product,
    required this.selectedSizeIndex,
    required this.selectedColorIndex,
    required this.onSizeSelected,
    required this.onColorSelected,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.visible,
  });

  final ReelProductModel product;
  final int selectedSizeIndex;
  final int selectedColorIndex;
  final ValueChanged<int> onSizeSelected;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: product.cardColor.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Row 1: Product name + price ────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 0.4.h),

              // ── Row 2: Brand name ──────────────────────────────────────
              Text(
                product.brand,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 1.h),

              // ── Description ────────────────────────────────────────────
              if (product.description != null)
                Text(
                  product.description!,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.lightBackground,
                    height: 1.5,
                  ),
                ),

              SizedBox(height: 2.5.h),

              // ── Meta: material, length, washing ───────────────────────
              if (product.material != null)
                _MetaRow(label: 'Material:', value: product.material!),
              if (product.length != null)
                _MetaRow(label: 'Length:', value: product.length!),
              if (product.washingInstructions != null)
                _MetaRow(
                    label: 'Washing instructions:',
                    value: product.washingInstructions!),

              SizedBox(height: 1.2.h),

              // ── Size label ─────────────────────────────────────────────
              Text(
                'Size*',
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),

              SizedBox(height: 0.8.h),

              // ── Size chips ─────────────────────────────────────────────
              Row(
                children: product.sizes.asMap().entries.map((e) {
                  final i = e.key;
                  final size = e.value;
                  final isSelected = i == selectedSizeIndex && !size.isSoldOut;
                  return Padding(
                    padding: EdgeInsets.only(right: 1.5.w),
                    child: _SizeChip(
                      label: size.label,
                      isSelected: isSelected,
                      isSoldOut: size.isSoldOut,
                      onTap: () => onSizeSelected(i),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 1.2.h),

              // ── Color label ────────────────────────────────────────────
              Text(
                'Color',
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),

              SizedBox(height: 0.8.h),

              // ── Color swatches ─────────────────────────────────────────
              Row(
                children: product.colors.asMap().entries.map((e) {
                  final i = e.key;
                  final isSelected = i == selectedColorIndex;
                  return Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: _ColorSwatch(
                      color: e.value.color,
                      isSelected: isSelected,
                      onTap: () => onColorSelected(i),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 1.5.h),

              // ── CTA row: cart + buy now ────────────────────────────────
              Row(
                children: [
                  // Cart button
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 18.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),

                  SizedBox(width: 2.w),

                  // Buy Now button
                  Expanded(
                    child: GestureDetector(
                      onTap: onBuyNow,
                      child: Container(
                        height: 11.w,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Buy Now',
                          style: textTheme.labelLarge?.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().slideY(
              begin: 0.06,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 0.2.h),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            TextSpan(
              text: value,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.lightBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.isSelected,
    required this.isSoldOut,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isSoldOut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: isSoldOut ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 9.w,
        height: 9.w,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.reelsSizeSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSoldOut
                ? AppColors.reelsSoldOut
                : isSelected
                    ? AppColors.reelsSizeSelected
                    : AppColors.reelsSizeBorder,
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isSoldOut
                ? AppColors.reelsSoldOut
                : isSelected
                    ? AppColors.white
                    : AppColors.lightTextPrimary,
            decoration: isSoldOut ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.reelsSoldOut,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.black : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.25),
                    blurRadius: 0,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}