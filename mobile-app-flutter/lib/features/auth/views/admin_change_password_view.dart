import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminChangePasswordView extends StatefulWidget {
  const AdminChangePasswordView({super.key});
  @override State<AdminChangePasswordView> createState() => _S();
}

class _S extends State<AdminChangePasswordView> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  String? _error;

  bool get _passwordValid => _newCtrl.text.length >= 12 && RegExp(r'[A-Z]').hasMatch(_newCtrl.text) && RegExp(r'[a-z]').hasMatch(_newCtrl.text) && RegExp(r'[0-9]').hasMatch(_newCtrl.text);
  bool get _confirmMatch => _newCtrl.text == _confirmCtrl.text && _confirmCtrl.text.isNotEmpty;
  bool get _canSubmit => _passwordValid && _confirmMatch && !_isLoading;

  void _submit() async {
    setState(() { _error = null; _isLoading = true; });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      showDialog(context: context, builder: (_) => AlertDialog(
        title: const Text('Password Changed'),
        content: const Text('Your password has been updated. Please log in again with your new password.'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('OK', style: TextStyle(color: AppColors.teal)))],
      ));
    }
  }

  @override
  void dispose() { _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        AdminTopBar(title: 'Change Password', onBack: () => Navigator.pop(context)),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
          child: Column(children: [
            // Form card
            AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AdminSectionTitle(title: 'Update Password', icon: Icons.lock_reset),
              const SizedBox(height: AppSpacing.lg),
              _passwordField('New Password', _newCtrl, _showNew, () => setState(() => _showNew = !_showNew)),
              const SizedBox(height: AppSpacing.md),
              _passwordField('Confirm New Password', _confirmCtrl, _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(children: [const Icon(Icons.warning, size: 14, color: AppColors.urgent), const SizedBox(width: AppSpacing.xs), Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.urgent)))]),
              ],
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: _canSubmit ? _submit : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(color: _canSubmit ? AppColors.teal : AppColors.teal.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(AppRadius.md)),
                  alignment: Alignment.center,
                  child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isLoading ? 'Changing...' : 'Change Password', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ])),
            const SizedBox(height: AppSpacing.sectionGap),
            // Requirements card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.verified_user, size: 14, color: AppColors.secondary), const SizedBox(width: AppSpacing.sm), const Text('Password Requirements', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary))]),
                const SizedBox(height: AppSpacing.md),
                _req('At least 12 characters', _newCtrl.text.length >= 12),
                _req('One uppercase letter (A-Z)', RegExp(r'[A-Z]').hasMatch(_newCtrl.text)),
                _req('One lowercase letter (a-z)', RegExp(r'[a-z]').hasMatch(_newCtrl.text)),
                _req('One number (0-9)', RegExp(r'[0-9]').hasMatch(_newCtrl.text)),
                _req('Passwords match', _confirmMatch),
              ]),
            ),
          ]),
        )),
      ])),
    );
  }

  Widget _passwordField(String hint, TextEditingController ctrl, bool visible, VoidCallback toggleVisible) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Expanded(child: TextField(
          controller: ctrl,
          obscureText: !visible,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 15, color: AppColors.tertiary), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
        )),
        GestureDetector(onTap: toggleVisible, child: Icon(visible ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.tertiary)),
      ]),
    );
  }

  Widget _req(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(children: [
        Icon(met ? Icons.check_circle : Icons.circle_outlined, size: 14, color: met ? AppColors.online : AppColors.tertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: TextStyle(fontSize: 13, color: met ? AppColors.charcoal : AppColors.tertiary)),
      ]),
    );
  }
}
