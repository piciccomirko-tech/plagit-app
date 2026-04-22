import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/providers/business_providers.dart';

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

  String _localText(
    BuildContext context, {
    required String en,
    required String it,
    required String ar,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'it') return it;
    if (code == 'ar') return ar;
    return en;
  }

  String _postJobTitle(BuildContext context) =>
      _localText(context, en: 'Post a Job', it: 'Pubblica un lavoro', ar: 'نشر وظيفة');

  String _saveDraftLabel(BuildContext context) =>
      _localText(context, en: 'Save Draft', it: 'Salva bozza', ar: 'حفظ كمسودة');

  String _jobTitleLabel(BuildContext context) =>
      _localText(context, en: 'Job Title', it: 'Titolo lavoro', ar: 'عنوان الوظيفة');

  String _jobTitleHint(BuildContext context) =>
      _localText(context, en: 'e.g. Senior Waiter', it: 'es. Cameriere senior', ar: 'مثال: نادل أول');

  String _categoryLabel(BuildContext context) =>
      _localText(context, en: 'Category', it: 'Categoria', ar: 'الفئة');

  String _locationLabel(BuildContext context) =>
      _localText(context, en: 'Location', it: 'Località', ar: 'الموقع');

  String _locationHint(BuildContext context) =>
      _localText(context, en: 'e.g. Mayfair, London', it: 'es. Mayfair, Londra', ar: 'مثال: مايفير، لندن');

  String _positionsLabel(BuildContext context) =>
      _localText(context, en: 'Number of Positions', it: 'Numero di posizioni', ar: 'عدد الوظائف');

  String _nextLabel(BuildContext context) =>
      _localText(context, en: 'Next', it: 'Avanti', ar: 'التالي');

  String _salaryLabel(BuildContext context) =>
      _localText(context, en: 'Salary', it: 'Salario', ar: 'الراتب');

  String _salaryHint(BuildContext context) =>
      _localText(context, en: 'e.g. £14', it: 'es. £14', ar: 'مثال: £14');

  String _contractTypeLabel(BuildContext context) =>
      _localText(context, en: 'Contract Type', it: 'Tipo di contratto', ar: 'نوع العقد');

  String _shiftTypeLabel(BuildContext context) =>
      _localText(context, en: 'Shift Type', it: 'Tipo di turno', ar: 'نوع الوردية');

  String _startDateLabel(BuildContext context) =>
      _localText(context, en: 'Start Date', it: 'Data di inizio', ar: 'تاريخ البدء');

  String _asapLabel(BuildContext context) =>
      _localText(context, en: 'ASAP', it: 'Appena possibile', ar: 'في أقرب وقت');

  String _specificDateLabel(BuildContext context) =>
      _localText(context, en: 'Specific Date', it: 'Data specifica', ar: 'تاريخ محدد');

  String _descriptionLabel(BuildContext context) =>
      _localText(context, en: 'Job Description', it: 'Descrizione lavoro', ar: 'وصف الوظيفة');

  String _descriptionHint(BuildContext context) => _localText(
        context,
        en: 'Describe the role, responsibilities, and what makes this opportunity special...',
        it: 'Descrivi il ruolo, le responsabilità e cosa rende speciale questa opportunità...',
        ar: 'صف الدور والمسؤوليات وما الذي يجعل هذه الفرصة مميزة...',
      );

  String _charCountLabel(BuildContext context, int count) => _localText(
        context,
        en: '$count / 50 min',
        it: '$count / 50 min',
        ar: '$count / 50 حد أدنى',
      );

  String _requirementsLabel(BuildContext context) =>
      _localText(context, en: 'Requirements', it: 'Requisiti', ar: 'المتطلبات');

  String _requirementsHint(BuildContext context) =>
      _localText(context, en: 'List key requirements...', it: 'Elenca i requisiti principali...', ar: 'اذكر المتطلبات الأساسية...');

  String _benefitsLabel(BuildContext context) =>
      _localText(context, en: 'Benefits', it: 'Vantaggi', ar: 'المزايا');

  String _benefitsHint(BuildContext context) =>
      _localText(context, en: 'List benefits offered...', it: 'Elenca i benefit offerti...', ar: 'اذكر المزايا المقدمة...');

  String _markUrgentLabel(BuildContext context) =>
      _localText(context, en: 'Mark as Urgent', it: 'Segna come urgente', ar: 'تحديد كعاجلة');

  String _featuredJobLabel(BuildContext context) =>
      _localText(context, en: 'Featured Job', it: 'Lavoro in evidenza', ar: 'وظيفة مميزة');

  String _premiumLabel(BuildContext context) =>
      _localText(context, en: 'Premium', it: 'Premium', ar: 'مميز');

  String _publishJobLabel(BuildContext context) =>
      _localText(context, en: 'Publish Job', it: 'Pubblica lavoro', ar: 'نشر الوظيفة');

  String _jobPublishedHeadline(BuildContext context) =>
      _localText(context, en: 'Job Published!', it: 'Lavoro pubblicato!', ar: 'تم نشر الوظيفة!');

  String _jobPublishedSubtext(BuildContext context) => _localText(
        context,
        en: 'Your job is now live and visible to candidates',
        it: 'Il tuo lavoro è ora online e visibile ai candidati',
        ar: 'وظيفتك أصبحت الآن منشورة ومرئية للمتقدمين',
      );

  String _viewJobLabel(BuildContext context) =>
      _localText(context, en: 'View Job', it: 'Vedi lavoro', ar: 'عرض الوظيفة');

  String _postAnotherLabel(BuildContext context) =>
      _localText(context, en: 'Post Another', it: 'Pubblicane un altro', ar: 'نشر وظيفة أخرى');

  String _categoryText(BuildContext context, String id) => switch (id) {
        'Waiter' => _localText(context, en: 'Waiter', it: 'Cameriere', ar: 'نادل'),
        'Bartender' => _localText(context, en: 'Bartender', it: 'Bartender', ar: 'ساقي'),
        'Chef' => _localText(context, en: 'Chef', it: 'Chef', ar: 'طاه'),
        'Host' => _localText(context, en: 'Host', it: 'Host', ar: 'مضيف'),
        'Manager' => _localText(context, en: 'Manager', it: 'Manager', ar: 'مدير'),
        'Barista' => _localText(context, en: 'Barista', it: 'Barista', ar: 'باريستا'),
        'Sommelier' => _localText(context, en: 'Sommelier', it: 'Sommelier', ar: 'سوملييه'),
        'Kitchen Porter' => _localText(context, en: 'Kitchen Porter', it: 'Aiuto cucina', ar: 'مساعد مطبخ'),
        'Runner' => _localText(context, en: 'Runner', it: 'Runner', ar: 'مساعد خدمة'),
        _ => id,
      };

  String _contractText(BuildContext context, String id) => switch (id) {
        'Full-time' => _localText(context, en: 'Full-time', it: 'Tempo pieno', ar: 'دوام كامل'),
        'Part-time' => _localText(context, en: 'Part-time', it: 'Part-time', ar: 'دوام جزئي'),
        'Zero Hours' => _localText(context, en: 'Zero Hours', it: 'Zero ore', ar: 'ساعات صفرية'),
        'Temporary' => _localText(context, en: 'Temporary', it: 'Temporaneo', ar: 'مؤقت'),
        _ => id,
      };

  String _shiftText(BuildContext context, String id) => switch (id) {
        'Days' => _localText(context, en: 'Days', it: 'Giorni', ar: 'نهاري'),
        'Evenings' => _localText(context, en: 'Evenings', it: 'Sere', ar: 'مسائي'),
        'Nights' => _localText(context, en: 'Nights', it: 'Notti', ar: 'ليلي'),
        'Weekends' => _localText(context, en: 'Weekends', it: 'Weekend', ar: 'عطلات نهاية الأسبوع'),
        'Flexible' => _localText(context, en: 'Flexible', it: 'Flessibile', ar: 'مرن'),
        _ => id,
      };

  String _salaryPeriodText(BuildContext context, String id) => switch (id) {
        'per hour' => _localText(context, en: 'per hour', it: "all'ora", ar: 'بالساعة'),
        'per day' => _localText(context, en: 'per day', it: 'al giorno', ar: 'باليوم'),
        'per week' => _localText(context, en: 'per week', it: 'a settimana', ar: 'بالأسبوع'),
        'per month' => _localText(context, en: 'per month', it: 'al mese', ar: 'بالشهر'),
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
        title: Text(_postJobTitle(context), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        centerTitle: true,
        actions: [
          if (!_published)
            TextButton(
              onPressed: () {},
              child: Text(_saveDraftLabel(context), style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
            ),
        ],
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(_jobTitleLabel(context)),
        _textField(_titleCtrl, _jobTitleHint(context)),
        const SizedBox(height: 16),
        _label(_categoryLabel(context)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) => _chip(
            _categoryText(context, cat),
            selected: _category == cat,
            onTap: () => setState(() => _category = cat),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _label(_locationLabel(context)),
        _textField(_locationCtrl, _locationHint(context)),
        const SizedBox(height: 16),
        _label(_positionsLabel(context)),
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
          _nextLabel(context),
          enabled: _titleCtrl.text.trim().isNotEmpty,
          onPressed: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  // ── STEP 2: DETAILS ──
  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(_salaryLabel(context)),
        Row(
          children: [
            Expanded(child: _textField(_salaryCtrl, _salaryHint(context), keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            ..._salaryPeriods.map((p) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _chip(_salaryPeriodText(context, p), selected: _salaryPeriod == p, onTap: () => setState(() => _salaryPeriod = p), small: true),
            )),
          ],
        ),
        const SizedBox(height: 16),
        _label(_contractTypeLabel(context)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _contractTypes.map((ct) => _chip(
            _contractText(context, ct),
            selected: _contractType == ct,
            onTap: () => setState(() => _contractType = ct),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _label(_shiftTypeLabel(context)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _shiftOptions.map((s) => _chip(
            _shiftText(context, s),
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
        _label(_startDateLabel(context)),
        Row(
          children: [
            _chip(_asapLabel(context), selected: _startDate == 'ASAP', onTap: () => setState(() => _startDate = 'ASAP')),
            const SizedBox(width: 8),
            _chip(_specificDateLabel(context), selected: _startDate != 'ASAP', onTap: () async {
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
          _nextLabel(context),
          enabled: true,
          onPressed: () => setState(() => _step = 2),
        ),
      ],
    );
  }

  // ── STEP 3: DESCRIPTION ──
  Widget _buildStep3() {
    final descLen = _descCtrl.text.length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label(_descriptionLabel(context)),
        _textArea(_descCtrl, _descriptionHint(context)),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _charCountLabel(context, descLen),
              style: TextStyle(
                fontSize: 11,
                color: descLen >= 50 ? AppColors.green : AppColors.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _label(_requirementsLabel(context)),
        _textArea(_reqCtrl, _requirementsHint(context)),
        const SizedBox(height: 16),
        _label(_benefitsLabel(context)),
        _textArea(_benefitsCtrl, _benefitsHint(context)),
        const SizedBox(height: 16),
        _toggleRow(_markUrgentLabel(context), _urgent, (v) => setState(() => _urgent = v), activeColor: AppColors.amber),
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
                child: Text(_featuredJobLabel(context), style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
              ),
              const Icon(Icons.lock_outline, size: 16, color: AppColors.tertiary),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(_premiumLabel(context), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.amber)),
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
          _publishJobLabel(context),
          enabled: descLen >= 50 && !_submitting,
          onPressed: _publishJob,
        ),
      ],
    );
  }

  // ── SUCCESS STATE ──
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: AppColors.green),
            const SizedBox(height: 16),
            Text(_jobPublishedHeadline(context), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
            const SizedBox(height: 8),
            Text(
              _jobPublishedSubtext(context),
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
                child: Text(_viewJobLabel(context), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                child: Text(_postAnotherLabel(context), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
