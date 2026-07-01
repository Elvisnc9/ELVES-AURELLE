/// ─────────────────────────────────────────────────────────────────────────────
/// hero_banner.dart
/// Full-bleed black hero banner with editorial headline + subline.
/// Height is ~45% of screen height, matching SSENSE's proportions.
///
/// Media priority: videoUrl > imageUrl > pure black.
/// Video plays autostart, muted, looped, and pauses when scrolled out of
/// view or when the app is backgrounded. First-load has no placeholder —
/// the container is black by default, so a delayed video is invisible.
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
  const HeroBanner({super.key, required this.banner});

  final HeroBannerModel banner;

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with WidgetsBindingObserver {
  VideoPlayerController? _controller;

  bool _disposed = false;
  bool _isVisible = false;
  bool _isAppForeground = true;

  static const _visibilityKey = ValueKey('hero_banner_video');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final url = widget.banner.videoUrl;
    if (url.isNotEmpty) {
      _initController(url);
    }
  }

  void _initController(String url) {
    final controller = VideoPlayerController.asset('aurelle_flutter/assets/anim/Asos-women_Video.mp4');
    _controller = controller;

    controller.initialize().then((_) {
      // Guard: widget may have been disposed while this future was pending.
      if (_disposed) {
        controller.dispose();
        return;
      }
      controller.setLooping(true);
      controller.setVolume(0);
      if (mounted) setState(() {}); // paint first frame
      _syncPlayback();
    }).catchError((_) {
      // Swallow — falls back to black container, no error UI per design.
    });
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final shouldPlay = _isVisible && _isAppForeground;
    if (shouldPlay && !controller.value.isPlaying) {
      controller.play();
    } else if (!shouldPlay && controller.value.isPlaying) {
      controller.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppForeground = state == AppLifecycleState.resumed;
    _syncPlayback();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Threshold: play once >20% visible, pause once it drops below.
    final visible = info.visibleFraction > 0.2;
    if (visible != _isVisible) {
      _isVisible = visible;
      _syncPlayback();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = widget.banner;
    final controller = _controller;
    final videoReady = controller != null && controller.value.isInitialized;

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: SizedBox(
        width: double.infinity,
        height: 45.h,
        child: Stack(
          children: [
            // ── Background ───────────────────────────────────────────────
            Positioned.fill(
              child: videoReady
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        // ignore: deprecated_member_use
                        Colors.black.withOpacity(0.55),
                        BlendMode.darken,
                      ),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    )
                  : (const ColoredBox(color: AppColors.black)),
            ),

            // ── Text — bottom-left, SSENSE style ────────────────────────
            Positioned(
              left: 4.w,
              bottom: 3.h,
              right: 4.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner.subline,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.4,
                      color: AppColors.white.withOpacity(0.65),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                  SizedBox(height: 0.8.h),

                  Text(
                    banner.headline,
                    style: GoogleFonts.inter(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.05,
                      color: AppColors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 180.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 450.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}