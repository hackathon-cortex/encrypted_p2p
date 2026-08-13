import 'package:flutter/material.dart';
import '../../core/navigation/navigation_models.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';

class MobileBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  const MobileBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isSosActive = appState.sosService.isSosActive;

    // 5 primary mobile bottom bar tabs:
    // 0: Dashboard, 1: Chat, 7: Emergency SOS, 4: Security, 5: Personnel
    final topTabs = [
      AppNavItems.primaryItems[0], // Dashboard
      AppNavItems.primaryItems[1], // Secure Chat
      AppNavItems.primaryItems[7], // Emergency SOS
      AppNavItems.primaryItems[4], // Security
      AppNavItems.primaryItems[5], // Personnel
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: topTabs.map((item) {
              final isSelected = selectedIndex == item.index;
              final isEmergency = item.isEmergency;

              Color iconColor = isSelected
                  ? (isEmergency ? AppColors.critical : AppColors.primary)
                  : (isEmergency ? AppColors.critical : AppColors.textMuted);

              Color textColor = isSelected
                  ? (isEmergency ? AppColors.critical : AppColors.primary)
                  : (isEmergency ? AppColors.critical : AppColors.textMuted);

              return Expanded(
                child: InkWell(
                  onTap: () => onSelectIndex(item.index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: iconColor,
                            size: isEmergency ? 24 : 22,
                          ),
                          if (isEmergency && isSosActive)
                            Positioned(
                              top: -2,
                              right: -4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.critical,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isEmergency ? 'SOS' : item.label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 10,
                          fontWeight: (isSelected || isEmergency) ? FontWeight.w700 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
