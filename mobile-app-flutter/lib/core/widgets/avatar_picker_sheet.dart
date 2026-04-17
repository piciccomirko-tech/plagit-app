/// Bottom sheet for choosing between uploading a personal photo and
/// using a professional system avatar.
///
/// Two-stage flow:
///
///   1. Entry sheet — "Upload personal photo" vs "Use professional avatar"
///      Either path returns through the same callback so the calling
///      screen only has to handle one result type.
///
///   2. Avatar picker (only if user picks the avatar route) — gender
///      selector + role-aware variant grid + confirm.
///
/// The picker is intentionally role-aware: callers pass the candidate's
/// current role string and the picker pre-selects the matching role
/// (e.g. "Head Chef" → AvatarRole.chef). The user can override the role
/// inside the picker without leaving the sheet.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plagit/core/widgets/professional_avatar.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

const _tealMain = Color(0xFF00B5B0);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _border = Color(0xFFE6E8ED);

/// Result returned through the picker callback.
sealed class AvatarPickerResult {
  const AvatarPickerResult();
}

/// User chose "upload personal photo" — caller is responsible for opening
/// the actual file picker / camera. We surface this as a separate result
/// so the picker stays decoupled from any platform image-picker plugin.
class AvatarPickerUploadRequested extends AvatarPickerResult {
  const AvatarPickerUploadRequested();
}

/// User confirmed a specific [ProfessionalAvatar] selection.
class AvatarPickerAvatarChosen extends AvatarPickerResult {
  final ProfessionalAvatar avatar;
  const AvatarPickerAvatarChosen(this.avatar);
}

/// Opens the photo-source picker. Returns the user's choice as an
/// [AvatarPickerResult], or null if the user dismissed the sheet.
Future<AvatarPickerResult?> showAvatarPickerSheet({
  required BuildContext context,
  String? currentRoleText,
  ProfessionalAvatar? currentAvatar,
}) {
  return showModalBottomSheet<AvatarPickerResult>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AvatarPickerSheet(
      currentRoleText: currentRoleText,
      currentAvatar: currentAvatar,
    ),
  );
}

class _AvatarPickerSheet extends StatefulWidget {
  final String? currentRoleText;
  final ProfessionalAvatar? currentAvatar;
  const _AvatarPickerSheet({this.currentRoleText, this.currentAvatar});

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  /// Two-stage state — entry vs avatar picker. We don't push a second
  /// route for the picker, just swap the body so the sheet feels like a
  /// single fluid surface.
  bool _showAvatarStage = false;

  late AvatarRole _selectedRole;
  late AvatarGender _selectedGender;
  int _selectedVariant = 1;

  @override
  void initState() {
    super.initState();
    final existing = widget.currentAvatar;
    _selectedRole = existing?.role ??
        AvatarRole.fromRoleText(widget.currentRoleText);
    _selectedGender = existing?.gender ?? AvatarGender.female;
    _selectedVariant = existing?.variant ?? 1;
    // Snap to a valid catalog combination so the picker never opens on
    // an empty (role, gender, variant) tuple.
    _ensureValidSelection();
    // If the candidate already has an avatar, jump straight to the
    // picker stage so editing feels natural.
    if (existing != null) _showAvatarStage = true;
  }

  ProfessionalAvatar get _currentSelection => ProfessionalAvatar(
        role: _selectedRole,
        gender: _selectedGender,
        variant: _selectedVariant,
      );

  /// Available avatars for the currently selected role — drives both the
  /// gender selector and the variant grid so the user can never land on
  /// an empty combination.
  List<ProfessionalAvatar> get _availableForSelectedRole =>
      ProfessionalAvatar.availableForRole(_selectedRole);

