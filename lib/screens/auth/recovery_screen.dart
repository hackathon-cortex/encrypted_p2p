import 'package:flutter/material.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_text_field.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _handleRecovery() async {
    final username = usernameController.text.trim();
    final key = keyController.text.trim();

    if (username.isEmpty || key.isEmpty) {
      setState(() => errorMessage = 'Please enter username and master recovery key.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final appState = AppStateProvider.of(context);
    final success = await appState.authService.recoverAccount(
      username: username,
      recoveryKey: key,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } else {
      setState(() => errorMessage = 'Recovery key verification failed. Key must be at least 8 characters.');
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  const Icon(Icons.key_rounded, size: 48, color: AppColors.accentCyan),
                  const SizedBox(height: 16),
                  const Text(
                    'RECOVER ACCESS KEY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your 24-word cryptographic recovery seed or emergency master key.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  CortexCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CortexTextField(
                          controller: usernameController,
                          labelText: 'OPERATOR USERNAME',
                          hintText: 'e.g. commander_alex',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        CortexTextField(
                          controller: keyController,
                          labelText: 'MASTER RECOVERY KEY / PHRASE',
                          hintText: 'Enter recovery phrase...',
                          prefixIcon: Icons.vpn_key_outlined,
                          maxLines: 2,
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                        ],
                        const SizedBox(height: 20),
                        CortexButton(
                          text: 'RESTORE CIPHER VAULT',
                          icon: Icons.restore_rounded,
                          isLoading: isLoading,
                          onPressed: _handleRecovery,
                        ),
                      ],
                    ),
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
