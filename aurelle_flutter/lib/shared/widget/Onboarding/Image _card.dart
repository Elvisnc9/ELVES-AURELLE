import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class OverlapImageCard extends StatelessWidget {
  const OverlapImageCard({
    super.key,
    required this.imageAsset,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String imageAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _gold = Color(0xFFC9A86A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Card body ─────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    border: Border.all(
                      color: selected ? _gold : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                ),

                // ── Overflowing image ─────────────────────────────────
                Positioned(
                  top: -1.5.h,
                  left: 8,
                  right: 8,
                  child: SizedBox(
                    height: 23.h,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.productPlaceholder,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Gold checkmark badge ──────────────────────────────
                if (selected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 0.8.h),

            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.dp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}