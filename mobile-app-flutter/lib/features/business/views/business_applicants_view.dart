import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/providers/business_providers.dart';

/// Business Applicants tab — list of all applicants across jobs.
class BusinessApplicantsView extends StatefulWidget {
  const BusinessApplicantsView({super.key});

  @override
  State<BusinessApplicantsView> createState() => _BusinessApplicantsViewState();
}

class _BusinessApplicantsViewState extends State<BusinessApplicantsView> {
  String _selectedSort = 'Newest';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _filters = [
    'All',
    'Applied',
    'Shortlisted',
    'Under Review',
    'Interview',
    'Rejected',
  ];
  static const _sorts = ['Newest', 'Most Experienced', 'Best Match'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessApplicantsProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Applies local search on top of provider-filtered applicants.
  List<Applicant> _applySearch(List<Applicant> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            a.role.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessApplicantsProvider>();

    // ── Loading state ──
    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // ── Error state ──
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<BusinessApplicantsProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Content state ──
    final selectedFilter = provider.filter;
    final filtered = _applySearch(provider.applicants);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search applicants...',
                hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.tertiary, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
              ),
            ),
          ),

          // ── Filter tabs ──
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == selectedFilter;
                return GestureDetector(
                  onTap: () => context.read<BusinessApplicantsProvider>().setFilter(f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.teal : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: active ? null : Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Sort row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _sorts.map((s) {
                final active = s == _selectedSort;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSort = s),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.teal : AppColors.secondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // ── Count ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${filtered.length} applicants',
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 8),

          // ── Applicant list ──
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text(
                          'No applicants found',
                          style:
                              TextStyle(fontSize: 16, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _ApplicantCard(applicant: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Applicants',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Applicant applicant;
  const _ApplicantCard({required this.applicant});

  Color _avatarColor(String initials) {
    final hue = (initials.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.5, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/business/applicant/${applicant.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ── Avatar ──
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _avatarColor(applicant.initials),
                  child: Text(
                    applicant.initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // ── Info column ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              applicant.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (applicant.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: AppColors.teal),
                          ],
                        ],
                      ),
                      Text(
                        'Applying for: ${applicant.role}',
                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                      ),
                      Text(
                        '${applicant.experience} \u00B7 ${applicant.location}',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: applicant.status.displayName),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Applied ${applicant.date}',
                style: const TextStyle(fontSize: 11, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 8),
            // ── Quick actions ──
            Row(
              children: [
                _ActionButton(
                  label: '\u2713 Shortlist',
                  color: AppColors.teal,
                  onTap: () {
                    context.read<BusinessApplicantsProvider>().shortlist(applicant.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${applicant.name} shortlisted'), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: '\u2717 Reject',
                  color: AppColors.red,
                  onTap: () {
                    context.read<BusinessApplicantsProvider>().reject(applicant.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${applicant.name} rejected'), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: '\uD83D\uDCAC Message',
                  color: AppColors.secondary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Messaging coming soon'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
