import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

const _orange = Color(0xFFF97316);

class ServiceRegisterView extends StatefulWidget {
  const ServiceRegisterView({super.key});

  @override
  State<ServiceRegisterView> createState() => _ServiceRegisterViewState();
}

class _ServiceRegisterViewState extends State<ServiceRegisterView> {
  int _step = 0;
  bool _submitted = false;

  // Step 0
  final _nameCtrl = TextEditingController();
  int _selectedCategory = -1;
  final _subcategoryCtrl = TextEditingController();

  // Step 1
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  // Step 2
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subcategoryCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () {
            if (_submitted || _step == 0) {
              context.pop();
            } else {
              setState(() => _step--);
            }
          },
        ),
        title: const Text(
          'Register Your Business',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: i <= _step ? AppColors.teal : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _step == 0
                ? _buildStep0()
                : _step == 1
                    ? _buildStep1()
                    : _buildStep2(),
          ),
        ),
      ],
    );
  }

  // ── Step 0: Business Info ──
  Widget _buildStep0() {
    final categories = MockData.serviceCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Company Name',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        _textField(_nameCtrl, 'Enter company name'),
        const SizedBox(height: 16),
        const Text('Category',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(categories.length, (i) {
            final cat = categories[i];
            final selected = _selectedCategory == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _orange : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: selected ? null : Border.all(color: AppColors.divider),
                ),
                child: Text(
                  cat['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.white : AppColors.secondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        const Text('Subcategory (optional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        _textField(_subcategoryCtrl, 'e.g. Florist, DJ Services'),
        const SizedBox(height: 32),
        _primaryButton(
          'Next',
          enabled: _nameCtrl.text.trim().isNotEmpty,
          onTap: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  // ── Step 1: Location & Contact ──
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        _textField(_addressCtrl, 'Street address', icon: Icons.pin_drop),
        const SizedBox(height: 16),
        const Text('City',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        _textField(_cityCtrl, 'City'),
        const SizedBox(height: 16),
        const Text('Phone',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        _textField(_phoneCtrl, 'Phone number'),
        const SizedBox(height: 16),
        const Text('Website (optional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        _textField(_websiteCtrl, 'www.example.com'),
        const SizedBox(height: 32),
        _primaryButton(
          'Next',
          enabled: true,
          onTap: () => setState(() => _step = 2),
        ),
      ],
    );
  }

  // ── Step 2: Profile ──
  Widget _buildStep2() {
    final initials = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo upload area
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: _orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: initials.isNotEmpty
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Business Description',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: TextField(
            controller: _descCtrl,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Describe your business...',
              hintStyle: TextStyle(color: AppColors.tertiary, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _primaryButton(
          'Submit for Review',
          enabled: true,
          onTap: () => setState(() => _submitted = true),
        ),
      ],
    );
  }

  // ── Success State ──
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Registration Submitted!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your business will be reviewed and listed within 24 hours',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
            const SizedBox(height: 32),
            _primaryButton(
              'Browse Companies',
              enabled: true,
              onTap: () => context.go('/services/discover'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _textField(TextEditingController ctrl, String hint, {IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: ctrl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 14),
          prefixIcon: icon != null ? Icon(icon, color: AppColors.secondary, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, {required bool enabled, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.teal : AppColors.divider,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
