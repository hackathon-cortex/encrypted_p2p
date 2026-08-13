import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/mfa_verification_screen.dart';
import '../../screens/auth/recovery_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/splash/splash_screen.dart';
import 'main_navigation_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mfa = '/mfa';
  static const String recovery = '/recovery';
  static const String home = '/home';

  // Specific Deep Link Routes
  static const String dashboard = '/dashboard';
  static const String chat = '/chat';
  static const String groupChat = '/group-chat';
  static const String fileShare = '/file-share';
  static const String voiceCall = '/voice-call';
  static const String security = '/security';
  static const String personnel = '/personnel';
  static const String liveLocation = '/live-location';
  static const String sos = '/sos';
  static const String aiAssistant = '/ai-assistant';
  static const String auditLogs = '/audit-logs';
  static const String notifications = '/notifications';
  static const String devices = '/devices';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        mfa: (context) => const MfaVerificationScreen(),
        recovery: (context) => const RecoveryScreen(),
        home: (context) => const MainNavigationShell(),

        // Direct fallback routes
        dashboard: (context) => const MainNavigationShell(),
        chat: (context) => const MainNavigationShell(),
        groupChat: (context) => const MainNavigationShell(),
        fileShare: (context) => const MainNavigationShell(),
        voiceCall: (context) => const MainNavigationShell(),
        security: (context) => const MainNavigationShell(),
        personnel: (context) => const MainNavigationShell(),
        liveLocation: (context) => const MainNavigationShell(),
        sos: (context) => const MainNavigationShell(),
        aiAssistant: (context) => const MainNavigationShell(),
        auditLogs: (context) => const MainNavigationShell(),
        notifications: (context) => const MainNavigationShell(),
        devices: (context) => const MainNavigationShell(),
        settings: (context) => const MainNavigationShell(),
        profile: (context) => const MainNavigationShell(),
      };
}
