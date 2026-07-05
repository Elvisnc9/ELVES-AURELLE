/// ─────────────────────────────────────────────────────────────────────────────
/// reels_stats_card.dart
/// Single minimal card sitting above the bottom nav bar.
/// Contains: brand · name · price · likes · sales · rating · swipe hint.
/// No sidebar. No bookmark. No TikTok-style action buttons.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ReelsStatsCard extends StatelessWidget {
  const ReelsStatsCard({super.key, required this.reel, required this.visible});

  final ReelModel reel;
  final bool visible;

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final variant = reel.primaryVariant;

    // Bottom nav bar height — card sits above it
    final bottomNavHeight = kBottomNavigationBarHeight + 8;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            3.w,
            0,
            3.w,
            bottomNavHeight / MediaQuery.of(context).size.height * 100 + 1.5,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: brand, name, price, stats ─────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand
                    Text(
                      variant.brand.toUpperCase(),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),

                    SizedBox(height: 0.6.h),

                    // Product name
                    Text(
                      variant.productName,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBackground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(width: 5.w),

                    Text(
                     'Crafted with premium materials for exceptional comfort and lasting quality.'
                      'Its modern silhouette blends timeless elegance with everyday versatility.'
                      ' Designed to elevate your wardrobe, it pairs effortlessly with both casual and formal looks.'
                      ' Every detail is carefully finished to deliver a refined and sophisticated experience.',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16.sp,
                      
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBackground,
                      ),
                    ),

                    Text(
                      '\$${variant.price.toStringAsFixed(0)}',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 244, 178, 57),
                      ),
                    ),

                    // Price
                    SizedBox(height: 1.2.h),

                    // ── Stats row ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      
                        SizedBox(width: 4.w),
                        _Stat(
                          icon: Icons.shopping_bag_outlined,
                          iconColor: AppColors.white,
                          label: '${_formatCount(reel.salesCount)} sold',
                        ),
                        SizedBox(width: 4.w),
                        _Stat(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.gold,
                          label:
                              '${reel.rating.toStringAsFixed(1)} '
                              '(${_formatCount(reel.reviewCount)})',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Right: animated swipe hint ───────────────────────────
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single stat — icon + label
// ─────────────────────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20.sp, color: iconColor),
        SizedBox(width: 1.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightBackground,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated swipe-left hint
// ─────────────────────────────────────────────────────────────────────────────
class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.chevron_left, color: AppColors.lightBackground, size: 22.sp)
            .animate(onPlay: (c) => c.repeat())
            .slideX(
              begin: 0.3,
              end: 0,
              duration: 700.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .slideX(
              begin: 0,
              end: 0.3,
              duration: 700.ms,
              curve: Curves.easeInOut,
            ),
        SizedBox(height: 0.4.h),
        Text(
          'Details',
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
