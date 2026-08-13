import 'package:flutter/material.dart';

import '../utils/colors.dart';

class UserTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isOnline;

  const UserTile({
    super.key,
    required this.name,
    this.subtitle,
    this.onTap,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      leading: Stack(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 1,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textSecondary,
        size: 15,
      ),
    );
  }
}