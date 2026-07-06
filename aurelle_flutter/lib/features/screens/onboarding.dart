import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/onboarding_model.dart';
import 'package:aurelle_flutter/features/provider/onboarding_provider.dart';
import 'package:aurelle_flutter/shared/widget/Onboarding/Image%20_card.dart';
import 'package:aurelle_flutter/shared/widget/Onboarding/brand_tile.dart';
import 'package:aurelle_flutter/shared/widget/Onboarding/onbording%20bottombar.dart';
import 'package:aurelle_flutter/shared/widget/Onboarding/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  static const int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    ref.read(onboardingProvider.notifier).goToPage(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _completeOnboarding() => context.go('/home');

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(3.w, 2.h, 4.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: state.currentPage > 0
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 20.dp,
                                  color: AppColors.lightTextPrimary,
                                ),
                                onPressed: () =>
                                    _goToStep(state.currentPage - 1),
                              )
                            : null,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'STEP ${state.currentPage + 1} OF $_totalSteps',
                        style: GoogleFonts.inter(
                          fontSize: 11.dp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: const Color(0xFFC9A86A), // gold
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  OnboardingProgress(
                    currentStep: state.currentPage,
                    totalSteps: _totalSteps,
                  ),
                ],
              ),
            ),

            // ── Page content ───────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                // FIXED: was BouncingScrollPhysics — users could swipe past
                // validation. NeverScrollable locks navigation to buttons only.
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) =>
                    ref.read(onboardingProvider.notifier).goToPage(index),
                children: const [
                  StyleIdentityPage(),
                  BrandSelectionPage(),
                  DiscoveryPreferencePage(),
                ],
              ),
            ),

            // ── Bottom bar ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
              child: _buildBottomBar(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(OnboardingState state) {
    switch (state.currentPage) {
      case 0:
        return OnboardingBottomBar(
          counterText: '${state.selectedStyles.length} of 3 selected',
          buttonLabel: 'NEXT',
          enabled: state.canProceedFromStyle,
          onPressed: () => _goToStep(1),
        );
      case 1:
        return OnboardingBottomBar(
          buttonLabel: 'NEXT',
          onSkip: () => _goToStep(2),
          onPressed: () => _goToStep(2),
        );
      case 2:
        return OnboardingBottomBar(
          counterText: '${state.selectedDiscovery.length} of 2 selected',
          buttonLabel: 'CONTINUE',
          enabled: state.canProceedFromDiscovery,
          onPressed: _completeOnboarding,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StyleIdentityPage
// ─────────────────────────────────────────────────────────────────────────────
class StyleIdentityPage extends ConsumerWidget {
  const StyleIdentityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).selectedStyles;
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your Style Identity?",
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26.dp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            'Select 2–3 aesthetics that resonate with you.',
            style: GoogleFonts.inter(
              fontSize: 12.dp,
              fontWeight: FontWeight.w400,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: styleOptions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0,
              crossAxisSpacing: 3.w,
              mainAxisExtent: 30.h,
            ),
            itemBuilder: (context, index) {
              final option = styleOptions[index];
              return OverlapImageCard(
                imageAsset: option.imageAsset,
                label: option.label,
                selected: selected.contains(option.id),
                onTap: () => notifier.toggleStyle(option.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BrandSelectionPage
// ─────────────────────────────────────────────────────────────────────────────
class BrandSelectionPage extends ConsumerStatefulWidget {
  const BrandSelectionPage({super.key});

  @override
  ConsumerState<BrandSelectionPage> createState() => _BrandSelectionPageState();
}

class _BrandSelectionPageState extends ConsumerState<BrandSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, ) {
    final selected = ref.watch(onboardingProvider).selectedBrands;
    final notifier = ref.read(onboardingProvider.notifier);

    final filtered = _query.isEmpty
        ? brandOptions
        : brandOptions
            .where((b) =>
                b.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your favorite brands',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26.dp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            'Pick the brands you love. You can skip this.',
            style: GoogleFonts.inter(
              fontSize: 12.dp,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 2.h),

          // ── Search — sharp corners to match app style ─────────────
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            style: GoogleFonts.inter(fontSize: 13.dp),
            decoration: InputDecoration(
              hintText: 'Search brands...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13.dp,
                color: AppColors.lightTextSecondary,
              ),
              prefixIcon: Icon(Icons.search, size: 18.dp),
              filled: true,
              fillColor: AppColors.lightSurface,
              contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
              // FIXED: sharp border corners to match app-wide style
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFE0DDD8)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFE0DDD8), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                    color: AppColors.lightTextPrimary, width: 1),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // ── Brand grid — FIXED: 4 columns (was 2) ─────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final brand = filtered[index];
              return BrandTile(
                logoAsset: brand.logoAsset,
                name: brand.name,
                selected: selected.contains(brand.id),
                onTap: () => notifier.toggleBrand(brand.id),
              );
            },
          ),

          if (filtered.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Center(
                child: Text(
                  'No brands match your search.',
                  style: GoogleFonts.inter(
                    fontSize: 12.dp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DiscoveryPreferencePage
// ─────────────────────────────────────────────────────────────────────────────
class DiscoveryPreferencePage extends ConsumerWidget {
  const DiscoveryPreferencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).selectedDiscovery;
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you like to discover?',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26.dp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 0.6.h),
          Text(
            "We'll tune your feed to match. Pick 1–2.",
            style: GoogleFonts.inter(
              fontSize: 12.dp,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: discoveryOptions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0,
              crossAxisSpacing: 3.w,
              mainAxisExtent: 30.h,
            ),
            itemBuilder: (context, index) {
              final option = discoveryOptions[index];
              return OverlapImageCard(
                imageAsset: option.imageAsset,
                label: option.label,
                selected: selected.contains(option.id),
                onTap: () => notifier.toggleDiscovery(option.id),
              );
            },
          ),
        ],
      ),
    );
  }
}