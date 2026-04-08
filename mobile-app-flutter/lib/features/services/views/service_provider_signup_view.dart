import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Registration form for hospitality service providers.
/// Mirrors ServiceProviderSignUpView.swift.
class ServiceProviderSignUpView extends StatefulWidget {
  const ServiceProviderSignUpView({super.key});

  @override
  State<ServiceProviderSignUpView> createState() => _ServiceProviderSignUpViewState();
}

class _ServiceProviderSignUpViewState extends State<ServiceProviderSignUpView> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _socialCtrl = TextEditingController();

  String _selectedCategoryId = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get _canSubmit {
    return _nameCtrl.text.trim().isNotEmpty &&
        _emailCtrl.text.contains('@') &&
        _emailCtrl.text.contains('.') &&
        _phoneCtrl.text.trim().isNotEmpty &&
        _selectedCategoryId.isNotEmpty;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _websiteCtrl.dispose();
    _socialCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: const Text('Registration Submitted', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          content: Text(
            'Your business "${_nameCtrl.text}" is now listed with a free profile. Upgrade to a premium plan for higher visibility and more features.',
            style: const TextStyle(color: AppColors.secondary),
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); context.pop(); },
              child: const Text('OK', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.lg),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
                      ),
                      const Spacer(),
                      const Text('Register Business', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                      const Spacer(),
                      const SizedBox(width: 36, height: 36),
                    ],
                  ),
                ),

                // Intro text
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
                  child: Text(
                    'List your hospitality service and get discovered by hotels, restaurants, and event planners.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColors.secondary, height: 1.45),
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                // ── Form card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Business Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                        const SizedBox(height: AppSpacing.lg),

                        // Required fields
                        Container(
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
                          child: Column(
                            children: [
                              _inputRow(Icons.apartment, 'Business Name *', _nameCtrl, TextInputType.text),
                              const Divider(height: 1, color: AppColors.divider),
                              _inputRow(Icons.email_outlined, 'Email *', _emailCtrl, TextInputType.emailAddress),
                              const Divider(height: 1, color: AppColors.divider),
                              _inputRow(Icons.phone_outlined, 'Phone *', _phoneCtrl, TextInputType.phone),
                              const Divider(height: 1, color: AppColors.divider),
                              _inputRow(Icons.location_on_outlined, 'Address / Location', _locationCtrl, TextInputType.text),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Category picker
                        GestureDetector(
                          onTap: () {
                            // Show category picker
                            setState(() => _selectedCategoryId = 'catering');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.category, size: 15, color: AppColors.amber),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  _selectedCategoryId.isEmpty ? 'Select Service Category *' : 'Catering - Event Catering',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: _selectedCategoryId.isEmpty ? AppColors.tertiary : AppColors.charcoal,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Description
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Service Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.sm)),
                              child: TextField(
                                controller: _descriptionCtrl,
                                maxLines: 4,
                                style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
                                decoration: const InputDecoration.collapsed(
                                  hintText: 'Describe your services, experience, and what makes you stand out...',
                                  hintStyle: TextStyle(color: AppColors.tertiary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Optional fields
                        const Text('Optional', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.tertiary)),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
                          child: Column(
                            children: [
                              _inputRow(Icons.language, 'Website', _websiteCtrl, TextInputType.url),
                              const Divider(height: 1, color: AppColors.divider),
                              _inputRow(Icons.camera_alt_outlined, 'Instagram / Social Link', _socialCtrl, TextInputType.text),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Error
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, size: 15, color: AppColors.urgent),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 13, color: AppColors.urgent), maxLines: 2)),
                      ],
                    ),
                  ),

                // Submit button
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
                  child: GestureDetector(
                    onTap: _canSubmit && !_isLoading ? _submit : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _canSubmit ? 1.0 : 0.6,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.amber, Color(0xDDF59E33)]),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          boxShadow: [BoxShadow(color: AppColors.amber.withValues(alpha: 0.18), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Register Business', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputRow(IconData icon, String placeholder, TextEditingController ctrl, TextInputType keyboard) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.amber),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: keyboard,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              decoration: InputDecoration.collapsed(hintText: placeholder, hintStyle: const TextStyle(color: AppColors.tertiary)),
            ),
          ),
        ],
      ),
    );
  }
}
