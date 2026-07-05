/// ─────────────────────────────────────────────────────────────────────────────
/// product_row_section.dart
/// A full section: SectionHeader + horizontally scrolling ProductCard row.
/// Also supports a 2-row grid layout (useGrid: true) like SSENSE's
/// "FOR YOU IN SALE" section which shows 2 rows stacked in the scroll.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:aurelle_flutter/shared/widget/Product/product_card.dart';
import 'package:aurelle_flutter/shared/widget/home/section_header.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ProductRowSection extends StatelessWidget {
  const ProductRowSection({
    super.key,
    required this.section,
    this.onProductTap,
    this.onHeaderTap,
  });

  final HomeProductSectionModel section;
  final ValueChanged<HomeProductModel>? onProductTap;
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          number: section.sectionNumber,
          label: section.sectionLabel,
          onTap: onHeaderTap,
        ),

        SizedBox(height: 1.h),

        section.useGrid
            ? _GridRow(
                products: section.products,
                onProductTap: onProductTap,
              )
            : _SingleRow(
                products: section.products,
                onProductTap: onProductTap,
              ),

        SizedBox(height: 2.5.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single horizontal row
// ─────────────────────────────────────────────────────────────────────────────
class _SingleRow extends StatelessWidget {
  const _SingleRow({required this.products, this.onProductTap});

  final List<HomeProductModel> products;
  final ValueChanged<HomeProductModel>? onProductTap;

  @override
  Widget build(BuildContext context) {
    // image height = cardWidth * 1.35, plus 1.h gap + ~4.5.h for brand + price text
    final cardWidth = 40.w;
    final rowHeight = (cardWidth * 1.35) + 6.h;

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (_, __) => SizedBox(width: 3.w),
        itemBuilder: (context, i) => ProductCard(
          product: products[i],
          onTap: () => onProductTap?.call(products[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2-row grid in a horizontal scroll — matches SSENSE "FOR YOU" section
// Products are arranged: top row = even indices, bottom row = odd indices
// ─────────────────────────────────────────────────────────────────────────────
class _GridRow extends StatelessWidget {
  const _GridRow({required this.products, this.onProductTap});

  final List<HomeProductModel> products;
  final ValueChanged<HomeProductModel>? onProductTap;

  @override
  Widget build(BuildContext context) {
    // Split into two rows: [0,2,4,...] top, [1,3,5,...] bottom
    final topRow = <HomeProductModel>[];
    final bottomRow = <HomeProductModel>[];
    for (int i = 0; i < products.length; i++) {
      if (i.isEven) {
        topRow.add(products[i]);
      } else {
        bottomRow.add(products[i]);
      }
    }

    final cardWidth = 36.w;
    final imageHeight = cardWidth * 1.35;
    // Each ProductCard = image + 1.h gap + brand text (~2.h) + 0.3.h + price (~2.h)
    final cardTotalHeight = imageHeight + 6.h;
    // Two cards + gap between them
    final totalHeight = (cardTotalHeight * 2) + 2.h;

    return SizedBox(
      height: totalHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        clipBehavior: Clip.none,
        itemCount: topRow.length,
        separatorBuilder: (_, _) => SizedBox(width: 2.w),
        itemBuilder: (context, i) {
          return SizedBox(
            height: totalHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductCard(
                  product: topRow[i],
                  cardWidth: cardWidth,
                  onTap: () => onProductTap?.call(topRow[i]),
                ),
                SizedBox(height: 2.h),
                if (i < bottomRow.length)
                  ProductCard(
                    product: bottomRow[i],
                    cardWidth: cardWidth,
                    onTap: () => onProductTap?.call(bottomRow[i]),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}