import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

/// Business Applicants tab — list of all applicants across jobs.
class BusinessApplicantsView extends StatefulWidget {
  const BusinessApplicantsView({super.key});

  @override
  State<BusinessApplicantsView> createState() => _BusinessApplicantsViewState();
}

class _BusinessApplicantsViewState extends State<BusinessApplicantsView> {
  String _selectedFilter = 'All';
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

  List<Map<String, dynamic>> get _filteredApplicants {
    var list = MockData.businessApplicants.cast<Map<String, dynamic>>();

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((a) =>
              (a['name']?.toString().toLowerCase().contains(q) ?? false) ||
              (a['role']?.toString().toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Status filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Interview') {
        list = list
            .where((a) =>
                a['status'] == 'Interview Scheduled' ||
                a['status'] == 'Interview')
            .toList();
      } else {
        list = list.where((a) => a['status'] == _selectedFilter).toList();
      }
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredApplicants;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      ),
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
                final active = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
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
}

class _ApplicantCard extends StatelessWidget {
  final Map<String, dynamic> applicant;
  const _ApplicantCard({required this.applicant});

  Color _avatarColor(String initials) {
    final hue = (initials.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.5, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final name = applicant['name']?.toString() ?? '';
    final initials = applicant['initials']?.toString() ?? '';
    final role = applicant['role']?.toString() ?? '';
    final experience = applicant['experience']?.toString() ?? '';
    final location = applicant['location']?.toString() ?? '';
    final status = applicant['status']?.toString() ?? '';
    final date = applicant['date']?.toString() ?? '';
    final verified = applicant['verified'] == true;

    return GestureDetector(
      onTap: () => context.push('/business/applicant/${applicant['id']}'),
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
                  backgroundColor: _avatarColor(initials),
                  child: Text(
                    initials,
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
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: AppColors.teal),
                          ],
                        ],
                      ),
                      Text(
                        'Applying for: $role',
                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                      ),
                      Text(
                        '$experience · $location',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Applied $date',
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name shortlisted'), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: '\u2717 Reject',
                  color: AppColors.red,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name rejected'), duration: const Duration(seconds: 1)),
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
