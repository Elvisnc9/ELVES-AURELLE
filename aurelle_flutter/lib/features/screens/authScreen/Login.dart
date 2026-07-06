import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back ──────────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(1.w),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20.dp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.h),

                    // ── Logo ───────────────────────────────────────────────
                    Text(
                      'AURELLE',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4.0,
                        color: AppColors.black,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 8),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    SizedBox(height: 2.h),

                    // ── Heading ────────────────────────────────────────────
                    Text(
                      'Welcome\nBack.',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: AppColors.lightTextPrimary,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          delay: 80.ms,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: 1.2.h),

                    // ── Subheading ─────────────────────────────────────────
                    Text(
                      'Sign in to continue your\nluxury discovery.',
                      style: GoogleFonts.inter(
                        fontSize: 13.dp,
                        color: AppColors.lightTextSecondary,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(delay: 130.ms, duration: 400.ms),

                    const Spacer(),

                    // ── Divider ────────────────────────────────────────────
                    _DividerLabel()
                        .animate()
                        .fadeIn(delay: 180.ms, duration: 400.ms),

                    SizedBox(height: 2.h),

                    // ── Google ─────────────────────────────────────────────
                    _SocialButton(
                      logoAsset: 'assets/icon/google_logo.png',
                      fallbackIcon: Icons.g_mobiledata,
                      label: 'CONTINUE WITH GOOGLE',
                      backgroundColor: AppColors.lightBackground,
                      foregroundColor: AppColors.lightTextPrimary,
                      borderColor: const Color(0xFFE0DDD8),
                      onTap: () {},
                    )
                        .animate()
                        .fadeIn(delay: 220.ms, duration: 350.ms)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          delay: 220.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: 1.4.h),

                    // ── Facebook ───────────────────────────────────────────
                    _SocialButton(
                      logoAsset: 'assets/logos/facebook_logo.png',
                      fallbackIcon: Icons.facebook,
                      label: 'CONTINUE WITH FACEBOOK',
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: AppColors.white,
                      borderColor: Colors.transparent,
                      onTap: () {},
                    )
                        .animate()
                        .fadeIn(delay: 280.ms, duration: 350.ms)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          delay: 280.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: 1.4.h),

                    // ── Apple ──────────────────────────────────────────────
                    _SocialButton(
                      logoAsset: 'assets/logos/apple_logo.png',
                      fallbackIcon: Icons.apple,
                      label: 'CONTINUE WITH APPLE',
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      borderColor: Colors.transparent,
                      onTap: () {},
                    )
                        .animate()
                        .fadeIn(delay: 340.ms, duration: 350.ms)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          delay: 340.ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: 3.h),

                    // ── Register nudge ─────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/signup'),
                        behavior: HitTestBehavior.opaque,
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 12.dp,
                              color: AppColors.lightTextSecondary,
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account?  "),
                              TextSpan(
                                text: 'REGISTER',
                                style: GoogleFonts.inter(
                                  fontSize: 12.dp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.lightTextPrimary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 380.ms, duration: 350.ms),

                    SizedBox(height: 3.h),

                    // ── Terms ──────────────────────────────────────────────
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10.dp,
                          color: AppColors.lightTextSecondary,
                          height: 1.6,
                        ),
                      ),
                    ).animate().fadeIn(delay: 420.ms, duration: 350.ms),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social button — Material + InkWell, sharp corners, logo left / label centred
// ─────────────────────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.logoAsset,
    required this.fallbackIcon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String logoAsset;
  final IconData fallbackIcon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: foregroundColor.withOpacity(0.08),
        highlightColor: foregroundColor.withOpacity(0.04),
        child: SizedBox(
          width: double.infinity,
          height: 6.4.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              children: [
                SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      fallbackIcon,
                      size: 25.sp,
                      color: foregroundColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11.dp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "CONTINUE WITH" hairline divider
// ─────────────────────────────────────────────────────────────────────────────
class _DividerLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 0.5, color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Text(
            'CONTINUE WITH',
            style: GoogleFonts.inter(
              fontSize: 10.dp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ),
        Expanded(child: Container(height: 0.5, color: AppColors.divider)),
      ],
    );
  }
}