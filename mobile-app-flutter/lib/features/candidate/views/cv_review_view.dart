import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// CV review screen — mirrors CVReviewView.swift.
class CvReviewView extends StatefulWidget {
  const CvReviewView({super.key});

  @override
  State<CvReviewView> createState() => _CvReviewViewState();
}

class _CvReviewViewState extends State<CvReviewView> {
  final _firstNameController = TextEditingController(text: 'John');
  final _lastNameController = TextEditingController(text: 'Smith');
  final _phoneController = TextEditingController(text: '+44 7700 900000');
  final _locationController = TextEditingController(text: 'London, UK');
  final _roleController = TextEditingController(text: 'Head Chef');
  final _experienceController = TextEditingController(text: '8 years');
  final _languagesController = TextEditingController(text: 'English, Italian');
  final _skillsController = TextEditingController(text: 'Fine dining, Menu planning, Team leadership');
  final _certificationsController = TextEditingController(text: 'Level 3 Food Safety, First Aid');
  final _bioController = TextEditingController(text: 'Experienced head chef with a passion for Mediterranean cuisine and team development.');

  String _jobType = 'Full-time';
  bool _isSaving = false;

  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Contract', 'Freelance', 'Temporary', 'Flexible'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _roleController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    _skillsController.dispose();
    _certificationsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Back', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
        ),
        title: const Text('Review Your Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.online.withValues(alpha: 0.1)),
                    child: const Icon(Icons.check_circle, size: 28, color: AppColors.online),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Text(
                      'We extracted the details below from your CV. Please review, edit if needed, and confirm before saving.',
                      style: TextStyle(fontSize: 13, color: AppColors.secondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text('Nothing will be saved until you confirm.', style: TextStyle(fontSize: 10, color: AppColors.tertiary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Personal Details
            _buildFieldCard('Personal Details', [
              _buildEditField('First Name', _firstNameController, Icons.person),
              _buildEditField('Last Name', _lastNameController, Icons.person),
              _buildEditField('Phone Number', _phoneController, Icons.phone, keyboard: TextInputType.phone),
              _buildEditField('Location', _locationController, Icons.location_on),
            ]),
            const SizedBox(height: AppSpacing.xl),
            // Professional
            _buildFieldCard('Professional', [
              _buildEditField('Job Role', _roleController, Icons.work),
              _buildEditField('Years of Experience', _experienceController, Icons.schedule),
              _buildJobTypePicker(),
            ]),
            const SizedBox(height: AppSpacing.xl),
            // Languages & Skills
            _buildFieldCard('Languages & Skills', [
              _buildEditField('Languages', _languagesController, Icons.language),
              _buildEditField('Skills', _skillsController, Icons.star),
              _buildEditField('Certifications', _certificationsController, Icons.military_tech),
            ]),
            const SizedBox(height: AppSpacing.xl),
            // Bio
            if (_bioController.text.isNotEmpty)
              _buildFieldCard('About', [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.format_align_left, size: 12, color: AppColors.teal),
                        SizedBox(width: AppSpacing.xs),
                        Text('Bio', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _bioController,
                      maxLines: null,
                      minLines: 3,
                      style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ]),
            const SizedBox(height: AppSpacing.lg),
            // Note
            const Center(
              child: Text('You can edit any extracted field before saving.', style: TextStyle(fontSize: 10, color: AppColors.tertiary)),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Save button
            GestureDetector(
              onTap: _isSaving ? null : _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(AppRadius.full)),
                alignment: Alignment.center,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, size: 14, color: Colors.white),
                          SizedBox(width: AppSpacing.sm),
                          Text('Save to Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.lg),
          ...children.map((c) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: c)),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.teal),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: AppColors.tertiary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobTypePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.badge, size: 12, color: AppColors.teal),
            SizedBox(width: AppSpacing.xs),
            Text('Job Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _jobTypes.map((type) {
              final active = _jobType == type;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => setState(() => _jobType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: active ? AppColors.teal : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(type, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _save() {
    setState(() => _isSaving = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSaving = false);
        context.pop();
      }
    });
  }
}
