import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';

class BusinessRegisterView extends StatefulWidget {
  const BusinessRegisterView({super.key});

  @override
  State<BusinessRegisterView> createState() => _BusinessRegisterViewState();
}

class _BusinessRegisterViewState extends State<BusinessRegisterView> {
  final _businessNameCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _businessNameCtrl.addListener(_rebuild);
    _contactNameCtrl.addListener(_rebuild);
    _emailCtrl.addListener(_rebuild);
    _passwordCtrl.addListener(_rebuild);
    _confirmPasswordCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  bool get _canSubmit =>
      _businessNameCtrl.text.trim().isNotEmpty &&
      _contactNameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _passwordCtrl.text.isNotEmpty &&
      _confirmPasswordCtrl.text.isNotEmpty &&
      _agreedToTerms;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _contactNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
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
                      'Create Business Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),

              const SizedBox(height: 32),

              // ── Form card ──
              Container(
                decoration: AppColors.cardDecoration,
                child: Column(
                  children: [
                    _buildField(Icons.business_outlined, 'Business Name', _businessNameCtrl),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildField(Icons.person_outline, 'Contact Name', _contactNameCtrl),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildField(Icons.email_outlined, 'Email', _emailCtrl, keyboardType: TextInputType.emailAddress),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildPasswordField('Password', _passwordCtrl, _obscurePassword, () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    }),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildPasswordField('Confirm Password', _confirmPasswordCtrl, _obscureConfirm, () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Terms checkbox ──
              GestureDetector(
                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.teal,
                        onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: AppColors.secondary),
                          children: [
                            TextSpan(text: 'I agree to '),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w500),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Create Account button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSubmit ? () => context.go('/business/onboarding/welcome') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),

              // ── Already have an account ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 14, color: AppColors.secondary),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/business/login'),
                    child: const Text(
                      'Sign In',
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

  Widget _buildField(IconData icon, String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 20, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: AppColors.tertiary,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}
