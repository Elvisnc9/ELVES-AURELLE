/// ─────────────────────────────────────────────────────────────────────────────
/// reels_screen.dart
///
/// Architecture (simplified):
///   Vertical PageView (swipe up/down = next/prev reel)
///     └─ _ReelEntry → _ReelVideoPage (full screen video + overlay)
///
/// "VIEW PRODUCT" tapped:
///   1. Write reel variant data → reelProductCacheProvider (keyed by variantId)
///   2. context.push(AppRoutes.productPath(variantId))
///   3. ProductDetailScreen reads from the cache via productDetailProvider
///
/// No horizontal PageView. No fromReels flag. Same ProductDetailScreen as Shop.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/reels_model.dart';
import 'package:aurelle_flutter/features/model/shop_model.dart';
import 'package:aurelle_flutter/features/provider/product_detail_provider.dart';
import 'package:aurelle_flutter/features/provider/reels_provider.dart';
import 'package:aurelle_flutter/shared/widget/Reels/brand_page.dart';
import 'package:aurelle_flutter/shared/widget/reels/reels_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          child: CircularProgressIndicator(
              color: AppColors.white, strokeWidth: 1.5),
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
// _ReelEntry
// Simple widget — no horizontal PageView, no complex state.
// "View Product" tap caches the reel's product data then pushes the shared
// ProductDetailScreen route.
// ─────────────────────────────────────────────────────────────────────────────
class _ReelEntry extends ConsumerWidget {
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

  void _onViewProduct(BuildContext context, WidgetRef ref) {
    final variant = reel.primaryVariant;

    // ── Write reel product data into the cache ───────────────────────────────
    // productDetailProvider will read this before attempting an API fetch,
    // so ProductDetailScreen gets populated instantly from reel data.
    final variants = reel.variants.map(reelVariantToProductVariant).toList();
    ref.read(reelProductCacheProvider.notifier).update((cache) => {
          ...cache,
          variant.id: ProductDetailState(
            variants: variants,
            isLoading: false,
          ),
        });

    // Restore system UI before navigating away from the immersive reel
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // ── Navigate to the shared ProductDetailScreen ───────────────────────────
    context.push(AppRoutes.productPath(variant.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ReelVideoPage(
      reel: reel,
      isActive: isActive,
      cardVisible: cardVisible,
      onCardTap: onCardTap,
      onViewProduct: () => _onViewProduct(context, ref),
      brandTap: () => BrandBottomSheet.show(   // ADD
    context,
    brand: reel.brand,
    onViewProducts: () => context.push(AppRoutes.shop),
  ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReelVideoPage — full screen video + gradient + overlay UI (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class _ReelVideoPage extends StatefulWidget {
  const _ReelVideoPage({
    required this.reel,
    required this.isActive,
    required this.cardVisible,
    required this.onCardTap,
    required this.onViewProduct, 
    required this.brandTap,
  });

  final ReelModel reel;
  final bool isActive;
  final bool cardVisible;
  final VoidCallback onCardTap;
  final VoidCallback onViewProduct;
  final VoidCallback brandTap;

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
    if (shouldPlay && !c.value.isPlaying)
      c.play();
    else if (!shouldPlay && c.value.isPlaying)
      c.pause();
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
              // ── Video ────────────────────────────────────────────────────
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

              // ── Gradient ─────────────────────────────────────────────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x44000000),
                      Colors.transparent,
                      Color(0x88000000),
                      Color(0xDD000000),
                    ],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // ── Top bar ──────────────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 1.8.h),
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
                        Icon(Icons.more_vert,
                            color: AppColors.white, size: 22.sp),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Overlay — product info + actions ─────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: kBottomNavigationBarHeight.toDouble() + 1.h,
                child: ReelsOverlay(
                  reel: widget.reel,
                  visible: widget.cardVisible,
                  onViewProduct: widget.onViewProduct,
                  onBrandTap: widget.brandTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}