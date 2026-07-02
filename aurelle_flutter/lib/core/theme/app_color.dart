import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color black = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFAFAFA);
  static const Color gold = Color.fromARGB(255, 231, 156, 18); // luxury accent

  // Light theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color.fromARGB(255, 213, 213, 213);
  static const Color lightTextPrimary = Color(0xFF0A0A0A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);

  // ── New: Home screen ─────────────────────────────────────────────────────
  /// Thin separator lines between sections (SSENSE-style hairline)
  static const Color divider = Color(0xFFE8E8E8);

  /// Strike-through price colour on sale items
  static const Color priceStrike = Color(0xFFAAAAAA);

  /// Subtle grey used for product card backgrounds / placeholder fills
  static const Color productPlaceholder = Color(0xFFF2F2F2);

  static const Color error = Color(0xFFD32F2F);


  static const Color reelsCardBackground = Color(0xFFF5EDE8);
  static const Color reelsSizeSelected = Color(0xFF0A0A0A);
  static const Color reelsSizeBorder = Color(0xFFD8D0CB);
  static const Color reelsSoldOut = Color(0xFFCCCCCC);
 
 
}