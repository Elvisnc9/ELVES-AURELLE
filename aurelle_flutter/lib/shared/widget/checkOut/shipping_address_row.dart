/// ─────────────────────────────────────────────────────────────────────────────
/// PATCH — apply these changes to checkout_screen.dart
/// Only the SHIPPING row and the import change. Everything else stays the same.
/// ─────────────────────────────────────────────────────────────────────────────

// 1. ADD this import at the top of checkout_screen.dart:
// import 'package:aurelle_flutter/features/provider/address_provider.dart';
// import 'package:aurelle_flutter/core/navigation/approutes.dart';

// 2. Change CheckoutScreen from ConsumerWidget to ConsumerWidget (already is),
//    and update the SHIPPING row inside the build method.
//
// REMOVE the existing static SHIPPING GoRoute in router and replace with:
//
// GoRoute(
//   path: '/address/add',
//   pageBuilder: (context, state) => SlideRightTransitionPage(
//     key: state.pageKey,
//     child: const AddAddressScreen(),
//   ),
// ),
//
// 3. REPLACE the existing SHIPPING _CheckoutInfoRow with this:

// ── In CheckoutScreen.build(), read the address ──────────────────────────────
//   final address = ref.watch(addressProvider);   ← add this line

// ── Replace the SHIPPING SliverToBoxAdapter with: ────────────────────────────

/*
SliverToBoxAdapter(
  child: _ShippingRow(
    address: address,
    onTap: () => context.push('/address/add'),
  ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
),
*/

// ─────────────────────────────────────────────────────────────────────────────
// Drop-in replacement widget for the SHIPPING row — paste into checkout_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/address_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class ShippingRow extends StatelessWidget {
  const ShippingRow({super.key, 
    required this.address,
    required this.onTap,
  });

  final AddressModel? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasAddress = address != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            SizedBox(
              width: 22.w,
              child: Text(
                'SHIPPING',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),

            // Content — placeholder OR saved address
            Expanded(
              child: hasAddress
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address!.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          address!.displayAddress,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.lightTextSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          address!.phone,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        SizedBox(height: 0.8.h),
                        // Edit link
                        Text(
                          'EDIT',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.lightTextPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Add shipping address',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
            ),

            Icon(
              Icons.chevron_right,
              size: 16.sp,
              color: AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}