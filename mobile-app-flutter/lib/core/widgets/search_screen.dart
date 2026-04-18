import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/recent_searches_panel.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/recent_searches_provider.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

const _tealMain = Color(0xFF00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _tertiary = Color(0xFF9EA3AD);

/// Full-screen dedicated search view — pushed as a new route from any
/// search icon across the app.
///
/// When opened it:
///   • Autofocuses the text field so the keyboard appears immediately
///   • Shows the role-scoped Recent Searches panel underneath while the
///     query is empty
///   • Runs `resultsBuilder` live as the user types (called on every
///     `onChanged`) so results update without needing a Return press
///   • Records the term to the recent-searches provider on **submit**
///     (Return key) OR on **recent-chip tap**, never on every keystroke
///
/// The caller supplies its own `resultsBuilder(context, query)` closure so
/// the screen stays data-agnostic and each side (Candidate / Business /
/// Admin) can render the right kind of result cards.
class SearchScreen extends StatefulWidget {
  final RecentSearchScope scope;
  final String title;
  final String hintText;

  /// Called on every keystroke with the current trimmed query. Return the
  /// widget to render under the search bar. An empty query means the user
  /// cleared the field — the screen will show the Recent Searches panel
  /// automatically and will NOT call this builder.
  final Widget Function(BuildContext context, String query) resultsBuilder;

  const SearchScreen({
    super.key,
    required this.scope,
    required this.title,
    required this.hintText,
    required this.resultsBuilder,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Autofocus so the keyboard appears the moment the screen opens —
    // the whole point of a dedicated search surface.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _query = value.trim());
  }

  /// Return key → record the term in the recent-searches history.
  void _onSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    context.read<RecentSearchesProvider>().record(widget.scope, trimmed);
  }

  /// Recent-chip tap → fill the field, run the search, and move the term
  /// back to the top of the history.
  void _onTapRecent(String term) {
    _ctrl.text = term;
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: term.length));
    setState(() => _query = term);
    context.read<RecentSearchesProvider>().record(widget.scope, term);
  }

  void _clearField() {
    _ctrl.clear();
    setState(() => _query = '');
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            if (_query.isEmpty)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 4),
                  child: RecentSearchesPanel(
                    scope: widget.scope,
                    onTapTerm: _onTapRecent,
                  ),
                ),
              )
            else
              Expanded(child: widget.resultsBuilder(context, _query)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const BackChevron(size: 28, color: _charcoal),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.search, size: 18, color: _tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      onChanged: _onChanged,
                      onSubmitted: _onSubmitted,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(fontSize: 14.5, color: _charcoal),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: const TextStyle(fontSize: 14.5, color: _tertiary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: _clearField,
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 16,
                        color: _tertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _tealMain,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SEARCH RESULTS HELPERS — shared "no results" + "empty state"
// ═══════════════════════════════════════════════════════════════

/// Reusable empty-results block — shown when `resultsBuilder` finds nothing
/// for the current query. Callers can use this directly or roll their own.
class SearchNoResults extends StatelessWidget {
  final String query;
  const SearchNoResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0x1A00B5B0),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.search, size: 22, color: _tealMain),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalizations.of(context).noResultsTitle(query),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _charcoal,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).noResultsSubtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF707580)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
