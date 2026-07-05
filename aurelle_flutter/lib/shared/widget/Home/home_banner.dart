/// ─────────────────────────────────────────────────────────────────────────────
/// hero_banner.dart
/// UI touches vs previous version:
///   • Search + Bag icons: circular containers removed → plain Material
///     IconButton style, consistent with how icons are handled on other screens
///   • Bag badge: uses Material Badge widget instead of custom Positioned box
///   • Shop Now button: BorderRadius.circular(30) → BorderRadius.zero to match
///     the sharp-corner button language used on cart, profile, and onboarding
///   • Brand headline font: Cormorant Garamond instead of Inter (matches the
///     heading font contract set in AppTypography)
///   • Everything else — architecture, video logic, overlays — UNCHANGED
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/home_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HeroBanner extends StatefulWidget {
  const HeroBanner({
    super.key,
    required this.banner,
    required this.bagCount,
    this.onProfileTap,
    this.onSearchTap,
    this.onBagTap,
    this.onShopNowTap,
  });

  final HeroBannerModel banner;
  final int bagCount;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBagTap;
  final VoidCallback? onShopNowTap;

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _disposed = false;
  bool _isVisible = false;
  bool _isAppForeground = true;

  static const _visibilityKey = ValueKey('hero_banner_video');

  // ── Lifecycle — UNCHANGED ─────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final url = widget.banner.videoUrl;
    if (url.isNotEmpty) _initController(url);
  }

  Future<void> _initController(String assetPath) async {
    final controller = VideoPlayerController.asset(assetPath);
    try {
      await controller.initialize();
    } catch (_) {
      await controller.dispose();
      return;
    }
    if (_disposed || !mounted) {
      await controller.dispose();
      return;
    }
    await controller.setLooping(true);
    await controller.setVolume(0);
    if (_disposed || !mounted) {
      await controller.dispose();
      return;
    }
    _controller = controller;
    setState(() {});
    _syncPlayback();
  }

  void _syncPlayback() {
    if (_disposed) return;
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final shouldPlay = _isVisible && _isAppForeground;
    if (shouldPlay && !c.value.isPlaying)
      c.play();
    else if (!shouldPlay && c.value.isPlaying)
      c.pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppForeground = state == AppLifecycleState.resumed;
    _syncPlayback();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.2;
    if (visible == _isVisible) return;
    _isVisible = visible;
    _syncPlayback();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final banner = widget.banner;
    final controller = _controller;
    final videoReady = controller != null && controller.value.isInitialized;
    final topPadding = MediaQuery.of(context).padding.top;

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: SizedBox(
        width: double.infinity,
        height: 60.h,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Black base ─────────────────────────────────────────────
              const ColoredBox(color: AppColors.black),

              // ── 2. Video ──────────────────────────────────────────────────
              if (videoReady)
                FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),

              // ── 3. Dark overlay ───────────────────────────────────────────
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0x55000000)),
              ),

              // ── 4. Gradient ───────────────────────────────────────────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x99000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                    stops: [0.0, 0.25, 0.55, 1.0],
                  ),
                ),
              ),

              // ── 5. Floating top bar ───────────────────────────────────────
              // CHANGED: Removed circular Container wrappers from icons.
              // Icons now sit directly as Material InkWell targets — same
              // pattern as the top bars in shop, cart, and checkout screens.
              Positioned(
                top: topPadding + 1.h,
                left: 4.w,
                right: 4.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Wordmark
                    Text(
                      'AURELLE',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4.0,
                        color: AppColors.white,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 8),
                        ],
                      ),
                    ),

                    // Icon row — plain icons, no circular container
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onSearchTap,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Icon(
                              Icons.search,
                              color: AppColors.white,
                              size: 30.sp,
                              shadows: const [
                                Shadow(color: Colors.black45, blurRadius: 6),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: widget.onBagTap,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.all(2.w),
                            // Material Badge handles the count dot natively
                            child: Badge(
                              isLabelVisible: widget.bagCount > 0,
                              label: Text(
                                '${widget.bagCount}',
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              backgroundColor: AppColors.gold,
                              child: Image.asset('assets/icon/parcel.png',
                                  height: 30.sp, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // ── 6. Bottom-left: subline + headline + Shop Now ─────────────
              Positioned(
                left: 4.w,
                bottom: 4.h,
                right: 35.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subline
                    Text(
                      banner.subline,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                        color: const Color(0xCCFFFFFF),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                    SizedBox(height: 0.6.h),

                    // Headline — CHANGED: Cormorant Garamond to match heading
                    // font contract; same weight as other screen headings
                    Text(
                          banner.headline,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            height: 1.2,
                            color: AppColors.white,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 500.ms)
                        .slideY(
                          begin: 0.12,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: 1.5.h),

                    // Shop Now — CHANGED: sharp corners (BorderRadius.zero)
                    // to match button language used in cart, profile, onboarding
                    GestureDetector(
                      onTap: widget.onShopNowTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 1.5.h,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          // No BorderRadius — sharp corners like the rest
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SHOP NOW',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.black,
                              size: 14.sp,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                  ],
                ),
              ),

              // ── 7. Bottom-right badge — UNCHANGED ────────────────────────
              Positioned(
                right: 4.w,
                bottom: 4.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.ac_unit,
                      color: AppColors.white,
                      size: 14.sp,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '15% off new',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'collection',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}