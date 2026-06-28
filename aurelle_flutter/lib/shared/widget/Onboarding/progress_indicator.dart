import 'package:flutter/material.dart';

/// Thin segmented progress bar — one filled segment per completed/active step.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentStep, // 0-indexed
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActiveOrPast = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
            height: 3,
            decoration: BoxDecoration(
              color: isActiveOrPast ? Colors.black : const Color(0xFFE5E1DA),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}