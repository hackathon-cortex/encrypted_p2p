import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/group_chat_screen.dart';
import '../screens/file_share_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sos_screen.dart';
import '../screens/voice_call_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String groupChat = '/group-chat';
  static const String fileShare = '/file-share';
  static const String profile = '/profile';
  static const String sos = '/sos';
  static const String voiceCall = '/voice-call';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    chat: (context) => const ChatScreen(),
    groupChat: (context) => const GroupChatScreen(),
    fileShare: (context) => const FileShareScreen(),
    profile: (context) => const ProfileScreen(),
    sos: (context) => const SosScreen(),
    voiceCall: (context) => const VoiceCallScreen(),
  };
}