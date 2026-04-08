import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/candidate_providers.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _nationalityCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _availabilityCtrl;
  late final TextEditingController _salaryCtrl;
  late final TextEditingController _experienceCtrl;
  late final TextEditingController _bioCtrl;

  String _contractPreference = 'Full-time';
  final List<String> _languages = [];
  bool _initialized = false;

  void _initFromProfile() {
    if (_initialized) return;
    _initialized = true;

    final profile = context.read<CandidateAuthProvider>().profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _emailCtrl = TextEditingController(text: profile?.email ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    _locationCtrl = TextEditingController(text: profile?.location ?? '');
    _nationalityCtrl = TextEditingController(text: profile?.nationality ?? '');
    _roleCtrl = TextEditingController(text: profile?.role ?? '');
    _availabilityCtrl = TextEditingController(text: profile?.availability ?? '');
    _salaryCtrl = TextEditingController(text: profile?.salary ?? '');
    _experienceCtrl = TextEditingController(text: profile?.experience ?? '');
    _bioCtrl = TextEditingController();
    _contractPreference = profile?.contractPreference ?? 'Full-time';

    final langs = profile?.languages;
    if (langs != null && langs.isNotEmpty) {
      for (final l in langs.split(', ')) {
        _languages.add(l);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initFromProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _nationalityCtrl.dispose();
    _roleCtrl.dispose();
    _availabilityCtrl.dispose();
    _salaryCtrl.dispose();
    _experienceCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<CandidateAuthProvider>().profile;

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
          title: const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.teal)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // ── Photo section ──
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(profile.initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Change Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Personal Info ──
          _buildCard([
            _buildTextField('Full Name', _nameCtrl),
            _buildTextField('Email', _emailCtrl, enabled: false),
            _buildTextField('Phone', _phoneCtrl, keyboard: TextInputType.phone),
            _buildTextField('Location', _locationCtrl),
            _buildTextField('Nationality', _nationalityCtrl),
          ]),

          const SizedBox(height: 16),

          // ── Work Preferences ──
          _buildCard([
            _buildTextField('Target Role', _roleCtrl),
            const SizedBox(height: 12),
            const Text('Contract Preference', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Full-time', 'Part-time', 'Zero Hours'].map((option) {
                final selected = _contractPreference == option;
                return ChoiceChip(
                  label: Text(option, style: TextStyle(fontSize: 13, color: selected ? Colors.white : AppColors.charcoal)),
                  selected: selected,
                  selectedColor: AppColors.teal,
                  backgroundColor: AppColors.background,
                  side: BorderSide(color: selected ? AppColors.teal : AppColors.border),
                  onSelected: (_) => setState(() => _contractPreference = option),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            _buildTextField('Availability', _availabilityCtrl),
            _buildTextField('Salary Expectation', _salaryCtrl),
          ]),

          const SizedBox(height: 16),

          // ── Experience ──
          _buildCard([
            _buildTextField('Experience', _experienceCtrl),
          ]),

          const SizedBox(height: 16),

          // ── Languages ──
          _buildCard([
            const Text('Languages', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._languages.map((lang) => Chip(
                  label: Text(lang, style: const TextStyle(fontSize: 13)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _languages.remove(lang)),
                  backgroundColor: AppColors.lightTeal.withValues(alpha: 0.2),
                  side: BorderSide.none,
                )),
                GestureDetector(
                  onTap: () {
                    if (!_languages.contains('Spanish (Basic)')) {
                      setState(() => _languages.add('Spanish (Basic)'));
                    }
                  },
                  child: const Text('+ Add Language', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 16),

          // ── Bio ──
          _buildCard([
            const Text('Bio', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _bioCtrl,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Tell employers about yourself...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.tertiary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                ),
                counterStyle: const TextStyle(fontSize: 11, color: AppColors.secondary),
              ),
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboard,
        style: TextStyle(
          fontSize: 15,
          color: enabled ? AppColors.charcoal : AppColors.secondary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: AppColors.secondary),
          filled: true,
          fillColor: enabled ? AppColors.background : AppColors.divider.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
