import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/hospitality_catalog.dart';
import 'package:plagit/services/business_service.dart';
import 'package:plagit/widgets/chip_selector.dart';
import 'package:plagit/widgets/hospitality_category_picker.dart';

/// Post new job form — mirrors BusinessRealPostJobView.swift.
class BusinessPostJobView extends StatefulWidget {
  const BusinessPostJobView({super.key});

  @override
  State<BusinessPostJobView> createState() => _BusinessPostJobViewState();
}

class _BusinessPostJobViewState extends State<BusinessPostJobView> {
  final _service = BusinessService();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  final _numHiresCtrl = TextEditingController(text: '1');
  String _jobType = '';
  String _categoryId = '';
  String _subcategoryId = '';
  String _roleId = '';
  bool _isUrgent = false;
  bool _openToInternational = false;
  bool _loading = false;
  String? _error;

  bool get _canSubmit => _titleCtrl.text.trim().isNotEmpty && _descCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_rebuild);
    _descCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _service.postJob({
        'title': _titleCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'salary_range': _salaryCtrl.text.trim(),
        'contract_type': _jobType.isEmpty ? null : _jobType,
        'category': _categoryId.isEmpty ? null : _categoryId,
        'role': _roleId.isEmpty ? null : _roleId,
        'description': _descCtrl.text.trim(),
        'requirements': _reqCtrl.text.trim(),
        'is_urgent': _isUrgent,
        'open_to_international': _openToInternational,
        'num_hires': int.tryParse(_numHiresCtrl.text) ?? 1,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job posted successfully')));
        context.pop();
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _locationCtrl.dispose(); _salaryCtrl.dispose();
    _descCtrl.dispose(); _reqCtrl.dispose(); _numHiresCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => context.pop()),
              const Text('Post a Job', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            ]),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              _field('Job Title', _titleCtrl, hint: 'e.g. Senior Chef'),
              _field('Location', _locationCtrl, hint: 'e.g. Dubai, UAE'),
              _field('Salary', _salaryCtrl, hint: 'e.g. \$5,500/mo'),
              const SizedBox(height: 16),
              const Text('Employment Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
              ChipSelector(options: jobTypeChips, selected: _jobType, onSelected: (v) => setState(() => _jobType = v)),
              const SizedBox(height: 16),
              const Text('Category & Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
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
                  width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    Icon(Icons.restaurant_menu, size: 16, color: AppColors.indigo),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      _roleId.isNotEmpty ? HospitalityCatalog.displayPath(categoryId: _categoryId, subcategoryId: _subcategoryId, roleId: _roleId) : 'Select category & role',
                      style: TextStyle(fontSize: 15, color: _roleId.isNotEmpty ? AppColors.charcoal : AppColors.tertiary), overflow: TextOverflow.ellipsis,
                    )),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              _field('Description', _descCtrl, maxLines: 4, hint: 'Describe the role...'),
              _field('Requirements', _reqCtrl, maxLines: 3, hint: 'List requirements...'),
              _field('Number of Hires', _numHiresCtrl, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              _toggle('Urgent', _isUrgent, (v) => setState(() => _isUrgent = v), AppColors.urgent),
              const SizedBox(height: 8),
              _toggle('Open to International', _openToInternational, (v) => setState(() => _openToInternational = v), AppColors.indigo),
              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: AppColors.urgent, fontSize: 14))],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: (_canSubmit && !_loading) ? _submit : null,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Post Job'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, int maxLines = 1, TextInputType? keyboard}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: ctrl, maxLines: maxLines, keyboardType: keyboard, decoration: InputDecoration(labelText: label, hintText: hint)),
  );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.charcoal))),
      Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: color),
    ]),
  );
}
