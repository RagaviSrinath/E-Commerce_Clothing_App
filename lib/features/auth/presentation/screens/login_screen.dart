import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _emailController = TextEditingController(text: authState.email);
    _passwordController = TextEditingController(text: authState.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    context.read<AuthBloc>().add(AuthEmailChanged(email));
    context.read<AuthBloc>().add(AuthPasswordChanged(password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            widget.onLoginSuccess();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header / Branding
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.cardShadow,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icons/ic_launcher.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 64,
                                  height: 64,
                                  color: AppColors.primary,
                                  child: const Icon(
                                    Icons.checkroom_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'NEXTGEN WARDROBE',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.brandHeader,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Curated contemporary wardrobe essentials',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 36),

                      // Error message container if login failed
                      if (state.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.error.withAlpha(76),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    const AuthErrorDismissed(),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Email input
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'e.g. user@nextgen.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        errorText: state.email.isNotEmpty && !state.isEmailValid
                            ? 'Please enter a valid email address'
                            : null,
                        onChanged: (value) {
                          context.read<AuthBloc>().add(AuthEmailChanged(value));
                        },
                      ),
                      const SizedBox(height: 18),

                      // Password input
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Enter your password',
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        errorText:
                            state.password.isNotEmpty && !state.isPasswordValid
                            ? 'Password must be at least 4 characters'
                            : null,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        onChanged: (value) {
                          context.read<AuthBloc>().add(
                            AuthPasswordChanged(value),
                          );
                        },
                        onSubmitted: state.isFormValid
                            ? () {
                                context.read<AuthBloc>().add(
                                  const AuthLoginSubmitted(),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 28),

                      // Submit button (disabled unless both email & password are valid)
                      CustomButton(
                        text: 'Sign In',
                        isLoading: state.isLoading,
                        onPressed: state.isFormValid
                            ? () {
                                context.read<AuthBloc>().add(
                                  const AuthLoginSubmitted(),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 28),

                      // Predefined dummy credentials helper
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.vpn_key_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Predefined Demo Credentials',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ActionChip(
                              backgroundColor: Colors.white,
                              label: const Text(
                                'Aarav Sharma (Demo Account)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              avatar: const Icon(
                                Icons.account_circle_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _fillCredentials(
                                'user@nextgen.com',
                                'Password123',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap chip to autofill credentials, or enter any valid email address.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
