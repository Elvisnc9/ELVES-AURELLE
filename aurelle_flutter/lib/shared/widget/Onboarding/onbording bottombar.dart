import 'package:flutter/material.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// OnboardingBottomBar
/// Shared bottom action area for all 3 pages — counter pill (optional),
/// skip link (optional), and the primary button. Kept as one widget so
/// button styling/spacing never drifts between pages.
/// ─────────────────────────────────────────────────────────────────────────
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
    this.counterText,
    this.onSkip,
    this.enabled = true,
  });

  final String buttonLabel;
  final VoidCallback onPressed;
  final String? counterText;
  final VoidCallback? onSkip;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (counterText != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDE7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                counterText!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (onSkip != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextButton(
              onPressed: onSkip,
              child: const Text(
                'Skip for now',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ),
          ),
           SizedBox(height: 4),
        ],
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              disabledBackgroundColor: Colors.black26,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  buttonLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}