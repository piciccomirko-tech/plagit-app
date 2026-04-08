import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';

class AdminLoginView extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AdminLoginView({super.key, required this.onLoginSuccess});
  @override State<AdminLoginView> createState() => _S();
}

class _S extends State<AdminLoginView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  bool _rememberMe = false;
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool get _canLogin => _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  void _performLogin() async {
    if (!_canLogin || _isLoading) return;
    _emailFocus.unfocus();
    _passwordFocus.unfocus();
    setState(() { _isLoading = true; _errorMessage = null; });
    await Future.delayed(const Duration(seconds: 1));
    if (_emailCtrl.text.contains('@') && _passwordCtrl.text.length >= 4) {
      widget.onLoginSuccess();
    } else {
      setState(() { _errorMessage = 'Invalid email or password. Please try again.'; _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Logo / branding
              Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(AppRadius.lg)),
                  child: const Icon(Icons.work_outline, color: Colors.white, size: 32),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Plagit Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                const SizedBox(height: AppSpacing.xs),
                const Text('Sign in to your admin account', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
              ]),
              const SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),

              // Login form card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(children: [
                  // Email field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Email', style: TextStyle(fontSize: 10, color: AppColors.tertiary)),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
                        decoration: const InputDecoration(hintText: 'Enter email', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                    ]),
                  ),
                  Padding(padding: const EdgeInsets.only(left: AppSpacing.xl), child: const Divider(height: 1, color: AppColors.divider)),
                  // Password field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Password', style: TextStyle(fontSize: 10, color: AppColors.tertiary)),
                      const SizedBox(height: AppSpacing.xs),
                      Row(children: [
                        Expanded(child: TextField(
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _performLogin(),
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
                          decoration: const InputDecoration(hintText: 'Enter password', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                        )),
                        GestureDetector(
                          onTap: () => setState(() => _showPassword = !_showPassword),
                          child: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.tertiary),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),

              // Remember me + forgot links
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl + AppSpacing.xs, AppSpacing.md, AppSpacing.xl + AppSpacing.xs, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_rememberMe ? Icons.check_box : Icons.check_box_outline_blank, size: 22, color: _rememberMe ? AppColors.teal : AppColors.tertiary),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Remember me', style: TextStyle(fontSize: 13, color: _rememberMe ? AppColors.charcoal : AppColors.secondary)),
                    ]),
                  ),
                  const Spacer(),
                  GestureDetector(onTap: () {}, child: const Text('Forgot password?', style: TextStyle(fontSize: 13, color: AppColors.teal))),
                ]),
              ),

              // Error message
              if (_errorMessage != null) Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl + AppSpacing.sm, AppSpacing.md, AppSpacing.xl + AppSpacing.sm, 0),
                child: Row(children: [const Icon(Icons.error, size: 16, color: AppColors.urgent), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 13, color: AppColors.urgent)))]),
              ),

              // Sign in button
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
                child: GestureDetector(
                  onTap: _canLogin && !_isLoading ? _performLogin : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: _canLogin ? AppColors.teal : AppColors.teal.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),
              const Text('Plagit Admin v1.0.0', style: TextStyle(fontSize: 10, color: AppColors.tertiary)),
            ],
          ),
        ),
      ),
    );
  }
}
