import 'package:flutter/material.dart';

class NavItem {
  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSecondary;
  final bool isEmergency;

  const NavItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.isSecondary = false,
    this.isEmergency = false,
  });
}

class AppNavItems {
  static const List<NavItem> primaryItems = [
    NavItem(
      index: 0,
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    NavItem(
      index: 1,
      label: 'Secure Chat',
      icon: Icons.chat_bubble_outline_rounded,
      selectedIcon: Icons.chat_bubble_rounded,
    ),
    NavItem(
      index: 2,
      label: 'Files',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder_rounded,
    ),
    NavItem(
      index: 3,
      label: 'Calls',
      icon: Icons.call_outlined,
      selectedIcon: Icons.call_rounded,
    ),
    NavItem(
      index: 4,
      label: 'Security',
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield_rounded,
    ),
    NavItem(
      index: 5,
      label: 'Personnel',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
    ),
    NavItem(
      index: 6,
      label: 'Live Location',
      icon: Icons.location_on_outlined,
      selectedIcon: Icons.location_on_rounded,
    ),
    NavItem(
      index: 7,
      label: 'Emergency SOS',
      icon: Icons.warning_amber_rounded,
      selectedIcon: Icons.warning_rounded,
      isEmergency: true,
    ),
  ];

  static const List<NavItem> secondaryItems = [
    NavItem(
      index: 8,
      label: 'AI Assistant',
      icon: Icons.smart_toy_outlined,
      selectedIcon: Icons.smart_toy_rounded,
      isSecondary: true,
    ),
    NavItem(
      index: 9,
      label: 'Audit Logs',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      isSecondary: true,
    ),
    NavItem(
      index: 10,
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      isSecondary: true,
    ),
    NavItem(
      index: 11,
      label: 'Devices',
      icon: Icons.devices_outlined,
      selectedIcon: Icons.devices_rounded,
      isSecondary: true,
    ),
    NavItem(
      index: 12,
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      isSecondary: true,
    ),
  ];
}
