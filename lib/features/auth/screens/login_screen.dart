import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;
import '../../../core/utils/constants.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailAuth() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    final notifier = ref.read(authNotifierProvider.notifier);
    if (_isSignUp) {
      notifier.signUpWithEmail(email, password);
    } else {
      notifier.signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          final isLoggedIn = ref.read(isLoggedInProvider);
          if (isLoggedIn) context.go('/map');
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red.shade700,
            ),
          );
        },
      );
    });

    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Logo
              Image.asset(
                'assets/images/slabhaul_logo.png',
                height: 80,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your crappie fishing command center',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Email / Password fields
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                      Icon(Icons.lock_outline, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 20),

              // Sign In / Sign Up button
              AuthButton(
                label: _isSignUp ? 'Create Account' : 'Sign In',
                icon: _isSignUp ? Icons.person_add : Icons.login,
                onPressed: _handleEmailAuth,
                backgroundColor: AppColors.teal,
                textColor: Colors.white,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),

              // Toggle sign up / sign in
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign in'
                      : "Don't have an account? Sign up",
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.cardBorder)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.cardBorder)),
                ],
              ),
              const SizedBox(height: 24),

              // OAuth buttons
              AuthButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata,
                onPressed: () => ref
                    .read(authNotifierProvider.notifier)
                    .signInWithOAuth(OAuthProvider.google),
              ),
              const SizedBox(height: 10),
              AuthButton(
                label: 'Continue with Apple',
                icon: Icons.apple,
                onPressed: () => ref
                    .read(authNotifierProvider.notifier)
                    .signInWithOAuth(OAuthProvider.apple),
              ),
              const SizedBox(height: 24),

              // Guest mode
              TextButton.icon(
                onPressed: () => context.go('/map'),
                icon: const Icon(Icons.explore_outlined,
                    color: AppColors.textSecondary, size: 18),
                label: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Guest mode: all features work, favorites require sign-in',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