  /// Snaps `_selectedGender` and `_selectedVariant` to the first valid
  /// combination available for `_selectedRole`. Called whenever the
  /// role changes so the picker always shows a real photo.
  void _ensureValidSelection() {
    final available = _availableForSelectedRole;
    if (available.isEmpty) return;
    // Already on a valid combo? Nothing to do.
    final isValid = available.any((a) =>
        a.gender == _selectedGender && a.variant == _selectedVariant);
    if (isValid) return;
    // Prefer keeping the same gender if any variant exists for it.
    final sameGender =
        available.where((a) => a.gender == _selectedGender).toList();
    if (sameGender.isNotEmpty) {
      _selectedVariant = sameGender.first.variant;
      return;
    }
    // Otherwise jump to the first available combo for this role.
    final first = available.first;
    _selectedGender = first.gender;
    _selectedVariant = first.variant;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _showAvatarStage ? _buildAvatarStage() : _buildEntryStage(),
        ),
      ),
    );
  }

  // ── Stage 1: choose between upload and avatar ──
  //
  // Real photos are the primary identity standard on Plagit — the upload
  // tile is visually dominant and the avatar option is framed as a
  // fallback for candidates who can't upload right now. The avatar
  // examples row only appears once the user has explicitly chosen the
  // avatar route (stage 2), so the entry stage stays clearly upload-first.
  Widget _buildEntryStage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _grabber(),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Text(
            'Add your profile photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _charcoal,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'A real headshot is the best way to build trust with employers. You can change this anytime.',
            style: TextStyle(fontSize: 13, color: _secondary, height: 1.4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              // Primary action — visually dominant.
              _entryRow(
                icon: CupertinoIcons.camera_fill,
                title: 'Upload personal photo',
                subtitle:
                    'A real headshot builds the most trust. Use a clear, well-lit photo.',
                accent: _tealMain,
                recommended: true,
                onTap: () => Navigator.of(context)
                    .pop(const AvatarPickerUploadRequested()),
              ),
              // Secondary fallback — small text link, not a peer tile.
              // Discoverable but never visually equal to the upload action.
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _showAvatarStage = true),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Can't upload right now? ",
                          style: TextStyle(
                            fontSize: 12,
                            color: _secondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        TextSpan(
                          text: 'Use a temporary avatar →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _tealMain,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _entryRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    bool recommended = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: _charcoal,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _tealMain.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _tealMain,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _secondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ForwardChevron(size: 28, color: _tertiary),
          ],
        ),
      ),
    );
  }

  // ── Stage 2: avatar picker ──
  Widget _buildAvatarStage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _grabber(),
        const SizedBox(height: 4),
        // Header with back arrow
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showAvatarStage = false),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: BackChevron(size: 28, color: _charcoal),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Choose your avatar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _charcoal,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Live preview
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Center(
            child: ProfessionalAvatarView(
              avatar: _currentSelection,
              size: 112,
            ),
          ),
        ),

        // Role selector
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            'Role',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _secondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: AvatarRole.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final role = AvatarRole.values[i];
              final active = role == _selectedRole;
              // Skip roles with no entries in the catalog so the row only
              // shows real, pickable options.
              final hasEntries =
                  ProfessionalAvatar.availableForRole(role).isNotEmpty;
              if (!hasEntries) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedRole = role;
                  _ensureValidSelection();
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? _charcoal : _surface,
                    borderRadius: BorderRadius.circular(100),
                    border: active
                        ? null
                        : Border.all(color: _border, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(role.badgeIcon,
                          size: 13,
                          color: active ? Colors.white : _secondary),
                      const SizedBox(width: 6),
                      Text(
                        role.label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : _charcoal,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Gender selector
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            'Presentation',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _secondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: AvatarGender.values.map((g) {
              final active = g == _selectedGender;
              // Only enable genders that actually have a real photo for
              // the selected role — never let the user land on a combo
              // with no catalog entry.
              final available = _availableForSelectedRole
                  .any((a) => a.gender == g);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: available
                        ? () => setState(() {
                              _selectedGender = g;
                              _ensureValidSelection();
                            })
                        : null,
                    child: Opacity(
                      opacity: available ? 1.0 : 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: active ? _tealMain : _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: active
                              ? null
                              : Border.all(color: _border, width: 0.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          g.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : _charcoal,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Variant grid — driven by the catalog. Shows the actual real
        // photos available for (role, gender) so the user is picking
        // between concrete headshots, not abstract slot numbers.
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            'Photo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _secondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: _buildPhotoVariantsRow(),
        ),

        // Confirm
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: GestureDetector(
            onTap: () => Navigator.of(context)
                .pop(AvatarPickerAvatarChosen(_currentSelection)),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _tealMain,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Use this avatar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Renders the variant grid for the currently selected (role, gender)
  /// — pulls from the catalog so each tile is a real photo. The row
  /// scrolls horizontally when there are more than three options.
  Widget _buildPhotoVariantsRow() {
    final variants = _availableForSelectedRole
        .where((a) => a.gender == _selectedGender)
        .toList();
    if (variants.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        alignment: Alignment.center,
        child: const Text(
          'No photos available for this combination yet.',
          style: TextStyle(fontSize: 12, color: _secondary),
        ),
      );
    }
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: variants.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final preview = variants[i];
          final active = preview.variant == _selectedVariant;
          return GestureDetector(
            onTap: () => setState(() => _selectedVariant = preview.variant),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? _tealMain : _border,
                  width: active ? 2 : 0.5,
                ),
              ),
              child: ProfessionalAvatarView(
                avatar: preview,
                size: 72,
                showRoleBadge: false,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _grabber() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D1D6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}
