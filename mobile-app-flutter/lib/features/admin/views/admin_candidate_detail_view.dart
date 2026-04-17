import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/core/widgets/professional_avatar.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminCandidateDetailView extends StatefulWidget {
  final String candidateId;
  const AdminCandidateDetailView({super.key, required this.candidateId});
  @override
  State<AdminCandidateDetailView> createState() =>
      _AdminCandidateDetailViewState();
}

class _AdminCandidateDetailViewState extends State<AdminCandidateDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _noteController = TextEditingController();
  late Map<String, dynamic> _candidate;
  bool _flagged = false;

  final _mockActivity = [
    {'icon': Icons.login, 'text': 'Logged in', 'time': '2 hours ago'},
    {'icon': Icons.edit, 'text': 'Updated profile photo', 'time': '1 day ago'},
    {
      'icon': Icons.send,
      'text': 'Applied for Waiter at The Grand London',
      'time': '2 days ago'
    },
    {
      'icon': Icons.person_add,
      'text': 'Account created',
      'time': '3 months ago'
    },
  ];

  final _mockApps = [
    {
      'title': 'Waiter',
      'business': 'The Grand London',
      'status': 'Applied',
      'date': '2 days ago'
    },
    {
      'title': 'Bartender',
      'business': 'Nobu Dubai',
      'status': 'Under Review',
      'date': '5 days ago'
    },
    {
      'title': 'Host',
      'business': 'Sketch London',
      'status': 'Interview',
      'date': '1 week ago'
    },
    {
      'title': 'Barista',
      'business': 'Cafe Royal',
      'status': 'Rejected',
      'date': '2 weeks ago'
    },
    {
      'title': 'Server',
      'business': 'Zuma Dubai',
      'status': 'Hired',
      'date': '1 month ago'
    },
  ];

  final _mockNotes = <Map<String, String>>[
    {
      'admin': 'Admin User',
      'text':
          'Candidate verified via video call. ID documents confirmed authentic.',
      'date': 'Apr 5, 2026'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    final providerItems = context.read<AdminCandidatesListProvider>().items;
    final match = providerItems.isNotEmpty
        ? providerItems.firstWhere((c) => c['id'] == widget.candidateId, orElse: () => providerItems.first)
        : MockData.adminCandidates.firstWhere((c) => c['id'] == widget.candidateId, orElse: () => MockData.adminCandidates.first);
    _candidate = Map<String, dynamic>.from(match);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = _candidate;
    final status = c['status'] as String;
    final verified = c['verified'] as String;
    final name = c['name'] as String;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(c['name'] as String,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
      ),
      body: Column(
        children: [
          // Admin actions
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                if (verified != 'Verified')
                  Expanded(
                    child: _actionBtn(l.adminActionVerify, AppColors.teal, true, () {
                      _showConfirmDialog(l.adminDialogVerifyCandidateTitle,
                          l.adminDialogVerifyBody(name), () async {
                        final ok = await context.read<AdminActionsProvider>().verifyUser((c['user_id'] ?? c['id']) as String);
                        if (ok && mounted) {
                          setState(() => _candidate['verified'] = 'Verified');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminSnackbarUserVerified), backgroundColor: AppColors.teal));
                        }
                      });
                    }),
                  ),
                if (verified != 'Verified') const SizedBox(width: 8),
                if (status == 'Active')
                  Expanded(
                    child: _actionBtn(l.adminActionSuspend, AppColors.red, false, () {
                      _showConfirmDialog(l.adminDialogSuspendCandidateTitle,
                          l.adminDialogSuspendCandidateBody(name), () async {
                        final ok = await context.read<AdminActionsProvider>().suspendUser((c['user_id'] ?? c['id']) as String);
                        if (ok && mounted) {
                          setState(() => _candidate['status'] = 'Suspended');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminSnackbarUserSuspended), backgroundColor: AppColors.red));
                        }
                      });
                    }),
                  )
                else if (status == 'Suspended')
                  Expanded(
                    child:
                        _actionBtn(l.adminActionReactivate, AppColors.green, true, () {
                      _showConfirmDialog(l.adminDialogReactivateCandidateTitle,
                          l.adminDialogReactivateBody(name), () async {
                        final ok = await context.read<AdminActionsProvider>().unsuspendUser((c['user_id'] ?? c['id']) as String);
                        if (ok && mounted) {
                          setState(() => _candidate['status'] = 'Active');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.adminSnackbarUserReactivated), backgroundColor: AppColors.green));
                        }
                      });
                    }),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileCard(c),
                  const SizedBox(height: 16),
                  _statsRow(),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabCtrl,
                          labelColor: AppColors.teal,
                          unselectedLabelColor: AppColors.secondary,
                          indicatorColor: AppColors.teal,
                          labelStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          tabs: [
                            Tab(text: l.adminTabProfile),
                            Tab(text: l.adminTabActivity),
                            Tab(text: l.adminMenuApplications),
                            Tab(text: l.adminTabNotes),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabCtrl,
                            children: [
                              _profileTab(c),
                              _activityTab(),
                              _applicationsTab(),
                              _notesTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Flag account
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _flagged = !_flagged),
                      icon: Icon(
                          _flagged ? Icons.flag : Icons.flag_outlined,
                          size: 18,
                          color: AppColors.red),
                      label: Text(
                          _flagged ? l.adminActionUnflagAccount : l.adminActionFlagAccount,
                          style: const TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(Map<String, dynamic> c) {
    final completion = (c['completion'] as int).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          // Profile imagery — uses the shared ProfilePhoto widget so a
          // system-avatar identifier in `photoUrl` automatically renders
          // the role-themed avatar instead of falling back to initials.
          ProfilePhoto(
            photoUrl: c['photoUrl'] as String?,
            initials: c['initials'] as String,
            size: 60,
          ),
          const SizedBox(height: 8),
          // Identity-source badge — tells the reviewer at a glance
          // whether this profile uses a real upload, a system avatar,
          // or no image at all. Critical for moderation workflows.
          IdentityTypeBadge(
            type: IdentityType.classify(c['photoUrl'] as String?),
            compact: true,
          ),
          const SizedBox(height: 10),
          Text(c['name'] as String,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal)),
          const SizedBox(height: 2),
          Text(c['role'] as String,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.secondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined,
                  size: 12, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(c['email'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_outlined,
                  size: 12, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(c['phone'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 12, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(c['location'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(AppLocalizations.of(context).adminTabProfile,
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: completion / 100,
                    backgroundColor: AppColors.divider,
                    color: AppColors.teal,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${completion.toInt()}%',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusBadge(status: c['status'] as String),
              const SizedBox(width: 6),
              _verifiedBadge(c['verified'] as String),
              const SizedBox(width: 6),
              _planBadge(c['plan'] as String),
            ],
          ),
          const SizedBox(height: 6),
          Text('Joined ${c['joined']}',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.tertiary)),
        ],
      ),
    );
  }

  Widget _statsRow() {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        _statCard(l.adminMenuApplications, '5', AppColors.teal),
        const SizedBox(width: 10),
        _statCard(l.adminMenuInterviews, '2', AppColors.purple),
        const SizedBox(width: 10),
        _statCard(l.adminStatSaved, '3', AppColors.amber),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _profileTab(Map<String, dynamic> c) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoRow(l.adminFieldName, c['name'] as String),
        _infoRow(l.adminFieldRole, c['role'] as String),
        _infoRow(l.adminFieldEmail, c['email'] as String),
        _infoRow(l.adminFieldPhone, c['phone'] as String),
        _infoRow(l.adminFieldLocation, c['location'] as String),
        _infoRow(l.adminFieldPlan, c['plan'] as String),
        _infoRow(l.adminFieldVerified, c['verified'] as String),
        _infoRow(l.adminFieldStatus, c['status'] as String),
        _infoRow(l.adminFieldJoined, c['joined'] as String),
        _infoRow(l.adminFieldProfileCompletion, '${c['completion']}%'),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.secondary)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal)),
          ),
        ],
      ),
    );
  }

  Widget _activityTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mockActivity.length,
      separatorBuilder: (_, _) => const Divider(color: AppColors.divider),
      itemBuilder: (_, i) {
        final a = _mockActivity[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(a['icon'] as IconData,
                    size: 16, color: AppColors.teal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(a['text'] as String,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.charcoal)),
              ),
              Text(a['time'] as String,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.tertiary)),
            ],
          ),
        );
      },
    );
  }

  Widget _applicationsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mockApps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = _mockApps[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['title']!,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal)),
                    const SizedBox(height: 2),
                    Text(a['business']!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.secondary)),
                    const SizedBox(height: 2),
                    Text(a['date']!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.tertiary)),
                  ],
                ),
              ),
              StatusBadge(status: a['status']!),
            ],
          ),
        );
      },
    );
  }

  Widget _notesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _mockNotes.length,
              itemBuilder: (_, i) {
                final n = _mockNotes[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(n['admin']!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoal)),
                          const Spacer(),
                          Text(n['date']!,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.tertiary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(n['text']!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.secondary)),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).adminPlaceholderAddNote,
                    hintStyle: const TextStyle(
                        fontSize: 13, color: AppColors.tertiary),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (_noteController.text.isNotEmpty) {
                    setState(() {
                      _mockNotes.add({
                        'admin': 'Admin User',
                        'text': _noteController.text,
                        'date': 'Apr 8, 2026',
                      });
                      _noteController.clear();
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.send, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      String text, Color color, bool filled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: color),
        ),
        alignment: Alignment.center,
        child: Text(text,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color)),
      ),
    );
  }

  Widget _verifiedBadge(String verified) {
    IconData icon;
    Color color;
    if (verified == 'Verified') {
      icon = Icons.check_circle;
      color = AppColors.teal;
    } else if (verified == 'Pending') {
      icon = Icons.access_time;
      color = AppColors.amber;
    } else {
      icon = Icons.cancel_outlined;
      color = AppColors.secondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(verified,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _planBadge(String plan) {
    final isPremium = plan == 'Premium';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPremium
            ? AppColors.purple.withValues(alpha: 0.10)
            : AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(plan,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPremium ? AppColors.purple : AppColors.secondary)),
    );
  }

  void _showConfirmDialog(
      String title, String message, VoidCallback onConfirm) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
        content: Text(message,
            style:
                const TextStyle(fontSize: 14, color: AppColors.secondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.adminActionCancel,
                style: const TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(l.adminActionConfirm,
                style: const TextStyle(
                    color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
