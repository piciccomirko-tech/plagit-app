import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/auth_service.dart';
import 'package:plagit/features/auth/widgets/auth_form_card.dart';
import 'package:plagit/features/auth/views/forgot_password_sheet.dart';
import 'package:plagit/widgets/plagit_logo.dart';

/// Business login — mirrors BusinessAuthView.swift.
class BusinessLoginView extends StatefulWidget {
  const BusinessLoginView({super.key});

  @override
  State<BusinessLoginView> createState() => _BusinessLoginViewState();
}

class _BusinessLoginViewState extends State<BusinessLoginView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _rememberMe = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onChanged);
    _passwordCtrl.addListener(_onChanged);
    _restoreSession();
  }

  void _onChanged() => setState(() {});

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('businessRememberMe') ?? false;
    final email = prefs.getString('businessRememberedEmail') ?? '';
    if (remember && email.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailCtrl.text = email;
      });
    }
  }

  bool get _canSubmit =>
      _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  Future<void> _login() async {
    if (!_canSubmit) return;
    setState(() { _loading = true; _error = null; });

    try {
      await AuthService().login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: 'business',
      );

      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('businessRememberMe', true);
        await prefs.setString('businessRememberedEmail', _emailCtrl.text.trim());
      } else {
        await prefs.remove('businessRememberMe');
        await prefs.remove('businessRememberedEmail');
      }

      if (mounted) context.go('/business/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Top bar ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/entry'),
                    child: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
                  ),
                  const Expanded(
                    child: Text(
                      'Join as Business',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),

              const SizedBox(height: 32),

              // ── Brand intro ──
              const Center(child: PlagitLogo(size: 56, borderRadius: 14)),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Hire the best talent\nin hospitality',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Sign in to post jobs and manage candidates',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 28),

              // ── Form card ──
              AuthFormCard(
                children: [
                  AuthFormField(
                    icon: Icons.email_outlined,
                    placeholder: 'Business Email',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  AuthFormField(
                    icon: Icons.lock_outline,
                    placeholder: 'Password',
                    controller: _passwordCtrl,
                    obscure: !_passwordVisible,
                    textInputAction: TextInputAction.done,
                    suffix: PasswordToggle(
                      visible: _passwordVisible,
                      onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Remember me ──
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    Icon(
                      _rememberMe ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                      color: _rememberMe ? AppColors.indigo : AppColors.tertiary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Remember me', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: 16),
              ],

              // ── Sign in button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: (_canSubmit && !_loading)
                        ? const LinearGradient(colors: [AppColors.indigo, Color(0xFF5560D0)])
                        : null,
                    color: (_canSubmit && !_loading) ? null : AppColors.indigo.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: (_canSubmit && !_loading)
                        ? [BoxShadow(color: AppColors.indigo.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: MaterialButton(
                    onPressed: (_canSubmit && !_loading) ? _login : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Create account ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.go('/business/signup'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: AppColors.indigo.withValues(alpha: 0.10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                  ),
                  child: const Text('Create Business Account', style: TextStyle(color: AppColors.indigo, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const ForgotPasswordSheet(),
                  ),
                  child: const Text('Forgot Password?', style: TextStyle(fontSize: 14, color: AppColors.indigo, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/candidate/login'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.secondary),
                      children: [
                        TextSpan(text: 'Looking for work? '),
                        TextSpan(
                          text: 'Switch to Candidate',
                          style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
