import 'package:flutter/material.dart';
import '../../core/navigation/navigation_models.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SecondaryDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const SecondaryDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final user = appState.authService.currentUser;

    return Drawer(
      backgroundColor: AppColors.backgroundSecondary,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header Profile
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.fullName?.substring(0, 1) ?? 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Alex Morgan',
                          style: AppTypography.titleMedium,
                        ),
                        Text(
                          '${user?.callsign ?? "Vanguard-1"} • ${user?.role ?? "Commander"}',
                          style: const TextStyle(
                            color: AppColors.accentCyan,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Modules List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'PRIMARY MODULES',
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
                    return _DrawerTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelectIndex(item.index);
                      },
                    );
                  }),

                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'SECONDARY & SECURITY',
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
                    return _DrawerTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelectIndex(item.index);
                      },
                    );
                  }),
                ],
              ),
            ),

            const Divider(height: 1),

            // Logout Action
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              title: const Text(
                'Logout Session',
                style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(context).pop();
                appState.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmergency = item.isEmergency;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? (isEmergency ? AppColors.critical.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          isSelected ? item.selectedIcon : item.icon,
          color: isSelected
              ? (isEmergency ? AppColors.critical : AppColors.primaryLight)
              : (isEmergency ? AppColors.critical : AppColors.textSecondary),
          size: 20,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected
                ? (isEmergency ? AppColors.critical : AppColors.white)
                : (isEmergency ? AppColors.critical : AppColors.textPrimary),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
