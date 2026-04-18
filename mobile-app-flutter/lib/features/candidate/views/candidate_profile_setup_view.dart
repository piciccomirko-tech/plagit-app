import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/avatar_picker_sheet.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/core/widgets/professional_avatar.dart';

/// Candidate profile setup / onboarding — mirrors CandidateProfileSetupView.swift.
class CandidateProfileSetupView extends StatefulWidget {
  const CandidateProfileSetupView({super.key});

  @override
  State<CandidateProfileSetupView> createState() => _CandidateProfileSetupViewState();
}

class _CandidateProfileSetupViewState extends State<CandidateProfileSetupView> {
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  String _jobType = '';
  final String _languages = '';
  String _startDate = 'Immediately';
  bool _availableToRelocate = false;
  String? _cvFileName;
  bool _isLoading = false;
  String? _errorMessage;

  /// Selected profile photo. Either a real upload (network/asset/base64
  /// string) or a system avatar identifier (`avatar:role:gender:variant`).
  /// Stored as a single string so it round-trips through CandidateProfile
  /// without any new field.
  String? _photoUrl;

  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Contract', 'Freelance', 'Temporary', 'Flexible'];
  final List<String> _startDateOptions = ['Immediately', 'Within 1 week', 'Within 2 weeks', 'Within 1 month', 'Flexible'];

