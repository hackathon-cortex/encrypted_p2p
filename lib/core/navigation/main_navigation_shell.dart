import 'package:flutter/material.dart';
import '../../screens/ai_assistant/ai_assistant_screen.dart';
import '../../screens/audit/audit_logs_screen.dart';
import '../../screens/calls/voice_call_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/dashboard/command_dashboard_screen.dart';
import '../../screens/devices/device_management_screen.dart';
import '../../screens/files/file_share_screen.dart';
import '../../screens/location/live_location_screen.dart';
import '../../screens/notifications/notification_center_screen.dart';
import '../../screens/personnel/personnel_screen.dart';
import '../../screens/security/security_center_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/sos/sos_screen.dart';
import '../../widgets/active_call_overlay.dart';
import '../../widgets/navigation/bottom_navigation.dart';
import '../../widgets/navigation/secondary_drawer.dart';
import '../../widgets/navigation/sidebar_navigation.dart';
import '../state/app_state_provider.dart';
import '../theme/app_colors.dart';
import 'app_routes.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const CommandDashboardScreen();
      case 1:
        return const ChatScreen();
      case 2:
        return const FileShareScreen();
      case 3:
        return const VoiceCallScreen();
      case 4:
        return const SecurityCenterScreen();
      case 5:
        return const PersonnelScreen();
      case 6:
        return const LiveLocationScreen();
      case 7:
        return const SosScreen();
      case 8:
        return const AiAssistantScreen();
      case 9:
        return const AuditLogsScreen();
      case 10:
        return const NotificationCenterScreen();
      case 11:
        return const DeviceManagementScreen();
      case 12:
        return const SettingsScreen();
      default:
        return const CommandDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    // If logged out, redirect to login
    if (!appState.authService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      });
      return const Scaffold(backgroundColor: AppColors.background);
    }

    final selectedIndex = appState.selectedNavigationIndex.clamp(0, 12);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      key: appState.rootScaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isDesktop
          ? null
          : SecondaryDrawer(
              selectedIndex: selectedIndex,
              onSelectIndex: (idx) => appState.setNavigationIndex(idx),
            ),
      body: Stack(
        children: [
          Row(
            children: [
              // Desktop Sidebar Navigation Rail
              if (isDesktop)
                SidebarNavigation(
                  selectedIndex: selectedIndex,
                  onSelectIndex: (idx) => appState.setNavigationIndex(idx),
                ),

              // Active Screen View
              Expanded(
                child: _buildScreen(selectedIndex),
              ),
            ],
          ),

          // Global Active Floating Call Banner
          const ActiveCallOverlay(),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : MobileBottomNavigation(
              selectedIndex: selectedIndex,
              onSelectIndex: (idx) => appState.setNavigationIndex(idx),
            ),
    );
  }
}
