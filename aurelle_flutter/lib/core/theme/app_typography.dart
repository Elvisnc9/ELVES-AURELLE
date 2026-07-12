import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w600, color: primaryColor,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 24, fontWeight: FontWeight.w600, color: primaryColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: primaryColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: secondaryColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor,
      ),

      bodySmall: GoogleFonts.dancingScript(
        fontSize: 18.sp, fontWeight: FontWeight.w400, color: secondaryColor,
      ),

      labelMedium: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      
                      ),

      titleSmall:  TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.gold,
                    ),



                    titleMedium: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w900, fontSize: 30.sp, color: AppColors.black)
    );
  }
}