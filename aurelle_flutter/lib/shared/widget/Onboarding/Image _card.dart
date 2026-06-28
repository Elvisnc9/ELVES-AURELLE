import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// OverlapImageCard
/// The "pop out of the card" tile used by both the Style Identity and
/// Discovery Preference screens. The image is a Positioned child that
/// starts ABOVE the card's top edge — Stack's clipBehavior.none is what
/// lets it render outside the card's bounds instead of being clipped.
///
/// Layout anatomy (top to bottom):
///   [image — overflows upward, its own rounded corners + shadow]
///   [card  — starts partway down, holds the label at its base]
/// ─────────────────────────────────────────────────────────────────────────
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

  /// How far the image pops above the card's top edge.

  static const Color _gold = Color.fromARGB(255, 231, 156, 18);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Card body (starts lower, holds the label) ──────────────────
                AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: double.infinity,
                          height: 200, // Increase this
                          decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        
                        border: Border.all(
                          color: selected ? _gold : Colors.transparent,
                          width: 1.5,
                        ),
                          ),
                        ),
          
                // ── Overflowing image ───────────────────────────────────────────
                Positioned(
                  top: -20,
            left: 10,
            right: 10,
                  child: SizedBox(
                    height: 25.h,
                    
                    child: Image.asset(imageAsset, fit: BoxFit.cover,),
                  )
                  ),
              
          
                // ── Selection checkmark badge ───────────────────────────────────
              
              ],
            ),
          ),
          SizedBox(height: 0.5.h,),
          Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black
          ),
            ),
        ],
      
      ),
    );
  }
}