/// ─────────────────────────────────────────────────────────────────────────────
/// product_card.dart
/// Reusable vertical product card used in all horizontal scroll rows.
/// Matches SSENSE's card exactly:
///   • Tall image (model photo), no border-radius
///   • Brand name (Inter, small, grey)
///   • Price — sale: [current]  [original struck]
///            normal: [price]
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.cardWidth,
  });

  final HomeProductModel product;
  final VoidCallback? onTap;

  /// Override width; defaults to ~40% screen width
  final double? cardWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = cardWidth ?? 40.w;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image ──────────────────────────────────────────────
            _ProductImage(
              imageUrl: product.imageUrl,
              width: width,
              height: width * 1.35, // portrait ratio
            ),

            SizedBox(height: 1.h),

            // ── Brand name ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.5.w),
              child: Text(
                product.brand,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: 0.3.h),

            // ── Price row ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.5.w),
              child: Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  if (product.isOnSale) ...[
                    SizedBox(width: 1.5.w),
                    Text(
                      '\$${product.originalPrice!.toStringAsFixed(0)}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.priceStrike,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.priceStrike,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product image — shows network image if URL provided, else placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String? imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.productPlaceholder,
      child: imageUrl != null
          ? Image.asset(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _Placeholder(),
            )
          : const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person_outline,
        size: 32,
        color: AppColors.lightTextSecondary.withOpacity(0.3),
      ),
    );
  }
}