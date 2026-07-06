import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
    this.counterText,
    this.onSkip,
    this.enabled = true,
  });

  final String buttonLabel;
  final VoidCallback onPressed;
  final String? counterText;
  final VoidCallback? onSkip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Counter pill ──────────────────────────────────────────────
        if (counterText != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            decoration: const BoxDecoration(
              color: Color(0xFFF0EDE7),
              // sharp corners — matches app-wide button language
            ),
            child: Text(
              counterText!,
              style: GoogleFonts.inter(
                fontSize: 12.dp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 1.2.h),
        ],

        // ── Skip link ─────────────────────────────────────────────────
        if (onSkip != null) ...[
          GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                'Skip for now',
                style: GoogleFonts.inter(
                  fontSize: 12.dp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
        ],

        // ── Primary CTA — BorderRadius.zero matches every other screen ─
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              disabledBackgroundColor: Colors.black26,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // fixed — was circular(4)
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  buttonLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12.dp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16.dp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}