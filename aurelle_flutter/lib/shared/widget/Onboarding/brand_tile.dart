import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// BrandTile
/// Deliberately ONE container — logo and name sit directly inside it.
/// No inner box wrapping the logo; the selection border/badge are applied
/// to this same outer container, not a child.
/// ─────────────────────────────────────────────────────────────────────────
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

 static const Color _gold = Color.fromARGB(255, 231, 156, 18);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          border: Border.all(
            color: selected ? _gold : Colors.transparent,
            width: selected ? 3.5 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Image.asset(
                logoAsset,
                height: 20.h,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  size: 28,
                  color: Colors.black54,
                ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}