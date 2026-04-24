import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/app_back_title_bar.dart';
import 'package:plagit/core/widgets/business_identity.dart';
import 'package:plagit/core/widgets/venue_gallery.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_profile.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/repositories/business_repository.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

const _tealMain = Color(0xFF00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _urgent = Color(0xFFF55748);

BoxShadow get _cardShadow => BoxShadow(
  color: Colors.black.withValues(alpha: 0.05),
  blurRadius: 14,
  offset: const Offset(0, 5),
);
BoxShadow get _subtleShadow => BoxShadow(
  color: Colors.black.withValues(alpha: 0.04),
  blurRadius: 10,
  offset: const Offset(0, 3),
);

extension _BusinessProfileL10n on AppLocalizations {
  String get addAction {
    switch (localeName) {
      case 'it':
        return 'Aggiungi';
      case 'ar':
        return 'إضافة';
      default:
        return 'Add';
    }
  }
}

class BusinessProfileView extends StatefulWidget {
  const BusinessProfileView({super.key});
  @override
  State<BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends State<BusinessProfileView> {
  final _repo = BusinessRepository();
  bool _loading = false;
  String? _error;
  bool _editing = false;
  bool _saving = false;
  String? _saveError;
  late TextEditingController _nameCtrl,
      _phoneCtrl,
      _locationCtrl,
      _categoryCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _categoryCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<BusinessAuthProvider>().profile == null) _load();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<BusinessAuthProvider>().refreshProfile();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  void _startEditing(BusinessProfile p) {
    _nameCtrl.text = p.name;
    _phoneCtrl.text = p.phone ?? '';
    _locationCtrl.text = p.location;
    _categoryCtrl.text = p.category;
    setState(() {
      _editing = true;
      _saveError = null;
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await _repo.updateProfile({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
      });
      if (mounted) {
        await context.read<BusinessAuthProvider>().refreshProfile();
        setState(() => _editing = false);
      }
    } catch (e) {
      if (mounted) setState(() => _saveError = e.toString());
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<BusinessAuthProvider>();
    final profile = auth.profile;

    if (profile == null) {
      return Scaffold(
        backgroundColor: _bgMain,
        body: SafeArea(
          child: Center(
            child: _loading
                ? const CircularProgressIndicator(
                    color: _tealMain,
                    strokeWidth: 2.5,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business, size: 40, color: _tertiary),
                      const SizedBox(height: 12),
                      Text(
                        _error ?? 'Profile not available',
                        style: const TextStyle(fontSize: 14, color: _secondary),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _load,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _tealMain,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            AppBackTitleBar(
              title: l.companyProfile,
              onBack: () => context.canPop() ? context.pop() : null,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              backBackgroundColor: _surface,
              backIcon: const BackChevron(size: 18, color: _charcoal,),
              titleStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _charcoal,
              ),
              trailing: GestureDetector(
                onTap: _saving
                    ? null
                    : _editing
                    ? _save
                    : () => _startEditing(profile),
                child: _saving
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _tealMain,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _editing
                            ? AppLocalizations.of(context).save
                            : AppLocalizations.of(context).editAction,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _tealMain,
                        ),
                      ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 4, bottom: 32),
                child: Column(
                  children: [
                    // HERO CARD
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [_cardShadow],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 76,
                                height: 76,
                                child: Stack(
                                  children: [
                                    // Identity chain: logo > venue cover > first gallery
                                    // image > category-themed fallback. Never empty —
                                    // even a brand-new business gets a polished slot.
                                    BusinessIdentity(
                                      initials: profile.initials,
                                      category: profile.category,
                                      logoUrl: profile.logoUrl,
                                      coverImage: profile.coverImage,
                                      galleryImages: profile.galleryImages,
                                      size: 72,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: _tealMain,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            profile.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: _charcoal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (profile.profileCompletion >=
                                            80) ...[
                                          const SizedBox(width: 6),
                                          PhosphorIcon(
                                            PhosphorIconsFill.sealCheck,
                                            size: 18,
                                            color: _tealMain,
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (profile.category.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        profile.category,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: _secondary,
                                        ),
                                      ),
                                    ],
                                    if (profile.location.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 10,
                                            color: _tealMain,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              profile.location,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: _tealMain,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ══════════════════════════════════════
                    // VENUE GALLERY (photos + optional video)
                    // ══════════════════════════════════════
                    if (!_editing) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.photo_on_rectangle,
                              size: 16,
                              color: _tealMain,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l.venueGallery,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const Spacer(),
                            if (profile.galleryImages.isNotEmpty)
                              Text(
                                l.photosCount(profile.galleryImages.length),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _tealMain.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.add,
                                      size: 12,
                                      color: _tealMain,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context).addAction,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _tealMain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: VenueGallery(
                          images: profile.galleryImages,
                          videoUrl: profile.videoUrl,
                          height: 220,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (_editing) ...[
                      _buildEditForm(profile),
                    ] else ...[
                      _infoCard('Business Details', [
                        (Icons.business, 'Business Name', profile.name),
                        (Icons.category, 'Category', profile.category),
                        (
                          Icons.location_on,
                          'Location',
                          profile.location.isNotEmpty
                              ? profile.location
                              : 'Not set',
                        ),
                        (
                          Icons.verified_user_outlined,
                          'Verification',
                          profile.profileCompletion >= 80
                              ? 'Verified'
                              : 'Pending',
                        ),
                      ]),
                      const SizedBox(height: 28),
                      _infoCard('Contact', [
                        (Icons.email_outlined, 'Email', profile.email),
                        (
                          Icons.phone_outlined,
                          'Phone',
                          profile.phone ?? 'Not set',
                        ),
                      ]),
                    ],
                    const SizedBox(height: 28),

                    // LOGOUT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => _showSignOutDialog(auth),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _urgent.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, size: 14, color: _urgent),
                              SizedBox(width: 8),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _urgent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(BusinessProfile p) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 16),
          _editField('Company Name', _nameCtrl),
          const SizedBox(height: 12),
          _editField('Phone', _phoneCtrl, keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _editField('Location', _locationCtrl),
          const SizedBox(height: 12),
          _editField('Category / Venue Type', _categoryCtrl),
          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Text(
              _saveError!,
              style: const TextStyle(fontSize: 13, color: _urgent),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() {
              _editing = false;
              _saveError = null;
            }),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context).cancelAction,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboard,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: _tertiary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 15, color: _charcoal),
          decoration: InputDecoration(
            filled: true,
            fillColor: _surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(String title, List<(IconData, String, String)> rows) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _secondary,
            ),
          ),
          const SizedBox(height: 16),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Icon(r.$1, size: 13, color: _tealMain),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.$2,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _tertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.$3,
                          style: const TextStyle(
                            fontSize: 15,
                            color: _charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BusinessAuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(ctx).signOutTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(ctx).signOutConfirm,
          style: const TextStyle(fontSize: 15, color: _secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).cancelAction, style: const TextStyle(color: _secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              context.go('/entry');
            },
            child: Text(
              AppLocalizations.of(ctx).signOut,
              style: const TextStyle(color: _urgent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
