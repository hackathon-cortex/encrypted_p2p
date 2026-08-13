import 'package:flutter/material.dart';
import '../../core/navigation/navigation_models.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final user = appState.authService.currentUser;
    final isSos = appState.sosService.isSosActive;
    final unreadNotifs = appState.notificationService.unreadCount;
    final activeThreats = appState.securityService.activeThreats.length;

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Brand Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'CORTEX',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'P2P',
                              style: TextStyle(
                                color: AppColors.accentCyan,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Secure Command v1.0',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'PRIMARY COMMAND',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                ...AppNavItems.primaryItems.map((item) {
                  final isSelected = selectedIndex == item.index;
                  int? badgeCount;
                  Color? badgeColor;

                  if (item.index == 4 && activeThreats > 0) {
                    badgeCount = activeThreats;
                    badgeColor = AppColors.warning;
                  } else if (item.index == 7 && isSos) {
                    badgeCount = 1;
                    badgeColor = AppColors.critical;
                  }

                  return _SidebarTile(
                    item: item,
                    isSelected: isSelected,
                    badgeCount: badgeCount,
                    badgeColor: badgeColor,
                    onTap: () => onSelectIndex(item.index),
                  );
                }),

                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'SECURITY & SYSTEM',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                ...AppNavItems.secondaryItems.map((item) {
                  final isSelected = selectedIndex == item.index;
                  int? badgeCount;
                  if (item.index == 10 && unreadNotifs > 0) {
                    badgeCount = unreadNotifs;
                  }

                  return _SidebarTile(
                    item: item,
                    isSelected: isSelected,
                    badgeCount: badgeCount,
                    onTap: () => onSelectIndex(item.index),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

          // User Footer Profile
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.fullName?.substring(0, 1) ?? 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.fullName ?? 'Alex Morgan',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.callsign ?? 'Vanguard-1',
                        style: const TextStyle(
                          color: AppColors.accentCyan,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    appState.logout();
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  tooltip: 'Logout Session',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final int? badgeCount;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.isSelected,
    this.badgeCount,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSos = item.isEmergency;

    Color tileBg = Colors.transparent;
    Color iconColor = AppColors.textSecondary;
    Color textColor = AppColors.textSecondary;

    if (isSelected) {
      tileBg = isSos ? AppColors.critical.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15);
      iconColor = isSos ? AppColors.critical : AppColors.primary;
      textColor = isSos ? AppColors.critical : AppColors.primary;
    } else if (isSos) {
      iconColor = AppColors.critical;
      textColor = AppColors.critical;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: tileBg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: iconColor,
                  size: 19,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
