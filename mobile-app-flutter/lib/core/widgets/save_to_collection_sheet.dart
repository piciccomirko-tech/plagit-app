import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/community_provider.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFFFFFFF);
const _surface = Color(0xFFF2F3F5);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);

/// Bottom sheet for choosing a collection category to save a post into.
/// Ported from the approved Swift `SaveCategoryPickerSheet`:
///
///   • Drag handle on top
///   • Title — "Save to Collection" (or "Choose Category" when re-categorising)
///   • Compact post preview
///   • 3-column grid of categories with soft card buttons
///   • Cancel action
///
/// The sheet is reusable — the only required input is the post preview text
/// and an `onSelect` callback. The current category (if any) is highlighted.
class SaveToCollectionSheet extends StatelessWidget {
  final String postPreview;
  final SavedPostCategory? currentCategory;
  final ValueChanged<SavedPostCategory> onSelect;
  final VoidCallback? onRemove;

  const SaveToCollectionSheet({
    super.key,
    required this.postPreview,
    required this.onSelect,
    this.currentCategory,
    this.onRemove,
  });

  /// Convenience helper used by every caller — opens the sheet with the
  /// right modal config.
  static Future<void> show(
    BuildContext context, {
    required String postPreview,
    required ValueChanged<SavedPostCategory> onSelect,
    SavedPostCategory? currentCategory,
    VoidCallback? onRemove,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveToCollectionSheet(
        postPreview: postPreview,
        onSelect: onSelect,
        currentCategory: currentCategory,
        onRemove: onRemove,
      ),
    );
  }

  bool get _isReassigning => currentCategory != null;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 8;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        color: _bgMain,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // ── Drag handle ──
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 18),
                // ── Title ──
                Text(
                  _isReassigning
                      ? AppLocalizations.of(context).chooseCategory
                      : AppLocalizations.of(context).saveToCollectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _charcoal,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 6),
                // ── Post preview ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    postPreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _secondary,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // ── Category grid ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: SavedPostCategory.values.map((cat) {
                      final isSelected = currentCategory == cat;
                      return _CategoryButton(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelect(cat);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),

                if (_isReassigning && onRemove != null) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onRemove!();
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.bookmark, size: 14, color: _secondary),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context).removeFromCollection,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                // ── Cancel ──
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context).cancelAction,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _tertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final SavedPostCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        decoration: BoxDecoration(
          color: isSelected ? _tealLight : _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _tealMain.withValues(alpha: 0.55) : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _tealMain.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? _tealMain : Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: isSelected
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Icon(
                category.icon,
                size: 18,
                color: isSelected ? Colors.white : _secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizedPostCategory(context, category),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? _tealMain : _charcoal,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
