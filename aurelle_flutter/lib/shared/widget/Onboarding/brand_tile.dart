import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class BrandTile extends StatelessWidget {
  const BrandTile({
    super.key,
    required this.logoAsset,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String logoAsset;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  static const Color _gold = Color(0xFFC9A86A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          border: Border.all(
            color: selected ? _gold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Image.asset(
                logoAsset,
               
                errorBuilder: (_, _, _) => Icon(
                  Icons.storefront_outlined,
                  size: 24,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),

            // ── Gold checkmark badge ──────────────────────────────────
            if (selected)
              Positioned(
                top: -8,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: _gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}