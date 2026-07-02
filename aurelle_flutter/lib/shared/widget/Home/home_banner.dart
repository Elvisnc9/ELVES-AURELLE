/// ─────────────────────────────────────────────────────────────────────────────
/// hero_banner.dart
///
/// Fixes applied vs previous version:
///
/// BUG 1 — "VideoPlayerController used after dispose"
///   Root cause: _controller was assigned BEFORE initialize() resolved.
///   If dispose() ran during that async gap, _controller.dispose() was called,
///   but the .then() callback still fired on the dead controller.
///
///   Fix: local-ref pattern — controller is only assigned to _controller
///   AFTER initialize() succeeds AND _disposed/mounted are confirmed clean.
///   Every await is followed by a _disposed/mounted guard before proceeding.
///
/// BUG 2 — ShaderMask / ColorFiltered bleed (previous session)
///   Fix retained: Stack overlay Container instead of ColorFiltered.
///   ClipRect wraps the entire Stack as a hard guarantee.
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
  // ── State ──────────────────────────────────────────────────────────────────

  /// Null until the controller has fully initialized AND the widget is
  /// confirmed alive. Never read from inside the init future chain — use
  /// local variables there instead.
  VideoPlayerController? _controller;

  bool _disposed = false;
  bool _isVisible = false;
  bool _isAppForeground = true;

  static const _visibilityKey = ValueKey('hero_banner_video');

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final url = widget.banner.videoUrl;
    if (url.isNotEmpty) _initController(url);
  }

  /// Async init using local-ref pattern.
  ///
  /// Pattern rule: NEVER touch [_controller] or any widget state inside this
  /// method until AFTER every await has passed a _disposed + mounted check.
  Future<void> _initController(String assetPath) async {
    // Step 1 — create locally, do NOT assign to _controller yet
    final controller = VideoPlayerController.asset(assetPath);

    // Step 2 — initialize (may take a few hundred ms)
    try {
      await controller.initialize();
    } catch (_) {
      // Init failed — discard silently, banner shows black base
      await controller.dispose();
      return;
    }

    // Step 3 — guard: widget may have been disposed during initialize()
    if (_disposed || !mounted) {
      await controller.dispose();
      return;
    }

    // Step 4 — configure (still using local ref)
    await controller.setLooping(true);
    await controller.setVolume(0);

    // Step 5 — final guard after the two awaits above
    if (_disposed || !mounted) {
      await controller.dispose();
      return;
    }

    // Step 6 — safe to assign; widget is alive, controller is fully ready
    _controller = controller;
    setState(() {});   // trigger first frame paint
    _syncPlayback();   // start playing if conditions are met
  }

  // ── Playback sync ──────────────────────────────────────────────────────────

  /// Single source of truth for play/pause decisions.
  /// Called on: init complete, visibility change, app lifecycle change.
  void _syncPlayback() {
    if (_disposed) return;                              // guard: widget dead
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;   // guard: not ready

    final shouldPlay = _isVisible && _isAppForeground;
    if (shouldPlay && !c.value.isPlaying) {
      c.play();
    } else if (!shouldPlay && c.value.isPlaying) {
      c.pause();
    }
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
    _disposed = true;                              // flip first — blocks any
    WidgetsBinding.instance.removeObserver(this); // in-flight callback from
    _controller?.dispose();                        // touching widget state
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
        child: ClipRect(                // hard clip — nothing leaks out
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ── 1. Black base — always present, zero GPU cost ────────────
              const ColoredBox(color: AppColors.black),

              // ── 2. Video ─────────────────────────────────────────────────
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

              // ── 3. Dark overlay (replaces ColorFiltered — no bleed) ──────
              if (videoReady)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x73000000), // ~45% black, no withOpacity()
                  ),
                ),

              // ── 4. Bottom gradient — text legibility only ────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 45.h * 0.45,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xB3000000)],
                      // 0xB3 = ~70% black
                    ),
                  ),
                ),
              ),

              // ── 5. Text — always on top, always readable ─────────────────
              Positioned(
                left: 4.w,
                right: 4.w,
                bottom: 3.h,
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
                        color: const Color(0xA6FAFAFA), // AppColors.white @ 65%
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
      ),
    );
  }
}