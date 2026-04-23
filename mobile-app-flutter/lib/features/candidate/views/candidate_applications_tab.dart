import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/application.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class CandidateApplicationsTab extends StatefulWidget {
  const CandidateApplicationsTab({super.key});

  @override
  State<CandidateApplicationsTab> createState() =>
      _CandidateApplicationsTabState();
}

class _CandidateApplicationsTabState extends State<CandidateApplicationsTab> {
  static const _filters = [
    'All',
    'Applied',
    'Under Review',
    'Interview Scheduled',
    'Shortlisted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateApplicationsProvider>().load();
    });
  }

  Color _avatarColor(String name) {
    final hue = (name.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.50).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.candidateApplicationsL10n;
    final provider = context.watch<CandidateApplicationsProvider>();

    // Loading state
    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n.myApplicationsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // Error state
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n.myApplicationsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<CandidateApplicationsProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = provider.applications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.myApplicationsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter tab bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final selected = provider.filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => provider.setFilter(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: selected
                                ? AppColors.teal
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          l10n.filterLabel(f),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              l10n.applicationCount(filtered.length),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Application list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noApplicationsFound,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final app = filtered[i];
                      return _ApplicationCard(
                        app: app,
                        avatarColor: _avatarColor(app.company),
                        statusText: l10n.statusLabel(app.status.displayName),
                        appliedText: l10n.appliedDate(app.date),
                        onTap: () => context.push(
                          '/candidate/application/${app.id}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application app;
  final Color avatarColor;
  final String statusText;
  final String appliedText;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.app,
    required this.avatarColor,
    required this.statusText,
    required this.appliedText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = app.company.isNotEmpty ? app.company[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.jobTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${app.company} \u00B7 ${app.location}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: statusText),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  appliedText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.tertiary,
                  ),
                ),
                const Spacer(),
                const ForwardChevron(size: 20, color: AppColors.tertiary,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension _CandidateApplicationsL10n on BuildContext {
  _CandidateApplicationsStrings get candidateApplicationsL10n =>
      _CandidateApplicationsStrings(Localizations.localeOf(this).languageCode);
}

class _CandidateApplicationsStrings {
  final String _lang;
  const _CandidateApplicationsStrings(this._lang);

  String get myApplicationsTitle => _lang == 'it'
      ? 'Le mie candidature'
      : _lang == 'ar'
          ? 'طلباتي'
          : 'My Applications';

  String get retryAction => _lang == 'it'
      ? 'Riprova'
      : _lang == 'ar'
          ? 'إعادة المحاولة'
          : 'Retry';

  String applicationCount(int count) => _lang == 'it'
      ? '$count candidatur${count == 1 ? 'a' : 'e'}'
      : _lang == 'ar'
          ? '$count طلب${count == 1 ? '' : 'ات'}'
          : '$count application${count == 1 ? '' : 's'}';

  String get noApplicationsFound => _lang == 'it'
      ? 'Nessuna candidatura trovata'
      : _lang == 'ar'
          ? 'لم يتم العثور على طلبات'
          : 'No applications found';

  String appliedDate(String date) => _lang == 'it'
      ? 'Candidatura inviata $date'
      : _lang == 'ar'
          ? 'تم التقديم $date'
          : 'Applied $date';

  String filterLabel(String value) {
    switch (value) {
      case 'All':
        return _lang == 'it'
            ? 'Tutte'
            : _lang == 'ar'
                ? 'الكل'
                : 'All';
      default:
        return statusLabel(value);
    }
  }

  String statusLabel(String value) {
    switch (value) {
      case 'Applied':
        return _lang == 'it'
            ? 'Inviata'
            : _lang == 'ar'
                ? 'تم التقديم'
                : 'Applied';
      case 'Under Review':
        return _lang == 'it'
            ? 'In revisione'
            : _lang == 'ar'
                ? 'قيد المراجعة'
                : 'Under Review';
      case 'Interview Scheduled':
        return _lang == 'it'
            ? 'Colloquio fissato'
            : _lang == 'ar'
                ? 'تم تحديد المقابلة'
                : 'Interview Scheduled';
      case 'Shortlisted':
        return _lang == 'it'
            ? 'Selezionata'
            : _lang == 'ar'
                ? 'ضمن القائمة المختصرة'
                : 'Shortlisted';
      case 'Rejected':
        return _lang == 'it'
            ? 'Rifiutata'
            : _lang == 'ar'
                ? 'مرفوض'
                : 'Rejected';
      default:
        return value;
    }
  }
}
