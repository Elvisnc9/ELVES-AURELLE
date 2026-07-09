/// ─────────────────────────────────────────────────────────────────────────────
/// payment_screen.dart
/// Payment method selection page.
/// Navigated to from CheckoutScreen when user taps "PLACE ORDER".
///
/// Payment options (UI containers only — wire handlers to your backend):
///   • Stripe      → onStripe()
///   • Paystack    → onPaystack()
///   • PayPal      → onPaypal()   (UI only, not active)
///   • Bank Card   → expands inline card entry form
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

// ── Payment method enum ───────────────────────────────────────────────────────

enum PaymentMethod { stripe, paystack, paypal, bankCard }

extension PaymentMethodInfo on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.stripe:   return 'Stripe';
      case PaymentMethod.paystack: return 'Paystack';
      case PaymentMethod.paypal:   return 'PayPal';
      case PaymentMethod.bankCard: return 'Bank Card';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.stripe:   return 'Pay securely with Stripe';
      case PaymentMethod.paystack: return 'Pay with Paystack — NGN supported';
      case PaymentMethod.paypal:   return 'Coming soon';
      case PaymentMethod.bankCard: return 'Visa · Mastercard · Verve';
    }
  }

  String get logoAsset {
    switch (this) {
      case PaymentMethod.stripe:   return 'assets/logos/stripe_logo.png';
      case PaymentMethod.paystack: return 'assets/logos/paystack_logo.png';
      case PaymentMethod.paypal:   return 'assets/logos/paypal_logo.png';
      case PaymentMethod.bankCard: return 'assets/logos/card_logo.png';
    }
  }

  IconData get fallbackIcon {
    switch (this) {
      case PaymentMethod.stripe:   return Icons.flash_on_outlined;
      case PaymentMethod.paystack: return Icons.account_balance_outlined;
      case PaymentMethod.paypal:   return Icons.language_outlined;
      case PaymentMethod.bankCard: return Icons.credit_card_outlined;
    }
  }

  bool get isDisabled => this == PaymentMethod.paypal;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final _selectedPaymentProvider =
    StateProvider<PaymentMethod?>((ref) => null);

final _cardExpandedProvider = StateProvider<bool>((ref) => false);

