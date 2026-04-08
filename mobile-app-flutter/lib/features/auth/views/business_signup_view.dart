import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/hospitality_catalog.dart';
import 'package:plagit/services/auth_service.dart';
import 'package:plagit/features/auth/widgets/auth_form_card.dart';
import 'package:plagit/widgets/chip_selector.dart';
import 'package:plagit/widgets/hospitality_category_picker.dart';

/// Business registration — mirrors BusinessSignUpView.swift.
class BusinessSignupView extends StatefulWidget {
  const BusinessSignupView({super.key});

  @override
  State<BusinessSignupView> createState() => _BusinessSignupViewState();
}

class _BusinessSignupViewState extends State<BusinessSignupView> {
  final _companyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _openToInternational = false;
  bool _loading = false;
  String? _error;
  String _categoryId = '';
  String _subcategoryId = '';
  String _roleId = '';
  String _jobType = '';

  @override
  void initState() {
    super.initState();
    _companyCtrl.addListener(_onChanged);
    _emailCtrl.addListener(_onChanged);
    _passwordCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit =>
      _companyCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.contains('@') &&
      _emailCtrl.text.contains('.') &&
      _passwordCtrl.text.length >= 8;

  Future<void> _register() async {
    if (!_canSubmit) return;
    setState(() { _loading = true; _error = null; });

    try {
      await AuthService().registerBusiness(
        companyName: _companyCtrl.text.trim(),
        email: _emailCtrl.text.trim().toLowerCase(),
        password: _passwordCtrl.text,
        contactPerson: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
        venueType: _categoryId.isEmpty ? null : '$_categoryId:$_subcategoryId',
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        requiredRole: _roleId.isEmpty ? null : _roleId,
        jobType: _jobType.isEmpty ? null : _jobType,
        openToInternational: _openToInternational,
      );
      if (mounted) context.go('/business/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _locationCtrl.dispose();
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
                    onTap: () => context.go('/business/login'),
                    child: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
                  ),
                  const Expanded(
                    child: Text(
                      'Create Business Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                'Register your business on Plagit and\nstart finding top hospitality talent.',
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
              ),

              const SizedBox(height: 24),

              // ── Business Details ──
              const Text('Business Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
              AuthFormCard(
                children: [
                  AuthFormField(icon: Icons.business_outlined, placeholder: 'Company Name', controller: _companyCtrl),
                  AuthFormField(icon: Icons.person_outline, placeholder: 'Contact Person (optional)', controller: _contactCtrl),
                  AuthFormField(icon: Icons.email_outlined, placeholder: 'Email Address', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                  AuthFormField(
                    icon: Icons.lock_outline,
                    placeholder: 'Password (min 8 characters)',
                    controller: _passwordCtrl,
                    obscure: !_passwordVisible,
                    suffix: PasswordToggle(
                      visible: _passwordVisible,
                      onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  AuthFormField(icon: Icons.location_on_outlined, placeholder: 'Location (optional)', controller: _locationCtrl, textInputAction: TextInputAction.done),
                ],
              ),

              const SizedBox(height: 16),

              // ── Open to international toggle ──
              GestureDetector(
                onTap: () => setState(() => _openToInternational = !_openToInternational),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language, size: 18, color: AppColors.indigo),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Open to international candidates', style: TextStyle(fontSize: 15, color: AppColors.charcoal)),
                      ),
                      Switch.adaptive(
                        value: _openToInternational,
                        onChanged: (v) => setState(() => _openToInternational = v),
                        activeTrackColor: AppColors.indigo,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Category & Role Picker ──
              const Text('Venue Type & Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => HospitalityCategoryPicker(
                    initialCategoryId: _categoryId.isEmpty ? null : _categoryId,
                    initialSubcategoryId: _subcategoryId.isEmpty ? null : _subcategoryId,
                    initialRoleId: _roleId.isEmpty ? null : _roleId,
                    onSelected: (catId, subId, role) => setState(() {
                      _categoryId = catId;
                      _subcategoryId = subId;
                      _roleId = role;
                    }),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant_menu, size: 16, color: AppColors.indigo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _roleId.isNotEmpty
                              ? HospitalityCatalog.displayPath(categoryId: _categoryId, subcategoryId: _subcategoryId, roleId: _roleId)
                              : 'Select venue type & required role',
                          style: TextStyle(
                            fontSize: 15,
                            color: _roleId.isNotEmpty ? AppColors.charcoal : AppColors.tertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Job Type Chips ──
              const Text('Job Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
              ChipSelector(
                options: jobTypeChips,
                selected: _jobType,
                onSelected: (v) => setState(() => _jobType = v),
              ),

              const SizedBox(height: 24),

              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: 16),
              ],

              // ── Create button ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: (_canSubmit && !_loading)
                        ? const LinearGradient(colors: [AppColors.indigo, Color(0xFF5560D0)])
                        : null,
                    color: (_canSubmit && !_loading) ? null : AppColors.indigo.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: (_canSubmit && !_loading)
                        ? [BoxShadow(color: AppColors.indigo.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: MaterialButton(
                    onPressed: (_canSubmit && !_loading) ? _register : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create Business Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () => context.go('/business/login'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.secondary),
                      children: [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(text: 'Sign In', style: TextStyle(color: AppColors.indigo, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'By creating an account you agree to our\nTerms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.tertiary),
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
