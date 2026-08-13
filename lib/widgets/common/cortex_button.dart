import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum CortexButtonVariant { primary, secondary, outline, destructive, ghost }

class CortexButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CortexButtonVariant variant;
  final bool isLoading;
  final double height;
  final double? width;
  final bool isSmall;

  const CortexButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = CortexButtonVariant.primary,
    this.isLoading = false,
    this.height = 46,
    this.width,
    this.isSmall = false,
  });

  factory CortexButton.destructive({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isSmall = false,
  }) {
    return CortexButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: CortexButtonVariant.destructive,
      isLoading: isLoading,
      isSmall: isSmall,
    );
  }

  factory CortexButton.outline({
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isSmall = false,
  }) {
    return CortexButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      variant: CortexButtonVariant.outline,
      isLoading: isLoading,
      isSmall: isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case CortexButtonVariant.primary:
        bg = AppColors.primary;
        fg = AppColors.white;
        break;
      case CortexButtonVariant.secondary:
        bg = AppColors.surfaceElevated;
        fg = AppColors.textPrimary;
        border = const BorderSide(color: AppColors.border, width: 1);
        break;
      case CortexButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.textPrimary;
        border = const BorderSide(color: AppColors.borderLight, width: 1);
        break;
      case CortexButtonVariant.destructive:
        bg = AppColors.error;
        fg = AppColors.white;
        break;
      case CortexButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        break;
    }

    final btnHeight = isSmall ? 36.0 : height;

    return SizedBox(
      height: btnHeight,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: border ?? BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: isSmall ? 16 : 20,
                height: isSmall ? 16 : 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fg,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: isSmall ? 15 : 18, color: fg),
                    SizedBox(width: isSmall ? 6 : 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
