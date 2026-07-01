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
import 'package:the_responsive_builder/the_responsive_builder.dart';


/// ─────────────────────────────────────────────────────────────────────────
/// OnboardingScreen
/// ONE Scaffold for the entire 3-step flow. A PageView swaps the body;
/// the progress bar and bottom action bar live outside the PageView so
/// they never rebuild/flicker between steps — only their content updates
/// reactively via Riverpod.
///
/// PageController is NOT driven by user swipe gestures directly here —
/// physics is locked (NeverScrollableScrollPhysics) so navigation only
/// happens via the buttons, keeping selection validation enforceable
/// (can't swipe past an incomplete required step).
/// ─────────────────────────────────────────────────────────────────────────
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

  void _completeOnboarding() {
    context.go('/home');
  }

TextTheme get theme => Theme.of(context).textTheme;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: step label + progress bar ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                            SizedBox(
                      
                        height: 32,
                        child: state.currentPage > 0
                            ? IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.arrow_back, size: 28),
                                onPressed: () =>
                                    _goToStep(state.currentPage - 1),
                              )
                            : null,
                      ),

                      SizedBox(width: 1.w,),
                      Text(
                        'STEP ${state.currentPage + 1} OF $_totalSteps',
                        style:  theme.titleSmall
                      ),



                      
                    ],
                  ),
                   SizedBox(height: 2.h),
                  OnboardingProgress(
                    currentStep: state.currentPage,
                    totalSteps: _totalSteps,
                  ),
                ],
              ),
            ),

            // ── Page content ───────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) =>
                    ref.read(onboardingProvider.notifier).goToPage(index),
                children: const [
                  StyleIdentityPage(),
                  BrandSelectionPage(),
                  DiscoveryPreferencePage(),
                ],
              ),
            ),

            // ── Bottom action bar (per-step config) ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
          buttonLabel: 'Next',
          enabled: state.canProceedFromStyle,
          onPressed: () => _goToStep(1),
        );
      case 1:
        return OnboardingBottomBar(
          buttonLabel: 'Next',
          onSkip: () => _goToStep(2),
          onPressed: () => _goToStep(2),
        );
      case 2:
        return OnboardingBottomBar(
          counterText: '${state.selectedDiscovery.length} of 2 selected',
          buttonLabel: 'Continue',
          enabled: state.canProceedFromDiscovery,
          onPressed: _completeOnboarding,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}


class StyleIdentityPage extends ConsumerWidget {
  const StyleIdentityPage({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).selectedStyles;
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context).textTheme;
 
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "What's your Style Identity?",
            style: theme.titleMedium,
          ),
          const SizedBox(height: 6),
           Text(
            'Select 2–3 aesthetics that resonate with you.',
            style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w400, color: AppColors.lightTextSecondary) ),
        
           SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: styleOptions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0, // extra vertical room for the overflow
              crossAxisSpacing: 20,
              childAspectRatio: 0.78,
              mainAxisExtent: 30.h
            ),
            itemBuilder: (context, index) {
              final option = styleOptions[index];
              final isSelected = selected.contains(option.id);
              return OverlapImageCard(
                imageAsset: option.imageAsset,
                label: option.label,
                selected: isSelected,
                onTap: () => notifier.toggleStyle(option.id),
              );
            },
          ),
        ],
      ),
    );
  }
}


 
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
  Widget build(BuildContext context) {
    final selected = ref.watch(onboardingProvider).selectedBrands;
    final notifier = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context).textTheme;
 
    final filtered = _query.isEmpty
        ? brandOptions
        : brandOptions
            .where((b) => b.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();
 
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your favorite brands',
            style: theme.titleMedium,
          ),
          const SizedBox(height: 6),
           Text(
            'Pick the brands you love. You can skip this.',
            style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w400, color: AppColors.lightTextSecondary) 
          ),
           SizedBox(height: 2.h),
 
          // ── Search field ────────────────────────────────────────────────
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search brands...',
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
               
                borderSide:  BorderSide(color: AppColors.black, ),
              ),
              enabledBorder: OutlineInputBorder(
               
                borderSide: BorderSide(color: AppColors.black, width: 0.8),
              ),
             
            ),
          ),
          const SizedBox(height: 20),
 
          // ── Brand grid — 4 columns, flat single-container tiles ─────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final brand = filtered[index];
              final isSelected = selected.contains(brand.id);
              return BrandTile(
                logoAsset: brand.logoAsset,
                name: brand.name,
                selected: isSelected,
                onTap: () => notifier.toggleBrand(brand.id),
              );
            },
          ),
 
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'No brands match your search.',
                  style: TextStyle(color: Colors.black45, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
 
 

 class DiscoveryPreferencePage extends ConsumerWidget {
  const DiscoveryPreferencePage({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingProvider).selectedDiscovery;
    final notifier = ref.read(onboardingProvider.notifier);
        final theme = Theme.of(context).textTheme;

 
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'How do you like to discover?',
            style:   theme.titleMedium,
          ),
          const SizedBox(height: 6),
           Text(
            "We'll tune your feed to match. Pick 1–2.",
            style: theme.titleSmall?.copyWith(fontWeight: FontWeight.w400, color: AppColors.lightTextSecondary) 
          ),
         SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: discoveryOptions.length,
            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: 2,
              mainAxisSpacing: 0, // extra vertical room for the overflow
              crossAxisSpacing: 20,
              childAspectRatio: 0.78,
              mainAxisExtent: 30.h
            ),
            itemBuilder: (context, index) {
              final option = discoveryOptions[index];
              final isSelected = selected.contains(option.id);
              return OverlapImageCard(
                imageAsset: option.imageAsset,
                label: option.label,
                selected: isSelected,
                onTap: () => notifier.toggleDiscovery(option.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
 