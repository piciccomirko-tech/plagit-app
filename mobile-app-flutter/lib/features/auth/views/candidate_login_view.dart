import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/network/api_error.dart';
import 'package:plagit/features/auth/widgets/auth_form_card.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/widgets/plagit_logo.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Candidate login screen — email/password sign-in with mock auth.
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
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit =>
      _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  Future<void> _login() async {
    if (!_canSubmit) return;
    setState(() { _loading = true; _error = null; });

    try {
      await context.read<CandidateAuthProvider>().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (mounted) context.go('/candidate/home');
    } catch (e) {
      if (mounted) {
        String msg;
        if (e is ApiError) {
          msg = e.displayMessage;
        } else {
          msg = e.toString().replaceAll('Exception: ', '');
        }
        setState(() { _error = msg; _loading = false; });
      }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5FBFB),
              Color(0xFFF5F5F7),
            ],
          ),
        ),
        child: SafeArea(
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
                      child: const BackChevron(size: 28, color: AppColors.charcoal),
                    ),
                    const Expanded(
                      child: Text(
                        'Join as Candidate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 28), // balance the back button
                  ],
                ),

                const SizedBox(height: 36),

                // ── Brand intro ──
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.18),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const PlagitLogo(size: 72, borderRadius: 18, withShadow: true),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Find your next hospitality role',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Sign in or create an account to start applying',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.35),
                  ),
                ),

                const SizedBox(height: 32),

              // ── Form card ──
              AuthFormCard(
                children: [
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
                    const Text(
                      'Remember me',
                      style: TextStyle(fontSize: 14, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444))),
              ],

              const SizedBox(height: 20),

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
                    onPressed: (_canSubmit && !_loading) ? _login : null,
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
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Create account button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.go('/candidate/register'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    backgroundColor: AppColors.tealLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Forgot password link ──
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/forgot-password'),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Switch to business ──
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/business/login'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.secondary),
                      children: [
                        TextSpan(text: 'Looking for staff instead? '),
                        TextSpan(
                          text: 'Switch to Business',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
