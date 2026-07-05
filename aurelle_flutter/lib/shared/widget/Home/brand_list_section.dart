/// ─────────────────────────────────────────────────────────────────────────────
/// brand_list_section.dart
/// UI touch vs previous version:
///   • 28.sp → 26.dp — sp scales with the user's system font size accessibility
///     setting, which can make brand names overflow at large text sizes. dp uses
///     the logarithmic screen-density formula from the_responsive_builder and
///     stays visually consistent regardless of system font preference.
///     This matches how all other text in the app is sized.
///   • Everything else — layout, animation, divider — UNCHANGED
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:aurelle_flutter/shared/widget/home/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class BrandListSection extends StatelessWidget {
  const BrandListSection({
    super.key,
    required this.section,
    this.onBrandTap,
    this.onHeaderTap,
  });

  final HomeBrandSectionModel section;
  final ValueChanged<String>? onBrandTap;
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        SectionHeader(
          number: section.sectionNumber,
          label: section.sectionLabel,
          onTap: onHeaderTap,
        ),

        // ── Brand names ────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0.5.h, 4.w, 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: section.brands.asMap().entries.map((entry) {
              final index = entry.key;
              final brand = entry.value;

              return GestureDetector(
                onTap: () => onBrandTap?.call(brand),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0.2.h),
                  child: Text(
                    brand,
                    style: GoogleFonts.inter(
                      // CHANGED: sp → dp so large system font settings don't
                      // cause brand names to overflow or wrap unexpectedly.
                      fontSize: 26.dp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.2,
                      color: AppColors.lightTextPrimary,
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 60 * index),
                        duration: 400.ms,
                      )
                      .slideX(
                        begin: -0.04,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Bottom divider ─────────────────────────────────────────────────
        _Divider(),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: AppColors.divider,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }
}