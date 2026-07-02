import 'package:aurelle_flutter/core/navigation/shell_item.dart';
import 'package:aurelle_flutter/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';


// ─────────────────────────────────────────────────────────────────────────────
// AppShell
// The single persistent Scaffold. GoRouter's ShellRoute injects the active
// tab's widget tree via [child]. Only [child] re-renders on tab change —
// the Scaffold, bottom bar, and any persistent overlays stay alive.
// ─────────────────────────────────────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  /// The currently active tab's widget tree, provided by ShellRoute.
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // ── Index resolution ──────────────────────────────────────────────────────
  /// Map each tab's root path to its index for O(1) lookup.
  static final Map<String, int> _pathToIndex = {
    for (int i = 0; i < shellNavItems.length; i++)
      shellNavItems[i].rootPath: i,
  };

  /// Derive the selected index from the current route location.
  /// Works for both root paths (/shop) and nested paths (/shop/product/123).
  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    // Walk from most-specific to root: prefer the deepest match.
    for (final item in shellNavItems.reversed) {
      if (location.startsWith(item.rootPath)) {
        return _pathToIndex[item.rootPath]!;
      }
    }
    return 0; // default to Home
  }

  // ── Tab tap ───────────────────────────────────────────────────────────────
  void _onTap(BuildContext context, int index) {
    final targetPath = shellNavItems[index].rootPath;
    final currentLocation = GoRouterState.of(context).uri.toString();

    // Tapping the *active* tab while on a nested page pops back to root.
    // Tapping the *active* tab while already at root — no-op (no stack pop).
    if (currentLocation.startsWith(targetPath) &&
        currentLocation != targetPath) {
      context.go(targetPath); // pop nested back to tab root
    } else if (currentLocation != targetPath) {
      context.go(targetPath); // switch tab
    }
    // else: already at root of active tab — do nothing
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.toString();
    final isReels = location.startsWith('/reels');
    return Scaffold(

      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      
      // ── Body ──────────────────────────────────────────────────────────────
      // [child] is provided by ShellRoute — it's the active tab's subtree.
      // Using IndexedStack here would preserve tab state (scroll position,
      // form values, etc.) across tab switches at the cost of keeping all
      // trees alive. GoRouter's ShellRoute with simple `child` is lighter:
      // each tab is only built when active.
      //
      // ➡ If you need state preservation, wrap with _StatefulShellRoute
      //   (go_router 7+) which manages NavigatorStates per branch natively.
      body: widget.child,

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBar: _AurelleBottomNav(
        selectedIndex: selectedIndex,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AurelleBottomNav
// Isolated widget so you can swap the visual without touching shell logic.
// Slot in your existing custom bottom bar design here.
// ─────────────────────────────────────────────────────────────────────────────

class _AurelleBottomNav extends StatelessWidget {
  const _AurelleBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isReels = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── Drop-in zone ─────────────────────────────────────────────────────────
    // Replace this NavigationBar with YOUR existing bottom nav widget.
    // Just wire [selectedIndex] → your "active" prop and [onTap] → your
    // callback. The nav logic above stays unchanged.
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      // Luxury-app feel: no elevation, tight label style
      elevation: 0,
      backgroundColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: shellNavItems.map((item) {
        // ignore: unused_local_variable
        final isSelected = shellNavItems.indexOf(item) == selectedIndex;
        return NavigationDestination(
          icon: Image.asset(item.icon, height: isSelected? 3.h : 2.5.h, color: isReels? AppColors.lightBackground : null, ),
          label: item.label,
          tooltip: item.label,
        );
      }).toList(),
    );
  }
}