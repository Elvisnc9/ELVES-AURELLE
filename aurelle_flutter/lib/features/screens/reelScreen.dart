/// ─────────────────────────────────────────────────────────────────────────────
/// reels_screen.dart
/// Full-screen vertical reel feed.
///
/// Layout (bottom → top in Stack):
///   1. PageView (vertical swipe, full screen)
///      └─ Each page: _ReelPage (video background)
///   2. AURELLE wordmark + share (top bar) — always on top
///   3. Right action sidebar (like, comment, save)
///   4. Product card — always visible, fades on video tap
///
/// Rules:
///   ✅ Zero logic — all state from reelsProvider
///   ✅ All colours from AppColors
///   ✅ All sizing via .w / .h / .sp
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:aurelle_flutter/features/provider/reels_provider.dart';
import 'package:aurelle_flutter/shared/widget/Reels/action_sidebar.dart';
import 'package:aurelle_flutter/shared/widget/Reels/product_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';
import 'package:video_player/video_player.dart';


class ReelsScreen extends ConsumerWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reelsProvider);
    final notifier = ref.read(reelsProvider.notifier);

    // Full-screen immersive — hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    if (state.reels.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Text(
            'No reels yet',
            style: GoogleFonts.inter(color: AppColors.white),
          ),
        ),
      );
    }

    final currentReel = state.currentReel!;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [

          // ── 1. Vertical paging reel feed ───────────────────────────────
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: state.reels.length,
            onPageChanged: notifier.onPageChanged,
            itemBuilder: (context, index) {
              return _ReelPage(
                reel: state.reels[index],
                isActive: index == state.currentIndex,
                onTap: notifier.toggleCard,
              );
            },
          ),

          // ── 2. Top bar: wordmark + share ───────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 4.w, vertical: 1.5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AURELLE',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.0,
                        color: AppColors.white,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 8),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // 🔁 Wire to share sheet
                      },
                      child: Icon(
                        Icons.share_outlined,
                        color: AppColors.white,
                        size: 22.sp,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Right action sidebar ────────────────────────────────────
          // Positioned(
          //   right: 3.w,
          //   bottom: 42.h, // sits above the product card
          //   child: ReelsActionsSidebar(
          //     isLiked: currentReel.isLiked,
          //     isSaved: currentReel.isSaved,
          //     likeCount: currentReel.likes,
          //     commentCount: currentReel.comments,
          //     onLike: () => notifier.toggleLike(currentReel.id),
          //     onSave: () => notifier.toggleSave(currentReel.id),
          //     onComment: () {
          //       // 🔁 Wire to comments bottom sheet
          //     },
          //     onShare: () {
          //       // 🔁 Wire to share sheet
          //     },
          //   ),
          // ),

          // ── 4. Product card — always visible, fades on tap ────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.h,
            child: ReelsProductCard(
              product: currentReel.product,
              selectedSizeIndex: state.selectedSizeIndex,
              selectedColorIndex: state.selectedColorIndex,
              visible: state.cardVisible,
              onSizeSelected: notifier.selectSize,
              onColorSelected: notifier.selectColor,
              onAddToCart: () {
                // 🔁 Wire to cart provider
              },
              onBuyNow: () {
                // 🔁 Wire to checkout flow
              },
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReelPage — single reel: video background + tap-to-toggle card
// Uses same safe async init pattern as HeroBanner
// ─────────────────────────────────────────────────────────────────────────────
class _ReelPage extends StatefulWidget {
  const _ReelPage({
    required this.reel,
    required this.isActive,
    required this.onTap,
  });

  final ReelModel reel;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _disposed = false;
  bool _isAppForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  Future<void> _initController() async {
    final asset = widget.reel.videoAsset;
    if (asset == null || asset.isEmpty) return;

    final controller = VideoPlayerController.asset(asset);

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
    if (mounted) setState(() {});
    _syncPlayback();
  }

  void _syncPlayback() {
    if (_disposed) return;
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    final shouldPlay = widget.isActive && _isAppForeground;
    if (shouldPlay && !c.value.isPlaying) {
      c.play();
    } else if (!shouldPlay && c.value.isPlaying) {
      c.pause();
    }
  }

  @override
  void didUpdateWidget(_ReelPage old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) _syncPlayback();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppForeground = state == AppLifecycleState.resumed;
    _syncPlayback();
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
    final controller = _controller;
    final videoReady = controller != null && controller.value.isInitialized;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox.expand(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Black base
              const ColoredBox(color: AppColors.black),

              // Video
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

              // Gradient: darken top and bottom for readability
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000), // top ~40%
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x55000000), // bottom ~33% — light enough nav reads transparent
                    ],
                    stops: [0.0, 0.25, 0.55, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}