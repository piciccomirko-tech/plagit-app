import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/business_providers.dart';

extension _PostJobL10nX on AppLocalizations {
  String _local({
    required String en,
    required String it,
    required String ar,
  }) {
    if (localeName.startsWith('it')) return it;
    if (localeName.startsWith('ar')) return ar;
    return en;
  }

  String get catWaiter => _local(en: 'Waiter', it: 'Cameriere', ar: 'نادل');
  String get catBartender =>
      _local(en: 'Bartender', it: 'Barman', ar: 'ساقي');
  String get catChef => _local(en: 'Chef', it: 'Chef', ar: 'شيف');
  String get catHost => _local(en: 'Host', it: 'Host', ar: 'مضيف');
  String get catManager => _local(en: 'Manager', it: 'Manager', ar: 'مدير');
  String get catBarista =>
      _local(en: 'Barista', it: 'Barista', ar: 'باريستا');
  String get catSommelier =>
      _local(en: 'Sommelier', it: 'Sommelier', ar: 'سوميلير');
  String get catKitchenPorter => _local(
    en: 'Kitchen Porter',
    it: 'Aiuto cucina',
    ar: 'مساعد مطبخ',
  );
  String get catRunner => _local(en: 'Runner', it: 'Runner', ar: 'عداء');

  String get contractFullTime => _local(
    en: 'Full-time',
    it: 'Tempo pieno',
    ar: 'دوام كامل',
  );
  String get contractPartTime => _local(
    en: 'Part-time',
    it: 'Part-time',
    ar: 'دوام جزئي',
  );
  String get contractZeroHours => _local(
    en: 'Zero Hours',
    it: 'Zero ore',
    ar: 'ساعات صفرية',
  );
  String get contractTemporary => _local(
    en: 'Temporary',
    it: 'Temporaneo',
    ar: 'مؤقت',
  );

  String get shiftDays => _local(en: 'Days', it: 'Giorni', ar: 'نهاري');
  String get shiftEvenings =>
      _local(en: 'Evenings', it: 'Sere', ar: 'مسائي');
  String get shiftNights => _local(en: 'Nights', it: 'Notti', ar: 'ليلي');
  String get shiftWeekends =>
      _local(en: 'Weekends', it: 'Weekend', ar: 'عطلات نهاية الأسبوع');
  String get shiftFlexible =>
      _local(en: 'Flexible', it: 'Flessibile', ar: 'مرن');

  String get salaryPerHour =>
      _local(en: 'per hour', it: "all'ora", ar: 'في الساعة');
  String get salaryPerDay =>
      _local(en: 'per day', it: 'al giorno', ar: 'في اليوم');
  String get salaryPerWeek =>
      _local(en: 'per week', it: 'a settimana', ar: 'في الأسبوع');
  String get salaryPerMonth =>
      _local(en: 'per month', it: 'al mese', ar: 'في الشهر');

