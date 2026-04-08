import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';
import 'package:plagit/services/auth_service.dart';

/// Business profile tab — mirrors BusinessRealProfileView.swift.
class BusinessProfileTab extends StatefulWidget {
  const BusinessProfileTab({super.key});

  @override
  State<BusinessProfileTab> createState() => _BusinessProfileTabState();
}

class _BusinessProfileTabState extends State<BusinessProfileTab> {
  final _service = BusinessService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  final _companyNameCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _venueTypeCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getProfile();
      final profile = (data['profile'] ?? data['business'] ?? data) as Map<String, dynamic>;
      if (mounted) setState(() {
        _profile = profile;
        _companyNameCtrl.text = profile['companyName']?.toString() ?? profile['company_name']?.toString() ?? '';
        _contactPersonCtrl.text = profile['contactPerson']?.toString() ?? profile['contact_person']?.toString() ?? '';
        _phoneCtrl.text = profile['phone']?.toString() ?? '';
        _locationCtrl.text = profile['location']?.toString() ?? '';
        _venueTypeCtrl.text = profile['venueType']?.toString() ?? profile['venue_type']?.toString() ?? '';
        _websiteCtrl.text = profile['website']?.toString() ?? '';
        _descriptionCtrl.text = profile['description']?.toString() ?? '';
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
        'company_name': _companyNameCtrl.text.trim(),
        'contact_person': _contactPersonCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'venue_type': _venueTypeCtrl.text.trim(),
        'website': _websiteCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
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
    _companyNameCtrl.dispose();
    _contactPersonCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _venueTypeCtrl.dispose();
    _websiteCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.indigo))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: AppColors.urgent)),
                  TextButton(onPressed: _loadProfile, child: const Text('Retry')),
                ]))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Header ──
                    Row(
                      children: [
                        const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _editing = !_editing),
                          child: Text(_editing ? 'Cancel' : 'Edit', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.indigo)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Avatar + company name ──
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.indigo.withValues(alpha: 0.12),
                            child: Text(
                              (_companyNameCtrl.text.isNotEmpty ? _companyNameCtrl.text[0].toUpperCase() : 'B'),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.indigo),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _profile?['companyName']?.toString() ?? _profile?['company_name']?.toString() ?? '',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                          ),
                          if (_profile?['email'] != null)
                            Text(_profile!['email'].toString(), style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_editing) ..._buildEditForm() else ..._buildReadOnly(),

                    const SizedBox(height: 32),

                    // ── Logout ──
                    Center(
                      child: TextButton(
                        onPressed: _logout,
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.urgent, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
    );
  }

  List<Widget> _buildReadOnly() {
    return [
      _ReadOnlyField(label: 'Company', value: _profile?['companyName']?.toString() ?? _profile?['company_name']?.toString()),
      _ReadOnlyField(label: 'Contact Person', value: _profile?['contactPerson']?.toString() ?? _profile?['contact_person']?.toString()),
      _ReadOnlyField(label: 'Phone', value: _profile?['phone']?.toString()),
      _ReadOnlyField(label: 'Location', value: _profile?['location']?.toString()),
      _ReadOnlyField(label: 'Venue Type', value: _profile?['venueType']?.toString() ?? _profile?['venue_type']?.toString()),
      _ReadOnlyField(label: 'Website', value: _profile?['website']?.toString()),
      _ReadOnlyField(label: 'Description', value: _profile?['description']?.toString()),
    ];
  }

  List<Widget> _buildEditForm() {
    return [
      _EditField(label: 'Company Name', controller: _companyNameCtrl, icon: Icons.store_outlined),
      _EditField(label: 'Contact Person', controller: _contactPersonCtrl, icon: Icons.person_outline),
      _EditField(label: 'Phone', controller: _phoneCtrl, icon: Icons.phone_outlined, keyboard: TextInputType.phone),
      _EditField(label: 'Location', controller: _locationCtrl, icon: Icons.location_on_outlined),
      _EditField(label: 'Venue Type', controller: _venueTypeCtrl, icon: Icons.restaurant_outlined),
      _EditField(label: 'Website', controller: _websiteCtrl, icon: Icons.language_outlined, keyboard: TextInputType.url),
      _EditField(label: 'Description', controller: _descriptionCtrl, icon: Icons.info_outline, maxLines: 3),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _saving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Profile'),
        ),
      ),
    ];
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String? value;
  const _ReadOnlyField({required this.label, this.value});
  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
            const Spacer(),
            Flexible(child: Text(value!, style: const TextStyle(fontSize: 15, color: AppColors.charcoal), textAlign: TextAlign.right)),
          ],
        ),
      ),
    );
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
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18)),
    ),
  );
}
