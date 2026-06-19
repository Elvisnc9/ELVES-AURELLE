import 'package:aurelle_flutter/core/navigation/approutes.dart';
import 'package:flutter/material.dart';

/// Describes a single bottom-navigation destination.
/// Keep this as a plain data class — no BuildContext dependency.
class ShellNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
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
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    rootPath: AppRoutes.home,
  ),
  ShellNavItem(
    label: 'Shop',
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view,
    rootPath: AppRoutes.shop,
  ),
  ShellNavItem(
    label: 'Cart',
    icon: Icons.shopping_bag_outlined,
    activeIcon: Icons.shopping_bag,
    rootPath: AppRoutes.cart,
  ),
  ShellNavItem(
    label: 'Profile',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    rootPath: AppRoutes.profile,
  ),
];