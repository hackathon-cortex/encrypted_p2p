import 'package:flutter/material.dart';
import '../../core/navigation/navigation_models.dart';
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
    // 5 top frequent tabs for mobile bottom bar:
    // 0: Dashboard, 1: Chat, 2: Files, 4: Security, 5: Personnel
    final topTabs = [
      AppNavItems.primaryItems[0], // Dashboard
      AppNavItems.primaryItems[1], // Secure Chat
      AppNavItems.primaryItems[2], // Files
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

              return Expanded(
                child: InkWell(
                  onTap: () => onSelectIndex(item.index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
