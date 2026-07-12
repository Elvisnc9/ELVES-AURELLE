import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PATCH — add to product_detail_screen.dart
/// ─────────────────────────────────────────────────────────────────────────────

// ── 1. Add this provider near the top of the file (outside the widget) ────────

// Tracks selected size per product — keyed by productId so each product
// independently remembers its selection.
final _selectedSizeProvider =
    StateProvider.family<String?, String>((ref, productId) => null);

// ── 2. Add this sliver BETWEEN "Brand + name + price" and "CTA buttons" ───────
// i.e. after:   SliverToBoxAdapter(child: SizedBox(height: 2.h)),
//        (the one that follows _ProductInfo)
// and before:   SliverToBoxAdapter(child: Padding(..._CTARow...))

/*
SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    child: _SizeSelector(productId: widget.productId),
  ),
),
SliverToBoxAdapter(child: SizedBox(height: 2.h)),
*/

// ── 3. Paste the _SizeSelector widget at the bottom of the file ───────────────



// Mock sizes — swap per product when backend is wired
const _mockSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
const _soldOutSizes = ['XS']; // example sold-out size

class SizeSelector extends ConsumerWidget {
  const SizeSelector({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedSizeProvider(productId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label row ───────────────────────────────────────────────────
        Row(
       
          children: [
            Text(
              'SIZE',
              style: GoogleFonts.inter(
                fontSize: 10.dp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: AppColors.lightTextSecondary,
              ),
            ),SizedBox(width: 5.w),
            if (selected != null)

            
              Text(
                selected,
                style: GoogleFonts.inter(
                  fontSize: 14.dp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.lightTextPrimary,
                ),
              ),
          ],
        ),

        SizedBox(height: 1.2.h),

        // ── Size chips ───────────────────────────────────────────────────
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _mockSizes.map((size) {
            final isSelected  = selected == size;
            final isSoldOut   = _soldOutSizes.contains(size);

            return GestureDetector(
              onTap: isSoldOut
                  ? null
                  : () => ref
                      .read(_selectedSizeProvider(productId).notifier)
                      .state = isSelected ? null : size,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width:  12.w,
                height: 4.5.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.black
                      : AppColors.lightSurface,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.black
                        : const Color(0xFFE0DDD8),
                    width: isSelected ? 1.5 : 1,
                  ),
                  // Sharp corners — matches app language
                ),
                child: isSoldOut
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            size,
                            style: GoogleFonts.inter(
                              fontSize: 14.dp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightTextSecondary
                                  .withOpacity(0.35),
                            ),
                          ),
                          // Diagonal strikethrough line for sold out
                          CustomPaint(
                            size: Size(13.w, 5.5.h),
                            painter: _StrikethroughPainter(),
                          ),
                        ],
                      )
                    : Text(
                        size,
                        style: GoogleFonts.inter(
                          fontSize: 12.dp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.lightTextPrimary,
                        ),
                      ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 0.8.h),

        // ── Sold out hint ────────────────────────────────────────────────
        if (_soldOutSizes.isNotEmpty)
          Text(
            'Crossed sizes are sold out',
            style: GoogleFonts.inter(
              fontSize: 9.dp,
              color: AppColors.lightTextSecondary,
            ),
          ),
      ],
    );
  }
}

// Diagonal line painter for sold-out sizes
class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.15),
      Paint()
        ..color = AppColors.lightTextSecondary.withOpacity(0.35)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}