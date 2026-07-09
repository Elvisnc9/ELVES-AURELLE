/// ─────────────────────────────────────────────────────────────────────────────
/// add_address_screen.dart
/// Form screen for adding a shipping address.
/// On SAVE ADDRESS → writes to addressProvider → pops back to CheckoutScreen
/// which reactively updates its SHIPPING row.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:aurelle_flutter/features/model/address_model.dart';
import 'package:aurelle_flutter/features/provider/address_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullName    = TextEditingController();
  final _phone       = TextEditingController();
  final _street1     = TextEditingController();
  final _street2     = TextEditingController();
  final _city        = TextEditingController();
  final _state       = TextEditingController();
  final _postal      = TextEditingController();
  final _country     = TextEditingController(text: 'Nigeria');

  @override
  void initState() {
    super.initState();
    // Pre-fill if an address already exists
    final existing = ref.read(addressProvider);
    if (existing != null) {
      _fullName.text = existing.fullName;
      _phone.text    = existing.phone;
      _street1.text  = existing.streetLine1;
      _street2.text  = existing.streetLine2 ?? '';
      _city.text     = existing.city;
      _state.text    = existing.state;
      _postal.text   = existing.postalCode;
      _country.text  = existing.country;
    }
  }

  @override
  void dispose() {
    _fullName.dispose(); _phone.dispose(); _street1.dispose();
    _street2.dispose();  _city.dispose();  _state.dispose();
    _postal.dispose();   _country.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(addressProvider.notifier).save(
      AddressModel(
        fullName:    _fullName.text.trim(),
        phone:       _phone.text.trim(),
        streetLine1: _street1.text.trim(),
        streetLine2: _street2.text.trim().isEmpty ? null : _street2.text.trim(),
        city:        _city.text.trim(),
        state:       _state.text.trim(),
        postalCode:  _postal.text.trim(),
        country:     _country.text.trim(),
      ),
    );

    if (context.canPop()) {
  context.pop();
} else {
  context.go(AppRoutes.checkout);
} // back to checkout — row updates reactively
  }

  @override
  Widget build(BuildContext context) {
    final existing = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            _TopBar(isEditing: existing != null),
            _Hairline(),

            // ── Form ───────────────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              existing != null
                                  ? 'Edit Address'
                                  : 'Add Address',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 30.dp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            SizedBox(height: 0.4.h),
                            Text(
                              'We\'ll deliver your order here.',
                              style: GoogleFonts.inter(
                                fontSize: 12.dp,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                    // ── Section: Personal ────────────────────────────
                    _sectionLabel('PERSONAL DETAILS'),

                    _formField(
                      controller: _fullName,
                      label: 'FULL NAME',
                      hint: 'Jane Doe',
                      delay: 60,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    _formField(
                      controller: _phone,
                      label: 'PHONE NUMBER',
                      hint: '+234 800 000 0000',
                      keyboardType: TextInputType.phone,
                      delay: 100,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                    // ── Section: Address ─────────────────────────────
                    _sectionLabel('DELIVERY ADDRESS'),

                    _formField(
                      controller: _street1,
                      label: 'STREET ADDRESS',
                      hint: '12 Banana Island Road',
                      delay: 140,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    _formField(
                      controller: _street2,
                      label: 'APARTMENT / SUITE (OPTIONAL)',
                      hint: 'Flat 4B',
                      delay: 180,
                    ),

                    _formField(
                      controller: _city,
                      label: 'CITY',
                      hint: 'Lagos',
                      delay: 220,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    // State + Postal in a row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _AddressField(
                                controller: _state,
                                label: 'STATE / REGION',
                                hint: 'Lagos State',
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              flex: 4,
                              child: _AddressField(
                                controller: _postal,
                                label: 'POSTAL CODE',
                                hint: '100001',
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                            delay: 260.ms, duration: 300.ms),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 1.5.h)),

                    _formField(
                      controller: _country,
                      label: 'COUNTRY',
                      hint: 'Nigeria',
                      delay: 300,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 2.h)),

                    // Clear address option if editing
                    if (existing != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: GestureDetector(
                            onTap: () {
                              ref.read(addressProvider.notifier).clear();
                              context.pop();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Text(
                                'Remove saved address',
                                style: GoogleFonts.inter(
                                  fontSize: 12.dp,
                                  color: const Color(0xFFCC0000),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(child: SizedBox(height: 4.h)),
                  ],
                ),
              ),
            ),

            // ── Save button ────────────────────────────────────────────
            _SaveButton(onTap: _save),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  SliverToBoxAdapter _sectionLabel(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.2.h),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.dp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _formField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int delay = 0,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.5.h),
        child: _AddressField(
          controller: controller,
          label: label,
          hint: hint,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 300.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable form field — sharp corners, consistent with payment screen fields
// ─────────────────────────────────────────────────────────────────────────────
class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
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
            errorStyle: GoogleFonts.inter(fontSize: 10.dp),
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
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Color(0xFFCC0000), width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Color(0xFFCC0000), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.isEditing});
  final bool isEditing;

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
             onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.checkout);
  }
},
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(1.w),
                child: Icon(Icons.arrow_back,
                    size: 20.dp, color: AppColors.lightTextPrimary),
              ),
            ),
            Text(
              isEditing ? 'EDIT ADDRESS' : 'ADD ADDRESS',
              style: style,
            ),
            SizedBox(width: 8.w), // balance
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save button
// ─────────────────────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(2.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 7.h,
          color: AppColors.black,
          alignment: Alignment.center,
          child: Text(
            'SAVE ADDRESS',
            style: GoogleFonts.inter(
              fontSize: 12.dp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hairline
// ─────────────────────────────────────────────────────────────────────────────
class _Hairline extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: AppColors.divider);
}