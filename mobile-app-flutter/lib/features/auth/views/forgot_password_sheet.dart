import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/api_client.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

/// 3-step forgot password flow — mirrors ForgotPasswordSheet.swift.
/// Step 1: Enter email → Step 2: Enter code + new password → Step 3: Success.
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  int _step = 1;
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _loading = false;
  String? _error;

  final _api = ApiClient();

  // ── Step 1: Request reset code ──
  bool get _canRequestCode => _emailCtrl.text.contains('@');

  Future<void> _requestCode() async {
    if (!_canRequestCode) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _api.post('/auth/forgot-password', {'email': _emailCtrl.text.trim()});
      setState(() => _step = 2);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Step 2: Submit code + new password ──
  bool get _canReset =>
      _codeCtrl.text.length == 6 &&
      _newPasswordCtrl.text.length >= 8 &&
      _newPasswordCtrl.text == _confirmPasswordCtrl.text;

  Future<void> _resetPassword() async {
    if (!_canReset) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _api.post('/auth/reset-password', {
        'email': _emailCtrl.text.trim(),
        'code': _codeCtrl.text.trim(),
        'newPassword': _newPasswordCtrl.text,
      });
      setState(() => _step = 3);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ──
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Close button ──
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.close, size: 22, color: AppColors.tertiary),
                ),
              ),
            ),

            if (_step == 1) _buildStep1(),
            if (_step == 2) _buildStep2(),
            if (_step == 3) _buildStep3(),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Email entry ──
  Widget _buildStep1() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _iconCircle(Icons.lock_open, AppColors.amber),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).resetYourPasswordTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context).enterEmailForResetCode, style: TextStyle(fontSize: 14, color: AppColors.secondary)),
        const SizedBox(height: 24),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).email,
            prefixIcon: Icon(Icons.email_outlined, size: 18),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.urgent)),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (_canRequestCode && !_loading) ? _requestCode : null,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(AppLocalizations.of(context).sendResetCode),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Code + new password ──
  Widget _buildStep2() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _iconCircle(Icons.lock_open, AppColors.amber),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).enterResetCode, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context).codeSentToEmail(_emailCtrl.text), style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
        const SizedBox(height: 24),
        TextField(
          controller: _codeCtrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, fontFamily: 'monospace'),
          decoration: const InputDecoration(hintText: '000000', counterText: ''),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _newPasswordCtrl,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).newPasswordHint,
            prefixIcon: const Icon(Icons.lock_outline, size: 18),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _passwordVisible = !_passwordVisible),
              child: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmPasswordCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).confirmPasswordField,
            prefixIcon: Icon(Icons.lock_outline, size: 18),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.urgent)),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: (_canReset && !_loading) ? _resetPassword : null,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(AppLocalizations.of(context).resetPassword),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() { _step = 1; _error = null; }),
          child: Text(AppLocalizations.of(context).resendCode, style: TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  // ── Step 3: Success ──
  Widget _buildStep3() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _iconCircle(Icons.check, AppColors.online),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).passwordResetComplete, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context).passwordUpdatedShort, style: TextStyle(fontSize: 14, color: AppColors.secondary)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).backToSignIn),
          ),
        ),
      ],
    );
  }

  Widget _iconCircle(IconData icon, Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28, color: color),
    );
  }
}
