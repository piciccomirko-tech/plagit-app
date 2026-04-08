import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';

/// Language model — mirrors Language struct from LanguagePickerView.swift.
class LanguageItem {
  final String code;
  final String name;
  final String nativeName;
  final String? flag;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.nativeName,
    this.flag,
  });

  static String displayLabel(Set<String> codes) {
    final byCode = {for (final l in all) l.code: l};
    return codes
        .toList()
        .where((c) => byCode.containsKey(c))
        .map((c) {
          final l = byCode[c]!;
          return l.nativeName == l.name ? l.name : '${l.nativeName} (${l.name})';
        })
        .join(', ');
  }

  static String profileLabel(Set<String> codes) {
    final byCode = {for (final l in all) l.code: l};
    final resolved = codes.toList()..sort();
    final mapped = resolved.where((c) => byCode.containsKey(c)).map((c) {
      final l = byCode[c]!;
      return l.nativeName == l.name ? l.name : '${l.nativeName} (${l.name})';
    }).toList();
    if (mapped.isEmpty) return '';
    if (mapped.length <= 3) return mapped.join(', ');
    return '${mapped.take(3).join(', ')} +${mapped.length - 3} more';
  }

  /// All languages (subset matching Swift source).
  static const List<LanguageItem> all = [
    LanguageItem(code: 'en', name: 'English', nativeName: 'English', flag: '\u{1F1EC}\u{1F1E7}'),
    LanguageItem(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '\u{1F1EE}\u{1F1F9}'),
    LanguageItem(code: 'fr', name: 'French', nativeName: 'Fran\u{00E7}ais', flag: '\u{1F1EB}\u{1F1F7}'),
    LanguageItem(code: 'es', name: 'Spanish', nativeName: 'Espa\u{00F1}ol', flag: '\u{1F1EA}\u{1F1F8}'),
    LanguageItem(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '\u{1F1E9}\u{1F1EA}'),
    LanguageItem(code: 'pt', name: 'Portuguese', nativeName: 'Portugu\u{00EA}s', flag: '\u{1F1F5}\u{1F1F9}'),
    LanguageItem(code: 'ar', name: 'Arabic', nativeName: '\u{0627}\u{0644}\u{0639}\u{0631}\u{0628}\u{064A}\u{0629}', flag: '\u{1F1F8}\u{1F1E6}'),
    LanguageItem(code: 'ru', name: 'Russian', nativeName: '\u{0420}\u{0443}\u{0441}\u{0441}\u{043A}\u{0438}\u{0439}', flag: '\u{1F1F7}\u{1F1FA}'),
    LanguageItem(code: 'zh', name: 'Chinese', nativeName: '\u{4E2D}\u{6587}', flag: '\u{1F1E8}\u{1F1F3}'),
    LanguageItem(code: 'ja', name: 'Japanese', nativeName: '\u{65E5}\u{672C}\u{8A9E}', flag: '\u{1F1EF}\u{1F1F5}'),
    LanguageItem(code: 'ko', name: 'Korean', nativeName: '\u{D55C}\u{AD6D}\u{C5B4}', flag: '\u{1F1F0}\u{1F1F7}'),
    LanguageItem(code: 'hi', name: 'Hindi', nativeName: '\u{0939}\u{093F}\u{0928}\u{094D}\u{0926}\u{0940}', flag: '\u{1F1EE}\u{1F1F3}'),
    LanguageItem(code: 'tr', name: 'Turkish', nativeName: 'T\u{00FC}rk\u{00E7}e', flag: '\u{1F1F9}\u{1F1F7}'),
    LanguageItem(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '\u{1F1F5}\u{1F1F1}'),
    LanguageItem(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '\u{1F1F3}\u{1F1F1}'),
    LanguageItem(code: 'ro', name: 'Romanian', nativeName: 'Rom\u{00E2}n\u{0103}', flag: '\u{1F1F7}\u{1F1F4}'),
    LanguageItem(code: 'el', name: 'Greek', nativeName: '\u{0395}\u{03BB}\u{03BB}\u{03B7}\u{03BD}\u{03B9}\u{03BA}\u{03AC}', flag: '\u{1F1EC}\u{1F1F7}'),
    LanguageItem(code: 'sv', name: 'Swedish', nativeName: 'Svenska', flag: '\u{1F1F8}\u{1F1EA}'),
    LanguageItem(code: 'da', name: 'Danish', nativeName: 'Dansk', flag: '\u{1F1E9}\u{1F1F0}'),
    LanguageItem(code: 'fi', name: 'Finnish', nativeName: 'Suomi', flag: '\u{1F1EB}\u{1F1EE}'),
    LanguageItem(code: 'no', name: 'Norwegian', nativeName: 'Norsk', flag: '\u{1F1F3}\u{1F1F4}'),
    LanguageItem(code: 'hr', name: 'Croatian', nativeName: 'Hrvatski', flag: '\u{1F1ED}\u{1F1F7}'),
    LanguageItem(code: 'bg', name: 'Bulgarian', nativeName: '\u{0411}\u{044A}\u{043B}\u{0433}\u{0430}\u{0440}\u{0441}\u{043A}\u{0438}', flag: '\u{1F1E7}\u{1F1EC}'),
    LanguageItem(code: 'cs', name: 'Czech', nativeName: '\u{010C}e\u{0161}tina', flag: '\u{1F1E8}\u{1F1FF}'),
    LanguageItem(code: 'hu', name: 'Hungarian', nativeName: 'Magyar', flag: '\u{1F1ED}\u{1F1FA}'),
    LanguageItem(code: 'th', name: 'Thai', nativeName: '\u{0E44}\u{0E17}\u{0E22}', flag: '\u{1F1F9}\u{1F1ED}'),
    LanguageItem(code: 'vi', name: 'Vietnamese', nativeName: 'Ti\u{1EBF}ng Vi\u{1EC7}t', flag: '\u{1F1FB}\u{1F1F3}'),
    LanguageItem(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '\u{1F1EE}\u{1F1E9}'),
    LanguageItem(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', flag: '\u{1F1F2}\u{1F1FE}'),
    LanguageItem(code: 'tl', name: 'Filipino', nativeName: 'Filipino', flag: '\u{1F1F5}\u{1F1ED}'),
    LanguageItem(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', flag: '\u{1F1F9}\u{1F1FF}'),
    LanguageItem(code: 'uk', name: 'Ukrainian', nativeName: '\u{0423}\u{043A}\u{0440}\u{0430}\u{0457}\u{043D}\u{0441}\u{044C}\u{043A}\u{0430}', flag: '\u{1F1FA}\u{1F1E6}'),
    LanguageItem(code: 'sr', name: 'Serbian', nativeName: '\u{0421}\u{0440}\u{043F}\u{0441}\u{043A}\u{0438}', flag: '\u{1F1F7}\u{1F1F8}'),
  ];
}

/// Searchable multi-select language picker — mirrors LanguagePickerView.swift.
class LanguagePicker extends StatefulWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onDone;

  const LanguagePicker({
    super.key,
    required this.selected,
    required this.onDone,
  });

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  late Set<String> _draft;
  String _search = '';

  List<LanguageItem> get _filtered {
    if (_search.isEmpty) return LanguageItem.all;
    final q = _search.toLowerCase();
    return LanguageItem.all.where((l) =>
        l.name.toLowerCase().contains(q) ||
        l.nativeName.toLowerCase().contains(q) ||
        l.code.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _draft = Set.of(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Languages', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onDone(_draft);
              Navigator.of(context).pop();
            },
            child: const Text('Done', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by name or language code',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.tertiary),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _search = ''))
                    : null,
              ),
            ),
          ),

          // Selected section
          if (_search.isEmpty && _draft.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_draft.length} selected',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                ),
              ),
            ),
            ...LanguageItem.all
                .where((l) => _draft.contains(l.code))
                .map((l) => _languageRow(l)),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('All Languages', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
              ),
            ),
          ],

          // All languages
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _languageRow(_filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageRow(LanguageItem lang) {
    final isSelected = _draft.contains(lang.code);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _draft.remove(lang.code);
          } else {
            _draft.add(lang.code);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: lang.flag != null
                  ? Text(lang.flag!, style: const TextStyle(fontSize: 18))
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                lang.nativeName == lang.name ? lang.name : '${lang.nativeName} (${lang.name})',
                style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: isSelected ? AppColors.teal : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}
