import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/token_storage.dart';
import 'package:plagit/services/auth_service.dart';
import 'package:plagit/features/auth/widgets/auth_form_card.dart';
import 'package:plagit/features/auth/views/forgot_password_sheet.dart';
import 'package:plagit/widgets/plagit_logo.dart';

/// Candidate login — mirrors CandidateAuthView.swift.
class CandidateLoginView extends StatefulWidget {
  const CandidateLoginView({super.key});

  @override
  State<CandidateLoginView> createState() => _CandidateLoginViewState();
}

class _CandidateLoginViewState extends State<CandidateLoginView> {
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
    final remember = prefs.getBool('candidateRememberMe') ?? false;
    final email = prefs.getString('candidateRememberedEmail') ?? '';
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
    debugPrint('[LOGIN] _login() called');
    debugPrint('[LOGIN] _canSubmit=$_canSubmit email="${_emailCtrl.text}" passLen=${_passwordCtrl.text.length}');
    if (!_canSubmit) {
      debugPrint('[LOGIN] BLOCKED: _canSubmit is false');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      debugPrint('[LOGIN] Calling AuthService.login...');
      final user = await AuthService().login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: 'candidate',
      );
      debugPrint('[LOGIN] AuthService.login SUCCEEDED: user.id=${user.id} user.email=${user.email} user.role=${user.role}');

      // Verify tokens were saved
      final savedToken = await TokenStorage.getAccessToken();
      final savedRole = await TokenStorage.getUserRole();
      debugPrint('[LOGIN] Token saved: ${savedToken != null ? "YES (${savedToken.length} chars)" : "NO"}');
      debugPrint('[LOGIN] Role saved: $savedRole');

      // Persist remember-me
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('candidateRememberMe', true);
        await prefs.setString('candidateRememberedEmail', _emailCtrl.text.trim());
      } else {
        await prefs.remove('candidateRememberMe');
        await prefs.remove('candidateRememberedEmail');
      }

      debugPrint('[LOGIN] About to navigate to /candidate/home, mounted=$mounted');
      if (mounted) context.go('/candidate/home');
      debugPrint('[LOGIN] Navigation called');
    } catch (e, st) {
      debugPrint('[LOGIN] ERROR: $e');
      debugPrint('[LOGIN] STACKTRACE: $st');
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
                      'Join as Candidate',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                    ),
                  ),
                  const SizedBox(width: 28), // balance
                ],
              ),

              const SizedBox(height: 32),

              // ── Brand intro ──
              const Center(child: PlagitLogo(size: 56, borderRadius: 14)),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Find your next role\nin hospitality',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Sign in to browse jobs and connect with employers',
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
                    placeholder: 'Email Address',
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
                      color: _rememberMe ? AppColors.teal : AppColors.tertiary,
                    ),
                    const SizedBox(width: 8),
                    const Text('Remember me', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Error banner ──
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
                        ? const LinearGradient(colors: [AppColors.teal, AppColors.tealDark])
                        : null,
                    color: (_canSubmit && !_loading) ? null : AppColors.teal.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: (_canSubmit && !_loading)
                        ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3))]
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

              // ── Create account button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.go('/candidate/signup'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: AppColors.tealLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                  ),
                  child: const Text('Create Account', style: TextStyle(color: AppColors.teal, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),

              // ── Helper links ──
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
                  child: const Text('Forgot Password?', style: TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/business/login'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.secondary),
                      children: [
                        TextSpan(text: 'Looking for staff? '),
                        TextSpan(
                          text: 'Switch to Business',
                          style: TextStyle(color: AppColors.indigo, fontWeight: FontWeight.w500),
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
