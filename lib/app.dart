import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_routes.dart';
import 'core/state/app_state_provider.dart';
import 'core/theme/app_theme.dart';

class CortexApp extends StatefulWidget {
  const CortexApp({super.key});

  @override
  State<CortexApp> createState() => _CortexAppState();
}

class _CortexAppState extends State<CortexApp> {
  late final AppStateProvider _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppStateProvider();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
