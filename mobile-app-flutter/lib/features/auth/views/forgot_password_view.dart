import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/auth/widgets/auth_form_card.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Forgot password screen — enter email to receive a reset link.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() => setState(() {}));
  }

  bool get _canSubmit => _emailCtrl.text.trim().isNotEmpty;

  Future<void> _sendResetLink() async {
    if (!_canSubmit) return;
    setState(() => _loading = true);

    // Mock network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _loading = false;
        _sent = true;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
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
                    child: const BackChevron(size: 28, color: AppColors.charcoal),
                  ),
                  const Expanded(
                    child: Text(
                      'Forgot Password',
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

              const SizedBox(height: 60),

              if (!_sent) _buildRequestState() else _buildSuccessState(),
            ],
          ),
        ),
      ),
    );
  }

  /// Initial state — email input + send button.
  Widget _buildRequestState() {
    return Column(
      children: [
        // ── Icon ──
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset, size: 36, color: AppColors.teal),
          ),
        ),
        const SizedBox(height: 24),

        const Center(
          child: Text(
            'Reset your password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Enter your email address and we\'ll send\nyou a link to reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4),
          ),
        ),

        const SizedBox(height: 32),

        // ── Email field ──
        AuthFormCard(
          children: [
            AuthFormField(
              icon: Icons.email_outlined,
              placeholder: 'Email address',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Send button ──
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
              onPressed: (_canSubmit && !_loading) ? _sendResetLink : null,
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
                      'Send Reset Link',
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

        // ── Back to login ──
        Center(
          child: GestureDetector(
            onTap: () => context.go('/candidate/login'),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Success state — confirmation message after email sent.
  Widget _buildSuccessState() {
    return Column(
      children: [
        // ── Green checkmark ──
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.online.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 44,
              color: AppColors.online,
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Center(
          child: Text(
            'Check your email',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'We\'ve sent a password reset link to\n${_emailCtrl.text.trim()}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4),
          ),
        ),

        const SizedBox(height: 32),

        // ── Back to sign in button ──
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark]),
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: MaterialButton(
              onPressed: () => context.go('/candidate/login'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Text(
                'Back to Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Resend link ──
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _sent = false),
            child: const Text(
              'Didn\'t receive it? Try again',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
