import 'package:aurelle_flutter/features/model/onboarding_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// ─────────────────────────────────────────────────────────────────────────
/// OnboardingState
/// Immutable snapshot of everything the 3-step flow needs. Kept as one
/// state object (not 3 separate providers) because the bottom bar's
/// "can proceed" logic needs to read the current page's selection set —
/// a single source of truth avoids cross-provider sync bugs.
/// ─────────────────────────────────────────────────────────────────────────
class OnboardingState {
  const OnboardingState({
    this.currentPage = 0,
    this.selectedStyles = const {},
    this.selectedBrands = const {},
    this.selectedDiscovery = const {},
  });

  final int currentPage;
  final Set<String> selectedStyles;
  final Set<String> selectedBrands;
  final Set<String> selectedDiscovery;

  OnboardingState copyWith({
    int? currentPage,
    Set<String>? selectedStyles,
    Set<String>? selectedBrands,
    Set<String>? selectedDiscovery,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      selectedStyles: selectedStyles ?? this.selectedStyles,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      selectedDiscovery: selectedDiscovery ?? this.selectedDiscovery,
    );
  }

  /// Page 0 (Style Identity) requires min 2 picks before "Next" is enabled.
  bool get canProceedFromStyle =>
      selectedStyles.length >= OnboardingLimits.minStyles;

  /// Page 1 (Brands) is always skippable — never blocks.
  bool get canProceedFromBrands => true;

  /// Page 2 (Discovery) requires at least 1 pick before "Continue".
  bool get canProceedFromDiscovery => selectedDiscovery.isNotEmpty;
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  // ── Style selection (max 3) ─────────────────────────────────────────────
  void toggleStyle(String id) {
    final current = Set<String>.from(state.selectedStyles);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      if (current.length >= OnboardingLimits.maxStyles) return; // ignore, at cap
      current.add(id);
    }
    state = state.copyWith(selectedStyles: current);
  }

  // ── Brand selection (no cap) ────────────────────────────────────────────
  void toggleBrand(String id) {
    final current = Set<String>.from(state.selectedBrands);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(selectedBrands: current);
  }

  // ── Discovery selection (max 2) ─────────────────────────────────────────
  void toggleDiscovery(String id) {
    final current = Set<String>.from(state.selectedDiscovery);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      if (current.length >= OnboardingLimits.maxDiscovery) return;
      current.add(id);
    }
    state = state.copyWith(selectedDiscovery: current);
  }

  // ── Page navigation ──────────────────────────────────────────────────────
  void goToPage(int index) => state = state.copyWith(currentPage: index);
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);