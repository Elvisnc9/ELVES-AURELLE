/// ─────────────────────────────────────────────────────────────────────────────
/// recently_viewed_section.dart
/// "RECENTLY VIEWED" horizontal scroll section.
/// Separated from the generic ProductRowSection so the label style
/// and item sizing can be tuned independently if needed.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:aurelle_flutter/shared/widget/home/section_header.dart';
import 'package:aurelle_flutter/shared/widget/Product/product_card.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({
    super.key,
    required this.products,
    this.onProductTap,
  });

  final List<HomeProductModel> products;
  final ValueChanged<HomeProductModel>? onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          label: 'RECENTLY VIEWED', number: '',
        ),

        SizedBox(height: 1.h),

        SizedBox(
          height: 40.h,
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
        ),

       
      ],
    );
  }
}