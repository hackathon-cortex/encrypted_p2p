import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/security_threat_model.dart';
import '../../models/audit_log_model.dart';

class CortexBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool isSmall;

  const CortexBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.surfaceElevated,
    this.textColor = AppColors.textPrimary,
    this.icon,
    this.isSmall = false,
  });

  factory CortexBadge.encrypted({bool isSmall = false}) {
    return CortexBadge(
      text: 'END-TO-END ENCRYPTED',
      backgroundColor: AppColors.success.withValues(alpha: 0.15),
      textColor: AppColors.success,
      icon: Icons.lock_outline_rounded,
      isSmall: isSmall,
    );
  }

  factory CortexBadge.severity(ThreatSeverity severity, {bool isSmall = false}) {
    Color bg;
    Color fg;
    switch (severity) {
      case ThreatSeverity.critical:
        bg = AppColors.critical.withValues(alpha: 0.18);
        fg = AppColors.critical;
        break;
      case ThreatSeverity.high:
        bg = AppColors.error.withValues(alpha: 0.18);
        fg = AppColors.error;
        break;
      case ThreatSeverity.medium:
        bg = AppColors.warning.withValues(alpha: 0.18);
        fg = AppColors.warning;
        break;
      case ThreatSeverity.low:
        bg = AppColors.info.withValues(alpha: 0.18);
        fg = AppColors.info;
        break;
      case ThreatSeverity.secure:
        bg = AppColors.success.withValues(alpha: 0.18);
        fg = AppColors.success;
        break;
    }
    return CortexBadge(
      text: severity.name.toUpperCase(),
      backgroundColor: bg,
      textColor: fg,
      isSmall: isSmall,
    );
  }

  factory CortexBadge.auditSeverity(AuditSeverity severity, {bool isSmall = false}) {
    Color bg;
    Color fg;
    switch (severity) {
      case AuditSeverity.critical:
        bg = AppColors.critical.withValues(alpha: 0.18);
        fg = AppColors.critical;
        break;
      case AuditSeverity.high:
        bg = AppColors.error.withValues(alpha: 0.18);
        fg = AppColors.error;
        break;
      case AuditSeverity.medium:
        bg = AppColors.warning.withValues(alpha: 0.18);
        fg = AppColors.warning;
        break;
      case AuditSeverity.low:
      case AuditSeverity.info:
        bg = AppColors.info.withValues(alpha: 0.18);
        fg = AppColors.info;
        break;
    }
    return CortexBadge(
      text: severity.name.toUpperCase(),
      backgroundColor: bg,
      textColor: fg,
      isSmall: isSmall,
    );
  }

  factory CortexBadge.online({required bool isOnline}) {
    return CortexBadge(
      text: isOnline ? 'ONLINE' : 'OFFLINE',
      backgroundColor: (isOnline ? AppColors.success : AppColors.textMuted).withValues(alpha: 0.15),
      textColor: isOnline ? AppColors.success : AppColors.textMuted,
      isSmall: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 10 : 13, color: textColor),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
