/// ─────────────────────────────────────────────────────────────────────────────
/// home_app_bar.dart
/// Stateless top bar: "SEARCH" (left) · "BAG 01" (right).
/// Matches SSENSE's ultra-minimal editorial header exactly.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.bagCount,
    this.onSearchTap,
    this.onBagTap,
  });

  final int bagCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBagTap;

  @override
  Size get preferredSize => Size.fromHeight(6.h);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = textTheme.labelLarge?.copyWith(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.6,
      color: AppColors.lightTextPrimary,
    );

    return Container(
      height: preferredSize.height,
      color: AppColors.lightBackground,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── SEARCH ────────────────────────────────────────────────────────
          GestureDetector(
            onTap: onSearchTap,
            behavior: HitTestBehavior.opaque,
            child: Text('SEARCH', style: labelStyle),
          ),

          // ── BAG count ─────────────────────────────────────────────────────
          GestureDetector(
            onTap: onBagTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'BAG ${bagCount.toString().padLeft(2, '0')}',
              style: labelStyle,
            ),
          ),
        ],
      ),
    );
  }
}