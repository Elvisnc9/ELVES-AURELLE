/// ─────────────────────────────────────────────────────────────────────────────
/// reels_screen.dart
/// Architecture:
///   Vertical PageView (swipe up/down = next/prev reel)
///     └─ _ReelEntry  
///          └─ Horizontal PageView
///               Page 0: _ReelVideoPage (video + gradient + ReelsOverlay)
///               Page 1: ProductDetailScreen (from ReelModel data)
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:aurelle_flutter/features/provider/product_detail_provider.dart';
import 'package:aurelle_flutter/features/provider/reels_provider.dart';
import 'package:aurelle_flutter/features/screens/productScreen.dart';
import 'package:aurelle_flutter/shared/widget/reels/reels_overlay.dart';
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: state.reels.length,
        onPageChanged: notifier.onPageChanged,
        itemBuilder: (context, index) {
          return _ReelEntry(
            reel: state.reels[index],
            isActive: index == state.currentIndex,
            cardVisible: state.cardVisible,
            onCardTap: notifier.toggleCard,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReelEntry — horizontal PageView: video page + product detail page
// ─────────────────────────────────────────────────────────────────────────────
class _ReelEntry extends ConsumerStatefulWidget {
  const _ReelEntry({
    required this.reel,
    required this.isActive,
    required this.cardVisible,
    required this.onCardTap,
  });

  final ReelModel reel;
  final bool isActive;
  final bool cardVisible;
  final VoidCallback onCardTap;

  @override
  ConsumerState<_ReelEntry> createState() => _ReelEntryState();
}

class _ReelEntryState extends ConsumerState<_ReelEntry> {
  late final PageController _hPageController;
  bool _onProductPage = false;

  @override
  void initState() {
    super.initState();
    _hPageController = PageController();
    _hPageController.addListener(() {
      final onProduct = (_hPageController.page ?? 0) > 0.5;
      if (onProduct != _onProductPage) {
        setState(() => _onProductPage = onProduct);
        SystemChrome.setEnabledSystemUIMode(
          onProduct ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
        );
      }
    });
  }

  @override
  void dispose() {
    _hPageController.dispose();
    super.dispose();
  }

  void _goToProductPage() {
    _hPageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _hPageController,
      scrollDirection: Axis.horizontal,
      children: [
        // Page 0: Video + overlay
        _ReelVideoPage(
          reel: widget.reel,
          isActive: widget.isActive && !_onProductPage,
          cardVisible: widget.cardVisible,
          onCardTap: widget.onCardTap,
          onViewProduct: _goToProductPage,
        ),

        // Page 1: ProductDetailScreen fed from reel data
        ProviderScope(
          overrides: [
            productDetailProvider(widget.reel.id).overrideWith(
              (ref) {
                final reel = ref.watch(reelsProvider).reels.firstWhere(
                  (r) => r.id == widget.reel.id,
                );
                return ReelProductDetailNotifier(reel);
              },
            ),
          ],
          child: ProductDetailScreen(productId: widget.reel.id),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReelVideoPage — full screen video + gradient + overlay UI
// ─────────────────────────────────────────────────────────────────────────────
class _ReelVideoPage extends StatefulWidget {
  const _ReelVideoPage({
    required this.reel,
    required this.isActive,
    required this.cardVisible,
    required this.onCardTap,
    required this.onViewProduct,
  });

  final ReelModel reel;
  final bool isActive;
  final bool cardVisible;
  final VoidCallback onCardTap;
  final VoidCallback onViewProduct;

  @override
  State<_ReelVideoPage> createState() => _ReelVideoPageState();
}

class _ReelVideoPageState extends State<_ReelVideoPage>
    with WidgetsBindingObserver {
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
    if (_disposed || !mounted) { await controller.dispose(); return; }
    await controller.setLooping(true);
    await controller.setVolume(0);
    if (_disposed || !mounted) { await controller.dispose(); return; }
    _controller = controller;
    if (mounted) setState(() {});
    _syncPlayback();
  }

  void _syncPlayback() {
    if (_disposed) return;
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final shouldPlay = widget.isActive && _isAppForeground;
    if (shouldPlay && !c.value.isPlaying) c.play();
    else if (!shouldPlay && c.value.isPlaying) c.pause();
  }

  @override
  void didUpdateWidget(_ReelVideoPage old) {
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
      onTap: widget.onCardTap,
      child: SizedBox.expand(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ── Video ───────────────────────────────────────────────────
              const ColoredBox(color: AppColors.black),
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

              // ── Gradient — heavier at bottom for overlay legibility ──────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x44000000), // top — light for top bar
                      Colors.transparent,
                      Color(0x88000000), // mid fade
                      Color(0xDD000000), // bottom — heavy for overlay text
                    ],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // ── Top bar: AURELLE · three-dot ────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AURELLE',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.5,
                            color: AppColors.white,
                          ),
                        ),
                        Icon(
                          Icons.more_vert,
                          color: AppColors.white,
                          size: 22.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Overlay — sits above nav bar ────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: kBottomNavigationBarHeight.toDouble() + 1.h,
                child: ReelsOverlay(
                  reel: widget.reel,
                  visible: widget.cardVisible,
                  onViewProduct: widget.onViewProduct,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}