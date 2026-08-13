import 'package:flutter/material.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController callsignController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedDepartment = 'Cyber Defense';
  bool isLoading = false;
  String? errorMessage;

  final departments = [
    'Central Command',
    'Cyber Defense',
    'Special Operations',
    'Cryptography Division',
    'Threat Intelligence',
    'Logistics & Comms',
  ];

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    callsignController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = usernameController.text.trim();
    final fullName = fullNameController.text.trim();
    final callsign = callsignController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Username and passphrase are required.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final appState = AppStateProvider.of(context);
    final success = await appState.authService.register(
      username: username,
      fullName: fullName,
      callsign: callsign,
      department: selectedDepartment,
      password: password,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } else {
      setState(() => errorMessage = 'Node registration failed.');
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PROVISION TACTICAL NODE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Generate new asymmetric keypair and register personnel roster.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall,
                  ),

                  const SizedBox(height: 24),

                  CortexCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CortexTextField(
                          controller: fullNameController,
                          labelText: 'FULL NAME',
                          hintText: 'e.g. Rachel Thorne',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 14),
                        CortexTextField(
                          controller: callsignController,
                          labelText: 'OPERATIONAL CALLSIGN',
                          hintText: 'e.g. Oracle-3',
                          prefixIcon: Icons.radar_rounded,
                        ),
                        const SizedBox(height: 14),
                        CortexTextField(
                          controller: usernameController,
                          labelText: 'SYSTEM USERNAME',
                          hintText: 'e.g. rachel_thorne',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'ASSIGNED DIVISION',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDepartment,
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceElevated,
                              items: departments.map((dept) {
                                return DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => selectedDepartment = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        CortexTextField(
                          controller: passwordController,
                          labelText: 'PASSPHRASE',
                          hintText: 'Min 8 characters...',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                        ],
                        const SizedBox(height: 24),
                        CortexButton(
                          text: 'INITIALIZE KEYPAIR & REGISTER',
                          icon: Icons.vpn_key_rounded,
                          isLoading: isLoading,
                          onPressed: _handleRegister,
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
