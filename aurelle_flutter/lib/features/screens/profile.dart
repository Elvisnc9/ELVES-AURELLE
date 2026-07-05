import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/navigation/approutes.dart';

// ───────────────────────────────────────────────────────────────────────────
// ProfileScreen
// SSENSE-inspired editorial profile page.
// Two states: unauthenticated (Login / Register CTAs) and authenticated
// (user name + email header). Auth state is stubbed via a simple bool —
// swap for your real authProvider when auth is wired.
// ────────────────────────────────────────────────────────────────────────────
// ── Stub — replace with real auth provider ──────────────────────────────────
final _isLoggedInProvider = StateProvider<bool>((ref) => false);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(_isLoggedInProvider);

    return  SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
           children: [


             Text(
                      'AURELLE',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.0,
                        color: AppColors.black,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 8),
                        ],
                      ),
                    ),


                    SizedBox(height: 3.h),
            // ── Auth section ────────────────────────────────────────────────
            isLoggedIn
                ? _AuthenticatedHeader()
                : _UnauthenticatedHeader(),

            SizedBox(height: 3.h),

            // ── Settings section ────────────────────────────────────────────
            _SectionLabel('SETTINGS'),
            _ProfileMenuItem(
              label: 'Shop Preference — Womenswear',
              onTap: () {},
            ),
            _ProfileMenuItem(
              label: 'Notifications',
              onTap: () {},
            ),
            _ProfileMenuItem(
              label: 'Location Services',
              onTap: () {},
            ),
            _ProfileMenuItem(
              label: 'Country/Region — Nigeria',
              onTap: () {},
            ),

            SizedBox(height: 3.h),

            // ── Orders section (only when logged in) ────────────────────────
            if (isLoggedIn) ...[
              _SectionLabel('ORDERS'),
              _ProfileMenuItem(
                label: 'My Orders',
                onTap: () => context.push('/${AppRoutes.orders}'),
              ),
              _ProfileMenuItem(
                label: 'Wishlist',
                onTap: () {},
              ),
              SizedBox(height: 3.h),
            ],

            // ── Support section ─────────────────────────────────────────────
            _SectionLabel('SUPPORT'),
            _ProfileMenuItem(
              label: 'Contact Us',
              isExternalLink: true,
              onTap: () {},
            ),
            _ProfileMenuItem(
              label: 'Help and Information',
              isExternalLink: true,
              onTap: () {},
            ),
            _ProfileMenuItem(
              label: 'Privacy Policy',
              isExternalLink: true,
              onTap: () => context.push('/${AppRoutes.qa}'),
            ),
            _ProfileMenuItem(
              label: 'Terms & Conditions',
              isExternalLink: true,
              onTap: () {},
            ),

            SizedBox(height: 4.h),

            // ── Logout (only when logged in) ────────────────────────────────
            if (isLoggedIn)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: TextButton(
                  onPressed: () {
                    ref.read(_isLoggedInProvider.notifier).state = false;
                  },
                  child: Text(
                    'LOG OUT',
                    style: TextStyle(
                      fontSize: 12.dp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 2.h),

            // ── App version ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                'VERSION 1.0.0',
                style: TextStyle(
                  fontSize: 10.dp,
                  color: Colors.black38,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
  
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _UnauthenticatedHeader
// Shown when the user is not logged in — mirrors SSENSE's pattern exactly:
// a single line of copy, then LOGIN (filled) / REGISTER (ghost) side by side.
// ─────────────────────────────────────────────────────────────────────────────
class _UnauthenticatedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To use your profile, please login or create an account.',
          style: GoogleFonts.inter(
            fontSize: 13.dp,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            // LOGIN — filled black
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // editorial: sharp corners
                    ),
                  ),
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 12.dp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // REGISTER — ghost/text
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutes.signup),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide.none, // no border — pure text like SSENSE
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 12.dp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AuthenticatedHeader
// Shown when logged in — user name + email in the editorial style.
// ─────────────────────────────────────────────────────────────────────────────
class _AuthenticatedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HELLO,',
          style: TextStyle(
            fontSize: 11.dp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: Colors.black45,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Jane Doe', // swap with real user name
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28.dp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Text(
          'jane@email.com', // swap with real email
          style: GoogleFonts.inter(
            fontSize: 12.dp,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionLabel
// Bold all-caps section header — same style as SSENSE "SETTINGS", "SUPPORT"
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.dp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileMenuItem
// A full-width tappable row with a label and a trailing icon.
// isExternalLink = true → shows a diagonal arrow (↗) like SSENSE's Support rows.
// isExternalLink = false → shows a chevron (›) for internal navigation.
// Separated by a thin divider, exactly like the reference.
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.label,
    required this.onTap,
    this.isExternalLink = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isExternalLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13.dp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  isExternalLink
                      ? Icons.north_east   // ↗ for external links
                      : Icons.chevron_right, // › for internal nav
                  size: 16.dp,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0EDE7)),
      ],
    );
  }
}