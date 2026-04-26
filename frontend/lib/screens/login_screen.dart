import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await context.read<AuthService>().login(email.text.trim(), password.text);
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _googleLogin() async {
    try {
      await context.read<AuthService>().signInWithGoogle();
    } catch (err) {
      if (!mounted) return;
      NotificationService.showMessage(
        context,
        err.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final loading = auth.loading;
    final googleConfigured = auth.isGoogleSignInConfigured;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            if (!wide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _heroCard(compact: true),
                    const SizedBox(height: 16),
                    _loginCard(loading, googleConfigured),
                  ],
                ),
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _heroCard(compact: false),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                    child: _loginCard(loading, googleConfigured),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _heroCard({required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDFBFF), Color(0xFFF5F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 98,
            height: 98,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A43EF), Color(0xFFE53896)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child:
                const Icon(Icons.shield_rounded, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 14),
          const Text(
            'Adhira',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const Text(
            'Women Safety & Support App',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: compact ? 210 : 280,
            height: compact ? 210 : 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFEDE7FF), Color(0xFFFFEAF4)],
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(
                Icons.self_improvement_rounded,
                color: AppColors.primary,
                size: 120,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Together, we empower.',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            'Together, we protect.',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE53896),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 280,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFE53896), Color(0xFFB21BC7)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x28B21BC7),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Get Started  →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginCard(bool loading, bool googleConfigured) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11101E42),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sign in to continue your safety journey.',
              style: TextStyle(
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: email,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 18),
          CustomButton(label: 'Login', onPressed: _login, loading: loading),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: (loading || !googleConfigured) ? null : _googleLogin,
            icon: const Icon(Icons.login),
            label: const Text('Continue with Google'),
          ),
          if (!googleConfigured)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Google sign-in needs GOOGLE_WEB_CLIENT_ID in --dart-define.',
                style: TextStyle(fontSize: 12, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: loading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
