import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/candidate_service.dart';
import 'package:plagit/services/auth_service.dart';
import 'package:plagit/core/hospitality_catalog.dart';
import 'package:plagit/widgets/hospitality_category_picker.dart';

class CandidateProfileTab extends StatefulWidget {
  const CandidateProfileTab({super.key});

  @override
  State<CandidateProfileTab> createState() => _CandidateProfileTabState();
}

class _CandidateProfileTabState extends State<CandidateProfileTab> {
  final _service = CandidateService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _languagesCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String _categoryId = '';
  String _subcategoryId = '';
  String _roleId = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getProfile();
      final profile = (data['profile'] ?? data['user'] ?? data) as Map<String, dynamic>;
      if (mounted) setState(() {
        _profile = profile;
        _nameCtrl.text = profile['name']?.toString() ?? '';
        _phoneCtrl.text = profile['phone']?.toString() ?? '';
        _locationCtrl.text = profile['location']?.toString() ?? '';
        _experienceCtrl.text = profile['experience']?.toString() ?? '';
        _languagesCtrl.text = profile['languages']?.toString() ?? '';
        _bioCtrl.text = profile['bio']?.toString() ?? '';
        _roleId = profile['role']?.toString() ?? '';
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await _service.updateProfile({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'experience': _experienceCtrl.text.trim(),
        'languages': _languagesCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        if (_roleId.isNotEmpty) 'role': _roleId,
      });
      if (mounted) {
        setState(() { _editing = false; _saving = false; });
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) context.go('/entry');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _locationCtrl.dispose();
    _experienceCtrl.dispose(); _languagesCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 28, color: AppColors.urgent),
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(fontSize: 14, color: AppColors.urgent)),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _loadProfile, child: const Text('Retry')),
                ]))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    // ── Header ──
                    Row(children: [
                      const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _editing = !_editing),
                        child: Text(_editing ? 'Cancel' : 'Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _editing ? AppColors.urgent : AppColors.teal)),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── Avatar card ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Column(children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'P',
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: AppColors.teal),
                          )),
                        ),
                        const SizedBox(height: 14),
                        Text(_profile?['name']?.toString() ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                        if (_profile?['email'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_profile!['email'].toString(), style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    // ── Profile strength ──
                    if (_profile?['profileStrength'] != null || _profile?['profile_strength'] != null) ...[
                      _buildStrength((_profile?['profileStrength'] ?? _profile?['profile_strength'] ?? 0) as num),
                      const SizedBox(height: 12),
                    ],

                    if (_editing) ..._buildEditForm() else ..._buildReadOnly(),

                    const SizedBox(height: 12),

                    // ── Account actions ──
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Column(children: [
                        _AccountRow(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
                        Divider(height: 1, color: AppColors.divider, indent: 52),
                        _AccountRow(icon: Icons.shield_outlined, label: 'Privacy Policy', onTap: () {}),
                        Divider(height: 1, color: AppColors.divider, indent: 52),
                        _AccountRow(icon: Icons.logout, label: 'Sign Out', color: AppColors.urgent, onTap: _logout),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
    );
  }

  Widget _buildStrength(num strength) {
    final int s = strength.toInt();
    final Color barColor = s >= 80 ? AppColors.online : s >= 50 ? AppColors.amber : AppColors.urgent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: barColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(Icons.shield_outlined, size: 18, color: barColor),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Profile Strength', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal))),
          Text('$s%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: barColor)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: s / 100, backgroundColor: AppColors.divider, color: barColor, minHeight: 6),
        ),
      ]),
    );
  }

  List<Widget> _buildReadOnly() {
    return [
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Column(children: [
          _DetailRow(icon: Icons.work_outline, label: 'Role', value: _profile?['role']?.toString()),
          _DetailRow(icon: Icons.location_on_outlined, label: 'Location', value: _profile?['location']?.toString()),
          _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: _profile?['phone']?.toString()),
          _DetailRow(icon: Icons.access_time, label: 'Experience', value: _profile?['experience']?.toString()),
          _DetailRow(icon: Icons.language, label: 'Languages', value: _profile?['languages']?.toString()),
          _DetailRow(icon: Icons.info_outline, label: 'Bio', value: _profile?['bio']?.toString(), isLast: true),
        ]),
      ),
    ];
  }

  List<Widget> _buildEditForm() {
    return [
      _EditField(label: 'Name', controller: _nameCtrl, icon: Icons.person_outline),
      _EditField(label: 'Phone', controller: _phoneCtrl, icon: Icons.phone_outlined, keyboard: TextInputType.phone),
      _EditField(label: 'Location', controller: _locationCtrl, icon: Icons.location_on_outlined),
      _EditField(label: 'Experience', controller: _experienceCtrl, icon: Icons.access_time),
      _EditField(label: 'Languages', controller: _languagesCtrl, icon: Icons.language),
      _EditField(label: 'Bio', controller: _bioCtrl, icon: Icons.info_outline, maxLines: 3),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => HospitalityCategoryPicker(
            initialCategoryId: _categoryId.isEmpty ? null : _categoryId,
            initialSubcategoryId: _subcategoryId.isEmpty ? null : _subcategoryId,
            initialRoleId: _roleId.isEmpty ? null : _roleId,
            onSelected: (c, s, r) => setState(() { _categoryId = c; _subcategoryId = s; _roleId = r; }),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: const Icon(Icons.restaurant_menu, size: 16, color: AppColors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _roleId.isNotEmpty ? HospitalityCatalog.displayPath(categoryId: _categoryId, subcategoryId: _subcategoryId, roleId: _roleId) : 'Select category & role',
              style: TextStyle(fontSize: 15, color: _roleId.isNotEmpty ? AppColors.charcoal : AppColors.tertiary),
            )),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _saving ? null : _saveProfile,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Profile'),
        ),
      ),
    ];
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;
  const _DetailRow({required this.icon, required this.label, this.value, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.teal),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
          const Spacer(),
          Flexible(child: Text(value!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), textAlign: TextAlign.right)),
        ]),
      ),
      if (!isLast) Divider(height: 1, color: AppColors.divider, indent: 56),
    ]);
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboard;
  final int maxLines;
  const _EditField({required this.label, required this.controller, required this.icon, this.keyboard, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(controller: controller, keyboardType: keyboard, maxLines: maxLines, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18))),
  );
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AccountRow({required this.icon, required this.label, this.color = AppColors.charcoal, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: color))),
        const Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
      ]),
    ),
  );
}
