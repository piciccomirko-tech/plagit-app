import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/job_card.dart';
import 'package:plagit/core/widgets/empty_state.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/repositories/candidate_repository.dart';

class SavedJobsView extends StatefulWidget {
  final CandidateRepository? repo;

  const SavedJobsView({super.key, this.repo});

  @override
  State<SavedJobsView> createState() => _SavedJobsViewState();
}

class _SavedJobsViewState extends State<SavedJobsView> {
  late Future<List<Job>> _savedJobsFuture;

  CandidateRepository get _repo => widget.repo ?? CandidateRepository();

  @override
  void initState() {
    super.initState();
    _savedJobsFuture = _loadSavedJobs();
  }

  Future<List<Job>> _loadSavedJobs() {
    return _repo.fetchSavedJobs();
  }

  void _refresh() {
    setState(() {
      _savedJobsFuture = _loadSavedJobs();
    });
  }

  void _confirmRemove(BuildContext context, CandidateJobsProvider provider, String jobId) {
    final l10n = context.savedJobsL10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeSavedTitle),
        content: Text(l10n.removeSavedSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelAction, style: const TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.toggleSave(jobId);
              _refresh();
            },
            child: Text(l10n.removeAction, style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.savedJobsL10n;
    return Consumer<CandidateJobsProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n.savedJobsTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        body: FutureBuilder<List<Job>>(
          future: _savedJobsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.retryAction),
                    ),
                  ],
                ),
              );
            }

            final jobs = snapshot.data ?? const <Job>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    l10n.savedJobsCount(jobs.length),
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                ),
                Expanded(
                  child: jobs.isEmpty
                      ? EmptyState(
                          icon: Icons.favorite_border,
                          title: l10n.emptyTitle,
                          subtitle: l10n.emptySubtitle,
                          buttonLabel: l10n.browseJobsAction,
                          onTap: () => context.push('/candidate/jobs'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: JobCard(
                                job: job.toJson(),
                                showSave: true,
                                saved: provider.isSaved(job.id),
                                onTap: () => context.push(
                                  '/candidate/job/${job.id}',
                                ),
                                onSave: () => _confirmRemove(context, provider, job.id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension _SavedJobsL10n on BuildContext {
  _SavedJobsStrings get savedJobsL10n =>
      _SavedJobsStrings(Localizations.localeOf(this).languageCode);
}

class _SavedJobsStrings {
  final String _lang;
  const _SavedJobsStrings(this._lang);

  String get removeSavedTitle => _lang == 'it'
      ? 'Rimuovere dai salvati?'
      : _lang == 'ar'
          ? 'إزالة من المحفوظات؟'
          : 'Remove from saved?';

  String get removeSavedSubtitle => _lang == 'it'
      ? 'Questa offerta verrà rimossa dalla tua lista salvata.'
      : _lang == 'ar'
          ? 'ستتم إزالة هذه الوظيفة من قائمتك المحفوظة.'
          : 'This job will be removed from your saved list.';

  String get cancelAction => _lang == 'it'
      ? 'Annulla'
      : _lang == 'ar'
          ? 'إلغاء'
          : 'Cancel';

  String get removeAction => _lang == 'it'
      ? 'Rimuovi'
      : _lang == 'ar'
          ? 'إزالة'
          : 'Remove';

  String get savedJobsTitle => _lang == 'it'
      ? 'Offerte salvate'
      : _lang == 'ar'
          ? 'الوظائف المحفوظة'
          : 'Saved Jobs';

  String get retryAction => _lang == 'it'
      ? 'Riprova'
      : _lang == 'ar'
          ? 'إعادة المحاولة'
          : 'Retry';

  String savedJobsCount(int count) => _lang == 'it'
      ? '$count offerte salvate'
      : _lang == 'ar'
          ? '$count وظائف محفوظة'
          : '$count saved jobs';

  String get emptyTitle => _lang == 'it'
      ? 'Nessuna offerta salvata'
      : _lang == 'ar'
          ? 'لا توجد وظائف محفوظة بعد'
          : 'No saved jobs yet';

  String get emptySubtitle => _lang == 'it'
      ? 'Esplora le offerte e salva quelle che ti interessano'
      : _lang == 'ar'
          ? 'تصفح الوظائف واحفظ ما يعجبك'
          : 'Browse jobs and save the ones you like';

  String get browseJobsAction => _lang == 'it'
      ? 'Esplora offerte'
      : _lang == 'ar'
          ? 'تصفح الوظائف'
          : 'Browse Jobs';
}
