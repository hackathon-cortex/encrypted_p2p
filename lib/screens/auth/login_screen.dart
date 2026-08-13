import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController(text: 'commander_alex');
  final TextEditingController passwordController = TextEditingController(text: 'SecurePass2026!');
  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Please enter both username and password.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final appState = AppStateProvider.of(context);
    final success = await appState.login(username, password);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      // Proceed to MFA Verification screen
      Navigator.pushNamed(context, AppRoutes.mfa);
    } else {
      setState(() => errorMessage = 'Invalid credentials. Security event logged.');
    }
  }

  Future<void> _handleBiometric() async {
    setState(() => isLoading = true);
    final appState = AppStateProvider.of(context);
    final success = await appState.authenticateBiometric();

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryLight, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shield_rounded,
                          size: 36,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'TACTICAL AUTHENTICATION GATEWAY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentCyan,
                      fontFamily: 'monospace',
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Form Card
                  CortexCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('OPERATOR LOGIN', style: AppTypography.titleMedium),
                        const SizedBox(height: 4),
                        const Text(
                          'Provide authorized credentials to access mesh node.',
                          style: AppTypography.bodySmall,
                        ),

                        const SizedBox(height: 20),

                        CortexTextField(
                          controller: usernameController,
                          labelText: 'OPERATOR CALLSIGN / USERNAME',
                          hintText: 'Enter callsign...',
                          prefixIcon: Icons.person_outline_rounded,
                        ),

                        const SizedBox(height: 16),

                        CortexTextField(
                          controller: passwordController,
                          labelText: 'SECURITY PASSPHRASE',
                          hintText: 'Enter passphrase...',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                          ),
                          onSubmitted: (_) => _handleLogin(),
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        CortexButton(
                          text: 'AUTHENTICATE',
                          icon: Icons.login_rounded,
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        ),

                        const SizedBox(height: 12),

                        CortexButton.outline(
                          text: 'DRILL BYPASS',
                          icon: Icons.flash_on_rounded,
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        ),

                        const SizedBox(height: 12),

                        // Biometric Quick Unlock
                        CortexButton.outline(
                          text: 'BIOMETRIC / HARDWARE UNLOCK',
                          icon: Icons.fingerprint_rounded,
                          onPressed: _handleBiometric,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Links: Register & Recovery
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.recovery);
                        },
                        child: const Text(
                          'Key Recovery',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text(
                          'Register Node',
                          style: TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