  @override
  void dispose() {
    _locationController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: AppSpacing.xl),
              _buildIntroText(),
              const SizedBox(height: AppSpacing.xxl),
              _buildPhotoUpload(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildDetailsCard(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildCvUploadCard(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildAvailabilityCard(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildBioCard(),
              const SizedBox(height: AppSpacing.xxl),
              _buildCompleteButton(),
              const SizedBox(height: AppSpacing.lg),
              _buildSkipButton(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal)),
          ),
          const Spacer(),
          Text(AppLocalizations.of(context).completeYourProfile, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildIntroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          const Text(
            'Choose how you want to set up your profile.',
            style: TextStyle(fontSize: 15, color: AppColors.secondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Upload CV option
          GestureDetector(
            onTap: () {
              // CV parse would open file picker
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: const Icon(Icons.document_scanner, size: 16, color: AppColors.teal),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).uploadCV, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                        const SizedBox(height: 2),
                        Text(AppLocalizations.of(context).uploadCVBig, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 2),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 28, color: AppColors.tertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(AppLocalizations.of(context).supportedFormats, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
          const SizedBox(height: AppSpacing.lg),
          // Divider
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(AppLocalizations.of(context).orLabel, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
              ),
              const Expanded(child: Divider(color: AppColors.divider)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(AppLocalizations.of(context).fillManually, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          const SizedBox(height: 2),
          Text(AppLocalizations.of(context).fillManuallySubtitle, style: const TextStyle(fontSize: 10, color: AppColors.tertiary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload() {
    final hasPhoto = _photoUrl != null && _photoUrl!.isNotEmpty;
    final isAvatar = ProfessionalAvatar.isAvatarId(_photoUrl);
    return Column(
      children: [
        GestureDetector(
          onTap: _openAvatarPicker,
          behavior: HitTestBehavior.opaque,
          child: hasPhoto
              ? ProfilePhoto(
                  photoUrl: _photoUrl,
                  initials: '?',
                  size: 96,
                )
              : Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 28, color: AppColors.teal),
                ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // ── Primary action: upload a real headshot ──
        // Real personal photos are the preferred identity standard on
        // Plagit (work platform, hospitality hiring) so the upload CTA
        // is the visually dominant action. Avatar fallback is a small
        // secondary link below.
        GestureDetector(
          onTap: _openAvatarPicker,
          child: Text(
            !hasPhoto
                ? 'Upload your photo'
                : isAvatar
                    ? 'Change avatar'
                    : 'Change photo',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'A real headshot builds the most trust with employers',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.tertiary,
            letterSpacing: -0.05,
          ),
        ),
      ],
    );
  }

  /// Opens the photo source picker. The picker returns either an
  /// upload-requested signal (we'd hand off to the platform image
  /// picker) or a confirmed [ProfessionalAvatar] selection.
  Future<void> _openAvatarPicker() async {
    final result = await showAvatarPickerSheet(
      context: context,
      currentRoleText: _jobType,
      currentAvatar: ProfessionalAvatar.tryParse(_photoUrl),
    );
    if (!mounted || result == null) return;
    if (result is AvatarPickerAvatarChosen) {
      setState(() => _photoUrl = result.avatar.id);
    } else if (result is AvatarPickerUploadRequested) {
      // Real photo upload — hand off to the platform image picker.
      // Image-picker plugin integration is out of scope for this widget;
      // we surface a clear placeholder so the caller knows what to wire.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).photoUploadSoon),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).yourDetails, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.lg),
          // Category & Role
          Text(AppLocalizations.of(context).categoryAndRole, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              // Would open category picker
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  const Icon(Icons.work, size: 13, color: AppColors.teal),
                  const SizedBox(width: AppSpacing.md),
                  Text(AppLocalizations.of(context).selectCategoryRoleShort, style: const TextStyle(fontSize: 15, color: AppColors.tertiary)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 28, color: AppColors.tertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Job type chips
          Text(AppLocalizations.of(context).jobType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _jobTypes.map((type) {
              final active = _jobType == type;
              return GestureDetector(
                onTap: () => setState(() => _jobType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(type, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Input fields
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Column(
              children: [
                _buildInputRow(Icons.location_on, 'Location (e.g. London, UK)', _locationController),
                const Divider(height: 1, color: AppColors.divider),
                _buildInputRow(Icons.schedule, 'Years of Experience (e.g. 5 years)', _experienceController),
                const Divider(height: 1, color: AppColors.divider),
                GestureDetector(
                  onTap: () {
                    // Would open language picker
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 13, color: AppColors.teal),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            _languages.isEmpty ? 'Select languages' : _languages,
                            style: TextStyle(fontSize: 15, color: _languages.isEmpty ? AppColors.tertiary : AppColors.charcoal),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 28, color: AppColors.tertiary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(IconData icon, String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.teal),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: AppColors.tertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvUploadCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).yourCV, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () {
              // Would open file picker
              setState(() => _cvFileName = 'My_CV.pdf');
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Icon(_cvFileName != null ? Icons.description : Icons.note_add, size: 15, color: AppColors.teal),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_cvFileName ?? 'Upload Your CV', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(_cvFileName != null ? 'Tap to change' : 'PDF, DOC \u2014 Max 5 MB', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                  if (_cvFileName != null)
                    const Icon(Icons.check_circle, size: 14, color: AppColors.online)
                  else
                    const Icon(Icons.chevron_right, size: 28, color: AppColors.tertiary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).availability, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: PopupMenuButton<String>(
              onSelected: (val) => setState(() => _startDate = val),
              itemBuilder: (context) => _startDateOptions.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 13, color: AppColors.teal),
                    const SizedBox(width: AppSpacing.md),
                    Text(AppLocalizations.of(context).startDate, style: const TextStyle(fontSize: 15, color: AppColors.secondary)),
                    const Spacer(),
                    Text(_startDate, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.public, size: 12, color: AppColors.indigo),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(AppLocalizations.of(context).openToRelocation, style: const TextStyle(fontSize: 15, color: AppColors.charcoal))),
              Switch(
                value: _availableToRelocate,
                onChanged: (v) => setState(() => _availableToRelocate = v),
                activeTrackColor: AppColors.indigo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context).aboutYou, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Text(AppLocalizations.of(context).optional, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: TextField(
              controller: _bioController,
              maxLines: null,
              maxLength: 300,
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).writeShortIntroAboutYourself,
                hintStyle: TextStyle(color: AppColors.tertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                isDense: true,
              ),
              onChanged: (v) {
                if (v.length > 300) {
                  _bioController.text = v.substring(0, 300);
                  _bioController.selection = TextSelection.fromPosition(TextPosition(offset: 300));
                }
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_bioController.text.length} / 300',
              style: TextStyle(fontSize: 10, color: _bioController.text.length >= 280 ? AppColors.amber : AppColors.tertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(_errorMessage!, style: const TextStyle(fontSize: 13, color: AppColors.urgent)),
            ),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isLoading ? null : _saveProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(AppLocalizations.of(context).completeProfile, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: () => context.go('/candidate/home'),
      child: Text(AppLocalizations.of(context).skipForNow, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
    );
  }

  void _saveProfile() {
    setState(() { _isLoading = true; _errorMessage = null; });
    // Mock save
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/candidate/home');
      }
    });
  }
}
