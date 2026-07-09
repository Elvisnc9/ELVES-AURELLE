/// ─────────────────────────────────────────────────────────────────────────────
/// brand_bottom_sheet.dart
///
/// TikTok-style brand profile pop-up shown when the brand name/avatar
/// is tapped on a reel. Minimal: avatar, name, tagline, stats row,
/// VIEW PRODUCTS button.
///
/// Usage:
///   BrandBottomSheet.show(context, brand: reel.brand, onViewProducts: () {
///     context.push(AppRoutes.brandProductsPath(brand.id));
///   });
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/brand_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class BrandBottomSheet extends StatelessWidget {
  const BrandBottomSheet({
    super.key,
    required this.brand,
    required this.onViewProducts,
  });

  final BrandProfile brand;
  final VoidCallback onViewProducts;

  /// Convenience static method — call this instead of showModalBottomSheet
  /// directly so the sheet config stays in one place.
  static void show(
    BuildContext context, {
    required BrandProfile brand,
    required VoidCallback onViewProducts,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // Allows the sheet to sit above the reel's immersive UI
      isScrollControlled: true,
      builder: (_) => BrandBottomSheet(
        brand: brand,
        onViewProducts: onViewProducts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        // Sharp top corners — no radius, consistent with app language
        borderRadius: BorderRadius.zero,
      ),
      padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            Center(
              child: Container(
                width: 10.w,
                height: 3,
                margin: EdgeInsets.only(bottom: 2.5.h),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Avatar + name + tagline ────────────────────────────────────
            Row(
              children: [
                // Avatar
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.productPlaceholder,
                    border: Border.all(
                      color: AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: brand.avatarUrl != null
                        ? Image.network(
                            brand.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _AvatarFallback(name: brand.name),
                          )
                        : _AvatarFallback(name: brand.name),
                  ),
                ),

                SizedBox(width: 3.w),

                // Name + tagline
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20.dp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      if (brand.tagline != null) ...[
                        SizedBox(height: 0.3.h),
                        Text(
                          brand.tagline!,
                          style: GoogleFonts.inter(
                            fontSize: 11.dp,
                            color: AppColors.lightTextSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // ── Stats row ──────────────────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                children: [
                  _StatCell(
                    value: brand.followersFormatted,
                    label: 'FOLLOWERS',
                  ),
                  _VerticalDivider(),
                  _StatCell(
                    value: brand.rating.toStringAsFixed(1),
                    label: 'RATING',
                    isRating: true,
                  ),
                  _VerticalDivider(),
                  _StatCell(
                    value: _formatCount(brand.reviewCount),
                    label: 'REVIEWS',
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // ── Hairline ───────────────────────────────────────────────────
            Container(height: 0.5, color: AppColors.divider),

            SizedBox(height: 2.5.h),

            // ── VIEW PRODUCTS button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close sheet first
                  onViewProducts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VIEW PRODUCTS',
                      style: GoogleFonts.inter(
                        fontSize: 12.dp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.arrow_forward, size: 16.dp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat cell
// ─────────────────────────────────────────────────────────────────────────────
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.isRating = false,
  });

  final String value;
  final String label;
  final bool isRating;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isRating) ...[
                Icon(
                  Icons.star,
                  size: 14.dp,
                  color: const Color(0xFFC9A86A), // gold
                ),
                SizedBox(width: 1.w),
              ],
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18.dp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.dp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical divider between stats
// ─────────────────────────────────────────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      color: AppColors.divider,
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar fallback — first letter of brand name on a placeholder background
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.productPlaceholder,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.cormorantGaramond(
          fontSize: 22.dp,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}



/// ─────────────────────────────────────────────────────────────────────────────
/// HOW TO WIRE THE BRAND BOTTOM SHEET
/// Apply these changes to your existing files.
/// ─────────────────────────────────────────────────────────────────────────────

// ── 1. reels_model.dart — add brand field to ReelModel ───────────────────────
//
// Add to ReelModel constructor:
//   required this.brand,
//
// Add field:
//   final BrandProfile brand;
//
// Update copyWith to include brand.
//
// In mock data, add to each ReelModel e.g.:
//   brand: const BrandProfile(
//     id: 'b1',
//     name: 'Jux Label',
//     followers: 24800,
//     rating: 4.7,
//     reviewCount: 312,
//     tagline: 'Crafted for the modern woman.',
//   ),


// ── 2. reels_screen.dart — show the sheet from _ReelEntry ────────────────────
//
// In _ReelEntry.build(), pass onBrandTap to _ReelVideoPage:

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return _ReelVideoPage(
//       reel: reel,
//       isActive: isActive,
//       cardVisible: cardVisible,
//       onCardTap: onCardTap,
//       onViewProduct: () => _onViewProduct(context, ref),
//       onBrandTap: () => BrandBottomSheet.show(         // ← add this
//         context,
//         brand: reel.brand,
//         onViewProducts: () {
//           context.push(AppRoutes.shopPath);            // 🔁 or brand-filtered shop path
//         },
//       ),
//     );
//   }
//
// Add onBrandTap param to _ReelVideoPage and pass it to ReelsOverlay:
//
//   final VoidCallback onBrandTap;
//   ...
//   ReelsOverlay(
//     reel: widget.reel,
//     visible: widget.cardVisible,
//     onViewProduct: widget.onViewProduct,
//     onBrandTap: widget.onBrandTap,    // ← add this
//   ),


// ── 3. reels_overlay.dart — make the brand row tappable ──────────────────────
//
// Wherever you render the brand name/avatar in ReelsOverlay,
// wrap it with GestureDetector:
//
//   GestureDetector(
//     onTap: onBrandTap,
//     behavior: HitTestBehavior.opaque,
//     child: Row(
//       children: [
//         // brand avatar circle
//         // brand name text
//       ],
//     ),
//   )
//
// Add onBrandTap as a required field to ReelsOverlay:
//   final VoidCallback onBrandTap;