  String get postJobTitle => _local(
    en: 'Post a Job',
    it: 'Pubblica un lavoro',
    ar: 'نشر وظيفة',
  );
  String get jobTitleLabel =>
      _local(en: 'Job Title', it: 'Titolo lavoro', ar: 'المسمى الوظيفي');
  String get jobTitleHint => _local(
    en: 'e.g. Senior Waiter',
    it: 'es. Cameriere senior',
    ar: 'مثال: نادل أول',
  );
  String get locationHint => _local(
    en: 'e.g. Mayfair, London',
    it: 'es. Mayfair, Londra',
    ar: 'مثال: مايفير، لندن',
  );
  String get numberOfPositions => _local(
    en: 'Number of Positions',
    it: 'Numero di posizioni',
    ar: 'عدد الوظائف',
  );
  String get nextButton => next;
  String get salaryLabel => _local(
    en: 'Salary',
    it: 'Stipendio',
    ar: 'الراتب',
  );
  String get salaryHint =>
      _local(en: 'e.g. £14', it: 'es. £14', ar: 'مثال: £14');
  String get contractTypeLabel => _local(
    en: 'Contract Type',
    it: 'Tipo di contratto',
    ar: 'نوع العقد',
  );
  String get shiftTypeLabel => _local(
    en: 'Shift Type',
    it: 'Tipo di turno',
    ar: 'نوع الوردية',
  );
  String get startDateLabel => _local(
    en: 'Start Date',
    it: 'Data di inizio',
    ar: 'تاريخ البدء',
  );
  String get asapChip => _local(en: 'ASAP', it: 'Appena possibile', ar: 'في أقرب وقت');
  String get specificDateChip =>
      _local(en: 'Specific Date', it: 'Data specifica', ar: 'تاريخ محدد');
  String get jobDescriptionLabel => _local(
    en: 'Job Description',
    it: 'Descrizione lavoro',
    ar: 'وصف الوظيفة',
  );
  String get jobDescriptionHint => _local(
    en: 'Describe the role, responsibilities, and expectations...',
    it: 'Descrivi ruolo, responsabilità e aspettative...',
    ar: 'اشرح الدور والمسؤوليات والتوقعات...',
  );
  String charCount(int count) => _local(
    en: '$count characters',
    it: '$count caratteri',
    ar: '$count حرفا',
  );
  String get requirementsLabel => _local(
    en: 'Requirements',
    it: 'Requisiti',
    ar: 'المتطلبات',
  );
  String get benefitsLabel =>
      _local(en: 'Benefits', it: 'Vantaggi', ar: 'المزايا');
  String get benefitsHint => _local(
    en: 'List the perks, extras, or support you offer...',
    it: 'Elenca benefit, extra o supporto che offri...',
    ar: 'اذكر المزايا أو الإضافات أو الدعم الذي تقدمه...',
  );
  String get markAsUrgent => _local(
    en: 'Mark as Urgent',
    it: 'Segna come urgente',
    ar: 'وضع علامة عاجل',
  );
  String get featuredJobToggle => _local(
    en: 'Featured Job',
    it: 'Lavoro in evidenza',
    ar: 'وظيفة مميزة',
  );
  String get premiumBadge =>
      _local(en: 'Premium', it: 'Premium', ar: 'بريميوم');
  String get publishJobButton =>
      _local(en: 'Publish Job', it: 'Pubblica lavoro', ar: 'نشر الوظيفة');
  String get jobPublishedHeadline => _local(
    en: 'Job Published!',
    it: 'Lavoro pubblicato!',
    ar: 'تم نشر الوظيفة!',
  );
  String get jobPublishedSubtext => _local(
    en: 'Your role is now live and visible to candidates.',
    it: 'Il ruolo è ora live e visibile ai candidati.',
    ar: 'أصبحت الوظيفة الآن منشورة ومرئية للمرشحين.',
  );
  String get postAnother =>
      _local(en: 'Post Another', it: 'Pubblicane un altro', ar: 'نشر وظيفة أخرى');
}

class PostJobView extends StatefulWidget {
  const PostJobView({super.key});

  @override
  State<PostJobView> createState() => _PostJobViewState();
}

class _PostJobViewState extends State<PostJobView> {
  int _step = 0;
  bool _published = false;
  bool _submitting = false;
  String? _submitError;

  // Step 1
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Mayfair, London');
  String _category = '';
  int _positions = 1;

  // Step 2
  final _salaryCtrl = TextEditingController();
  String _salaryPeriod = 'per hour';
  String _contractType = '';
  final Set<String> _shiftTypes = {};
  String _startDate = 'ASAP';

  // Step 3
  final _descCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  final _benefitsCtrl = TextEditingController();
  bool _urgent = false;
  bool _featured = false;

  static const _categories = [
    'Waiter', 'Bartender', 'Chef', 'Host', 'Manager',
    'Barista', 'Sommelier', 'Kitchen Porter', 'Runner',
  ];

  static const _contractTypes = ['Full-time', 'Part-time', 'Zero Hours', 'Temporary'];
  static const _shiftOptions = ['Days', 'Evenings', 'Nights', 'Weekends', 'Flexible'];
  static const _salaryPeriods = ['per hour', 'per day', 'per week', 'per month'];

  String _catLabel(AppLocalizations l, String id) => switch (id) {
        'Waiter' => l.catWaiter,
        'Bartender' => l.catBartender,
        'Chef' => l.catChef,
        'Host' => l.catHost,
        'Manager' => l.catManager,
        'Barista' => l.catBarista,
        'Sommelier' => l.catSommelier,
        'Kitchen Porter' => l.catKitchenPorter,
        'Runner' => l.catRunner,
        _ => id,
      };