// ── Screen ────────────────────────────────────────────────────────────────────

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({
    super.key,
    required this.orderTotal,
  });

  final double orderTotal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedPaymentProvider);
    final canPay = selected != null && !selected.isDisabled;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            _TopBar(),
            _Hairline(),

            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [

                  // Heading
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAYMENT',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 32.dp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            'Select how you\'d like to pay',
                            style: GoogleFonts.inter(
                              fontSize: 12.dp,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                  // Order total pill
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _OrderTotalRow(total: orderTotal),
                    ).animate().fadeIn(delay: 60.ms, duration: 300.ms),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 2.5.h)),
                  SliverToBoxAdapter(
                    child: Container(height: 0.5, color: AppColors.divider),
                  ),

                  // Payment options
                  SliverList(
                    delegate: SliverChildListDelegate([
                      ...PaymentMethod.values.asMap().entries.map((entry) {
                        final i = entry.key;
                        final method = entry.value;
                        final delay = Duration(milliseconds: 100 + (i * 60));

                        if (method == PaymentMethod.bankCard) {
                          return _BankCardTile(
                            selected: selected == method,
                            onTap: () => ref
                                .read(_selectedPaymentProvider.notifier)
                                .state = method,
                          )
                              .animate()
                              .fadeIn(delay: delay, duration: 300.ms)
                              .slideY(
                                begin: 0.03,
                                end: 0,
                                delay: delay,
                                duration: 280.ms,
                                curve: Curves.easeOutCubic,
                              );
                        }

                        return _PaymentTile(
                          method: method,
                          selected: selected == method,
                          onTap: method.isDisabled
                              ? null
                              : () => ref
                                  .read(_selectedPaymentProvider.notifier)
                                  .state = method,
                        )
                            .animate()
                            .fadeIn(delay: delay, duration: 300.ms)
                            .slideY(
                              begin: 0.03,
                              end: 0,
                              delay: delay,
                              duration: 280.ms,
                              curve: Curves.easeOutCubic,
                            );
                      }),
                    ]),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 4.h)),
                ],
              ),
            ),

            // ── Confirm button ───────────────────────────────────────────
            _ConfirmButton(
              enabled: canPay,
              total: orderTotal,
              onTap: () {
                final method = ref.read(_selectedPaymentProvider);
                if (method == null) return;
                switch (method) {
                  case PaymentMethod.stripe:
                    // 🔁 StripeService.pay(orderTotal)
                    break;
                  case PaymentMethod.paystack:
                    // 🔁 PaystackService.pay(orderTotal)
                    break;
                  case PaymentMethod.bankCard:
                    // 🔁 StripeService.payWithCard(cardDetails)
                    break;
                  case PaymentMethod.paypal:
                    break;
                }
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 11.sp,
          letterSpacing: 1.6,
        );
    return SizedBox(
      height: 6.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(1.w),
                child: Icon(Icons.arrow_back,
                    size: 20.dp, color: AppColors.lightTextPrimary),
              ),
            ),
            Text('SECURE PAYMENT', style: style),
            Icon(Icons.lock_outline,
                size: 16.dp, color: AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order total row
// ─────────────────────────────────────────────────────────────────────────────
class _OrderTotalRow extends StatelessWidget {
  const _OrderTotalRow({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GoogleFonts.inter(
          fontSize: 12.dp,
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w500,
        ).let((style) => Text('Amount due', style: style)),
        GoogleFonts.cormorantGaramond(
          fontSize: 22.dp,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
        ).let((style) => Text(
              '\$${total.toStringAsFixed(2)} USD',
              style: style,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Standard payment tile (Stripe, Paystack, PayPal)
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = method.isDisabled;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.black.withOpacity(0.03)
                : Colors.transparent,
            border: selected
                ? const Border(
                    left: BorderSide(color: AppColors.black, width: 2),
                  )
                : const Border(
                    left: BorderSide(color: Colors.transparent, width: 2),
                  ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 4.w, vertical: 2.2.h),
                child: Row(
                  children: [
                    // Logo
                    SizedBox(
                      width: 11.w,
                      height: 11.w,
                      child: Image.asset(
                        method.logoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          method.fallbackIcon,
                          size: 22.dp,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Label + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.label,
                            style: GoogleFonts.inter(
                              fontSize: 13.dp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            method.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 11.dp,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? AppColors.black
                              : AppColors.lightTextSecondary,
                          width: selected ? 5 : 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _Hairline(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bank card tile — expands to show inline card form when selected
// ─────────────────────────────────────────────────────────────────────────────
class _BankCardTile extends ConsumerWidget {
  const _BankCardTile({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.black.withOpacity(0.03)
                : Colors.transparent,
            border: selected
                ? const Border(
                    left: BorderSide(color: AppColors.black, width: 2),
                  )
                : const Border(
                    left: BorderSide(color: Colors.transparent, width: 2),
                  ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 4.w, vertical: 2.2.h),
              child: Row(
                children: [
                  // Logo
                  SizedBox(
                    width: 11.w,
                    height: 11.w,
                    child: Image.asset(
                      PaymentMethod.bankCard.logoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.credit_card_outlined,
                        size: 22.dp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank Card',
                          style: GoogleFonts.inter(
                            fontSize: 13.dp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          'Visa · Mastercard · Verve',
                          style: GoogleFonts.inter(
                            fontSize: 11.dp,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.black
                            : AppColors.lightTextSecondary,
                        width: selected ? 5 : 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Inline card form — expands when bank card is selected ──────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: selected
              ? const _CardForm()
              : const SizedBox.shrink(),
        ),

        _Hairline(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline card entry form
// ─────────────────────────────────────────────────────────────────────────────
class _CardForm extends StatelessWidget {
  const _CardForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.5.h),

          // Card number
          _CardField(
            label: 'CARD NUMBER',
            hint: '0000  0000  0000  0000',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Expiry + CVV row
          Row(
            children: [
              Expanded(
                child: _CardField(
                  label: 'EXPIRY',
                  hint: 'MM / YY',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _CardField(
                  label: 'CVV',
                  hint: '•••',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Cardholder name
          _CardField(
            label: 'CARDHOLDER NAME',
            hint: 'As it appears on card',
            keyboardType: TextInputType.name,
          ),

          SizedBox(height: 1.h),

          // Secure note
          Row(
            children: [
              Icon(Icons.lock_outline,
                  size: 11.dp, color: AppColors.lightTextSecondary),
              SizedBox(width: 1.w),
              Text(
                'Your card details are encrypted and secure.',
                style: GoogleFonts.inter(
                  fontSize: 10.dp,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card form field — sharp corners, consistent with app style
// ─────────────────────────────────────────────────────────────────────────────
class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.dp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 0.6.h),
        TextField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          style: GoogleFonts.inter(
            fontSize: 13.dp,
            color: AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 13.dp,
              color: AppColors.lightTextSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppColors.lightSurface,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.6.h),
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
              borderSide:
                  BorderSide(color: AppColors.lightTextPrimary, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky confirm button
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.enabled,
    required this.total,
    required this.onTap,
  });

  final bool enabled;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding:  EdgeInsets.all(2.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 7.h,
          color: enabled ? AppColors.black : AppColors.black.withOpacity(0.25),
          alignment: Alignment.center,
          child: Text(
            enabled
                ? 'PAY  \$${total.toStringAsFixed(2)}'
                : 'SELECT A PAYMENT METHOD',
            style: GoogleFonts.inter(
              fontSize: 12.dp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input formatters
// ─────────────────────────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(digits[i]);
    }
    final string = buffer.toString();
    return next.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '').replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write(' / ');
      buffer.write(digits[i]);
    }
    final string = buffer.toString();
    return next.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared hairline
// ─────────────────────────────────────────────────────────────────────────────
class _Hairline extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: AppColors.divider);
}

// Extension to allow .let() chaining for TextStyle
extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}