import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/network/api_error.dart';
import 'package:plagit/features/auth/widgets/auth_form_card.dart';
import 'package:plagit/repositories/auth_repository.dart';
import 'package:plagit/widgets/plagit_logo.dart';

/// Candidate registration screen — create a new account.
class CandidateRegisterView extends StatefulWidget {
  const CandidateRegisterView({super.key});

  @override
  State<CandidateRegisterView> createState() => _CandidateRegisterViewState();
}

class _CandidateRegisterViewState extends State<CandidateRegisterView> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  bool _termsAccepted = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged);
    _passwordCtrl.addListener(_onChanged);
    _confirmCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _passwordCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty &&
      _termsAccepted;

  Future<void> _createAccount() async {
    if (!_canSubmit) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final authRepo = AuthRepository();
      await authRepo.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: 'candidate',
      );
      if (mounted) context.go('/onboarding/welcome');
    } catch (e) {
      if (mounted) {
        final msg = e is ApiError ? e.displayMessage : e.toString().replaceAll('Exception: ', '');
        setState(() { _error = msg; _loading = false; });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
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
                    onTap: () => context.go('/candidate/login'),
                    child: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
                  ),
                  const Expanded(
                    child: Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
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
                  'Join Plagit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Create your account to start finding roles',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 28),

              // ── Form card ──
              AuthFormCard(
                children: [
                  AuthFormField(
                    icon: Icons.person_outline,
                    placeholder: 'Full name',
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                  ),
                  AuthFormField(
                    icon: Icons.email_outlined,
                    placeholder: 'Email address',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  AuthFormField(
                    icon: Icons.lock_outline,
                    placeholder: 'Password',
                    controller: _passwordCtrl,
                    obscure: !_passwordVisible,
                    suffix: PasswordToggle(
                      visible: _passwordVisible,
                      onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  AuthFormField(
                    icon: Icons.lock_outline,
                    placeholder: 'Confirm password',
                    controller: _confirmCtrl,
                    obscure: !_confirmVisible,
                    textInputAction: TextInputAction.done,
                    suffix: PasswordToggle(
                      visible: _confirmVisible,
                      onToggle: () => setState(() => _confirmVisible = !_confirmVisible),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Terms checkbox ──
              GestureDetector(
                onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _termsAccepted ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                      color: _termsAccepted ? AppColors.teal : AppColors.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13, color: AppColors.secondary, height: 1.4),
                          children: [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444)),
                ),
              ],

              const SizedBox(height: 24),

              // ── Create account button ──
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
                        ? [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: MaterialButton(
                    onPressed: (_canSubmit && !_loading) ? _createAccount : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Sign in link ──
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/candidate/login'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.secondary),
                      children: [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
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