  String _contractLabel(AppLocalizations l, String id) => switch (id) {
        'Full-time' => l.contractFullTime,
        'Part-time' => l.contractPartTime,
        'Zero Hours' => l.contractZeroHours,
        'Temporary' => l.contractTemporary,
        _ => id,
      };

  String _shiftLabel(AppLocalizations l, String id) => switch (id) {
        'Days' => l.shiftDays,
        'Evenings' => l.shiftEvenings,
        'Nights' => l.shiftNights,
        'Weekends' => l.shiftWeekends,
        'Flexible' => l.shiftFlexible,
        _ => id,
      };

  String _periodLabel(AppLocalizations l, String id) => switch (id) {
        'per hour' => l.salaryPerHour,
        'per day' => l.salaryPerDay,
        'per week' => l.salaryPerWeek,
        'per month' => l.salaryPerMonth,
        _ => id,
      };

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_rebuild);
    _descCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  void _resetForm() {
    _titleCtrl.clear();
    _locationCtrl.text = 'Mayfair, London';
    _category = '';
    _positions = 1;
    _salaryCtrl.clear();
    _salaryPeriod = 'per hour';
    _contractType = '';
    _shiftTypes.clear();
    _startDate = 'ASAP';
    _descCtrl.clear();
    _reqCtrl.clear();
    _benefitsCtrl.clear();
    _urgent = false;
    _featured = false;
    _step = 0;
    _published = false;
    _submitting = false;
    _submitError = null;
    setState(() {});
  }

  List<String> _splitMultilineValues(String raw) {
    return raw
        .split(RegExp(r'[\n,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _buildPostJobPayload() {
    final requirements = _splitMultilineValues(_reqCtrl.text);
    final benefits = _splitMultilineValues(_benefitsCtrl.text);
    final salaryValue = _salaryCtrl.text.trim();
    final salaryLabel = salaryValue.isEmpty
        ? ''
        : '$salaryValue ${_salaryPeriod == 'per hour' ? '/hr' : _salaryPeriod}';

    return {
      'title': _titleCtrl.text.trim(),
      'job_title': _titleCtrl.text.trim(),
      'category': _category,
      'positions': _positions,
      'location': _locationCtrl.text.trim(),
      'salary': salaryLabel,
      'salary_range': salaryLabel,
      'contract': _contractType,
      'contract_type': _contractType,
      'shiftTypes': _shiftTypes.toList(),
      'startDate': _startDate,
      'description': _descCtrl.text.trim(),
      'requirements': requirements,
      'job_requirements': requirements,
      'benefits': benefits,
      'job_benefits': benefits,
      'urgent': _urgent,
      'is_urgent': _urgent,
      'featured': _featured,
      'is_featured': _featured,
      'status': 'Active',
    };
  }

  Future<void> _publishJob() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      await context.read<BusinessJobsProvider>().postJob(_buildPostJobPayload());
      if (!mounted) return;
      setState(() {
        _published = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _descCtrl.dispose();
    _reqCtrl.dispose();
    _benefitsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const BackChevron(size: 28, color: AppColors.charcoal),
          onPressed: () {
            if (_published) {
              context.pop();
            } else if (_step > 0) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(l.postJobTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        centerTitle: true,
        actions: const [],
      ),
      body: Column(
        children: [
          // ── PROGRESS BAR ──
          if (!_published)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: List.generate(3, (i) {
                  final active = i <= _step;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: active ? AppColors.teal : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // ── CONTENT ──
          Expanded(
            child: _published ? _buildSuccess() : _buildStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── STEP 1: BASIC INFO ──
  Widget _buildStep1() {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(l.jobTitleLabel),
        _textField(_titleCtrl, l.jobTitleHint),
        const SizedBox(height: 16),
        _label(l.categoryLabel),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) => _chip(
            _catLabel(l, cat),
            selected: _category == cat,
            onTap: () => setState(() => _category = cat),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _label(l.locationLabel),
        _textField(_locationCtrl, l.locationHint),
        const SizedBox(height: 16),
        _label(l.numberOfPositions),
        Row(
          children: [
            _counterButton(Icons.remove, () {
              if (_positions > 1) setState(() => _positions--);
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('$_positions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
            ),
            _counterButton(Icons.add, () {
              if (_positions < 10) setState(() => _positions++);
            }),
          ],
        ),
        const SizedBox(height: 32),
        _primaryButton(
          l.nextButton,
          enabled: _titleCtrl.text.trim().isNotEmpty,
          onPressed: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  // ── STEP 2: DETAILS ──
  Widget _buildStep2() {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(l.salaryLabel),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textField(
              _salaryCtrl,
              l.salaryHint,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _salaryPeriods
                  .map(
                    (p) => _chip(
                      _periodLabel(l, p),
                      selected: _salaryPeriod == p,
                      onTap: () => setState(() => _salaryPeriod = p),
                      small: true,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _label(l.contractTypeLabel),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _contractTypes.map((ct) => _chip(
            _contractLabel(l, ct),
            selected: _contractType == ct,
            onTap: () => setState(() => _contractType = ct),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _label(l.shiftTypeLabel),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _shiftOptions.map((s) => _chip(
            _shiftLabel(l, s),
            selected: _shiftTypes.contains(s),
            onTap: () => setState(() {
              if (_shiftTypes.contains(s)) {
                _shiftTypes.remove(s);
              } else {
                _shiftTypes.add(s);
              }
            }),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _label(l.startDateLabel),
        Row(
          children: [
            _chip(l.asapChip, selected: _startDate == 'ASAP', onTap: () => setState(() => _startDate = 'ASAP')),
            const SizedBox(width: 8),
            _chip(l.specificDateChip, selected: _startDate != 'ASAP', onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _startDate = '${date.day}/${date.month}/${date.year}');
              }
            }),
            if (_startDate != 'ASAP') ...[
              const SizedBox(width: 10),
              Text(_startDate, style: const TextStyle(fontSize: 13, color: AppColors.charcoal, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
        const SizedBox(height: 32),
        _primaryButton(
          l.nextButton,
          enabled: true,
          onPressed: () => setState(() => _step = 2),
        ),
      ],
    );
  }

  // ── STEP 3: DESCRIPTION ──
  Widget _buildStep3() {
    final l = AppLocalizations.of(context);
    final descLen = _descCtrl.text.length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(l.jobDescriptionLabel),
        _textArea(_descCtrl, l.jobDescriptionHint),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.charCount(descLen),
              style: TextStyle(
                fontSize: 11,
                color: descLen >= 50 ? AppColors.green : AppColors.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _label(l.requirementsLabel),
        _textArea(_reqCtrl, l.requirementsHint),
        const SizedBox(height: 16),
        _label(l.benefitsLabel),
        _textArea(_benefitsCtrl, l.benefitsHint),
        const SizedBox(height: 16),
        _toggleRow(l.markAsUrgent, _urgent, (v) => setState(() => _urgent = v), activeColor: AppColors.amber),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(l.featuredJobToggle, style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
              ),
              const Icon(Icons.lock_outline, size: 16, color: AppColors.tertiary),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(l.premiumBadge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.amber)),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: _featured,
                onChanged: null,
                activeTrackColor: AppColors.amber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (_submitError != null) ...[
          Text(
            _submitError!,
            style: const TextStyle(fontSize: 13, color: AppColors.red),
          ),
          const SizedBox(height: 12),
        ],
        _primaryButton(
          _submitting ? '...' : l.publishJobButton,
          enabled: descLen >= 50 && !_submitting,
          onPressed: _publishJob,
        ),
      ],
    );
  }

  // ── SUCCESS STATE ──
  Widget _buildSuccess() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: AppColors.green),
            const SizedBox(height: 16),
            Text(l.jobPublishedHeadline, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
            const SizedBox(height: 8),
            Text(
              l.jobPublishedSubtext,
              style: const TextStyle(fontSize: 14, color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/business/jobs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l.viewJobAction, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l.postAnother, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPER WIDGETS ──

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
  );

  Widget _textField(TextEditingController ctrl, String hint, {TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
      ),
    );
  }

  Widget _textArea(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
      ),
    );
  }

  Widget _chip(String text, {required bool selected, required VoidCallback onTap, bool small = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: small ? 10 : 14, vertical: small ? 6 : 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.teal : AppColors.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: small ? 11 : 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.charcoal,
          ),
        ),
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.charcoal, size: 20),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged, {required Color activeColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.charcoal))),
          Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: activeColor),
        ],
      ),
    );
  }

  Widget _primaryButton(String text, {required bool enabled, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }
}
