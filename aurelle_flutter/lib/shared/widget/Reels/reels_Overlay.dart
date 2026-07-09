/// ─────────────────────────────────────────────────────────────────────────────
/// reels_overlay.dart
/// Full bottom overlay sitting directly on the video gradient — no card bg.
///
/// Layout:
///   • Brand pill (outline chip, white border)
///   • Product name (large Playfair Display, white)
///   • Short description (white, 75% opacity)
///   • Stats bar (dark semi-transparent pill — X sold | ⭐ rating)
///   • Bottom row: price pill (gold border) + View Product button (white pill)
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ReelsOverlay extends StatelessWidget {
  const ReelsOverlay({
    super.key,
    required this.reel,
    required this.visible,
    required this.onViewProduct,
    required this.onBrandTap,
  });

  final ReelModel reel;
  final bool visible;
  final VoidCallback onViewProduct;
  final VoidCallback onBrandTap;

  String _fmt(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';

  @override
  Widget build(BuildContext context) {
    final variant = reel.primaryVariant;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Brand pill ─────────────────────────────────────────────
              GestureDetector(
                onTap: onBrandTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                    color: Colors.white.withOpacity(0.08),
                  ),
                  child: Text(
                    variant.brand.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.white,
                    ),
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
              ),

              SizedBox(height: 1.h),

              // ── Product name ───────────────────────────────────────────
              Text(
                variant.productName,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 400.ms)
                  .slideY(begin: 0.08, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),

              SizedBox(height: 0.8.h),

              // ── Short description ──────────────────────────────────────
              if (variant.itemInfo != null)
                Text(
                  variant.itemInfo!.split('\n').first,
                
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white.withOpacity(0.75),
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(delay: 160.ms, duration: 400.ms),

              SizedBox(height: 1.8.h),

              // ── Stats bar ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
                ),
                child: Row(
                  children: [
                    // Sold
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 20.sp, color: AppColors.white),
                          SizedBox(width: 2.w),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '${_fmt(reel.salesCount)} ',
                                style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.white),
                              ),
                              TextSpan(
                                text: 'sold',
                                style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.white.withOpacity(0.75)),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(width: 0.5, height: 2.h, color: Colors.white.withOpacity(0.25)),
                    // Rating
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_rounded, size: 20.sp, color: AppColors.gold),
                          SizedBox(width: 1.5.w),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '${reel.rating.toStringAsFixed(1)} ',
                                style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.white),
                              ),
                              TextSpan(
                                text: '(${_fmt(reel.reviewCount)})',
                                style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.white.withOpacity(0.75)),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              SizedBox(height: 1.5.h),

              // ── Bottom row: price + view product ──────────────────────
              Row(
                children: [
                  // Price pill — gold border
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: Text(
                      '\$${variant.price.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // View product — white pill
                  Expanded(
                    child: GestureDetector(
                      onTap: onViewProduct,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 1.4.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                       
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View product',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(Icons.chevron_right, color: AppColors.black, size: 16.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }
}