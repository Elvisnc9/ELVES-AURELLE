import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:flutter/material.dart';

/// Describes a single bottom-navigation destination.
/// Keep this as a plain data class — no BuildContext dependency.
class ShellNavItem {
  final String label;
  final String icon;
  final String activeIcon;
  final String rootPath; // the tab's root route path

  const ShellNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.rootPath,
  });
}

/// Single source of truth for the tab order.
/// Change order here and the whole app follows.
const List<ShellNavItem> shellNavItems = [
  ShellNavItem(
    label: 'Home',
    icon: 'assets/icon/home.png',
    activeIcon: 'assets/icon/home_filled.png',
    rootPath: AppRoutes.home,
  ),
  ShellNavItem(
    label: 'Shop',
    icon: 'assets/icon/shopping-cart.png',
    activeIcon: 'assets/icon/shopping-cart_filled.png',
    rootPath: AppRoutes.shop,
  ),
    ShellNavItem(
    label: 'Reels',
    icon: 'assets/icon/reel.png',
    activeIcon: 'assets/icon/reel_filled.png',
    rootPath: AppRoutes.reels,
  ),

  ShellNavItem(
    label: 'Profile',
    icon: 'assets/icon/user.png',
    activeIcon: 'assets/icon/user_filled.png',
    rootPath: AppRoutes.profile,
  ),
];