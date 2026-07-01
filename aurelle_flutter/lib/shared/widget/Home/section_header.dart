/// ─────────────────────────────────────────────────────────────────────────────
/// section_header.dart
/// The numbered section header row used throughout the home screen.
///
/// Exact SSENSE pattern:
///   [007]  SALE FROM   ›
///
/// • Number  → titleSmall (gold, tracking, w700)
/// • Label   → labelLarge (black, tracking, w600) uppercased
/// • Arrow   → Icon, right-aligned, only when [onTap] is provided
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.number,
    required this.label,
    this.onTap,
  });

  final String number;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0.6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Section number (gold) ──────────────────────────────────────
            Text(
              number,
              style: textTheme.titleSmall,
            ),

            SizedBox(width: 2.w),

            // ── Section label ──────────────────────────────────────────────
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 11.sp,
                  letterSpacing: 1.4,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),

            // ── Arrow (only when tappable) ─────────────────────────────────
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 18.sp,
                color: AppColors.lightTextPrimary,
              ),
          ],
        ),
      ),
    );
  }
}