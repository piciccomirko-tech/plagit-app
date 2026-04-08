import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/widgets/plagit_logo.dart';

class BusinessLoginView extends StatefulWidget {
  const BusinessLoginView({super.key});

  @override
  State<BusinessLoginView> createState() => _BusinessLoginViewState();
}

class _BusinessLoginViewState extends State<BusinessLoginView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<BusinessAuthProvider>().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (mounted) context.go('/business/home');
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Top bar ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, size: 22, color: AppColors.charcoal),
                  ),
                  const Expanded(
                    child: Text(
                      'Join as Business',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),

              const SizedBox(height: 24),

              // ── Logo ──
              const PlagitLogo(size: 56, borderRadius: 14),

              const SizedBox(height: 16),

              // ── Headline ──
              const Text(
                'Hire the best hospitality talent',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal),
              ),

              const SizedBox(height: 8),

              const Text(
                'Sign in or create an account to start hiring',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
              ),

              const SizedBox(height: 32),

              // ── Form card ──
              Container(
                decoration: AppColors.cardDecoration,
                child: Column(
                  children: [
                    // Email field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 20, color: AppColors.teal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Business email',
                                hintStyle: TextStyle(color: AppColors.tertiary, fontSize: 15),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: AppColors.divider),

                    // Password field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, size: 20, color: AppColors.teal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: AppColors.tertiary, fontSize: 15),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.tertiary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Remember me ──
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.teal,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Remember me', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
                  ],
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.red)),
              ],

              const SizedBox(height: 24),

              // ── Sign In button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 12),

              // ── Create Business Account ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => context.go('/business/register'),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.teal.withValues(alpha: 0.08),
                    foregroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Create Business Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),

              // ── Forgot password ──
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 12),

              // ── Switch to Candidate ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Looking for work instead? ',
                    style: TextStyle(fontSize: 14, color: AppColors.secondary),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/candidate/login'),
                    child: const Text(
                      'Switch to Candidate',
                      style: TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
