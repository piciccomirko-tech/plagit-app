import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminBusinessDetailView extends StatefulWidget {
  final String businessId;
  const AdminBusinessDetailView({super.key, required this.businessId});
  @override
  State<AdminBusinessDetailView> createState() =>
      _AdminBusinessDetailViewState();
}

class _AdminBusinessDetailViewState extends State<AdminBusinessDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _noteController = TextEditingController();
  late Map<String, dynamic> _business;
  bool _featured = false;

  final _mockActivity = [
    {'icon': Icons.work_outline, 'text': 'Posted new job: Waiter', 'time': '3 days ago'},
    {'icon': Icons.person, 'text': 'Reviewed 5 applications', 'time': '4 days ago'},
    {'icon': Icons.edit, 'text': 'Updated company profile', 'time': '1 week ago'},
    {'icon': Icons.business, 'text': 'Account created', 'time': '5 months ago'},
  ];

  final _mockNotes = <Map<String, String>>[
    {
      'admin': 'Admin User',
      'text': 'Business verified. Trade license and documents confirmed.',
      'date': 'Mar 20, 2026'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _business = Map<String, dynamic>.from(
      MockData.adminBusinesses.firstWhere(
        (b) => b['id'] == widget.businessId,
        orElse: () => MockData.adminBusinesses.first,
      ),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = _business;
    final status = b['status'] as String;
    final verified = b['verified'] as String;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(b['name'] as String,
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
                // Verify / Unverify
                Expanded(
                  child: _actionBtn(
                    verified == 'Verified' ? 'Unverify' : 'Verify',
                    AppColors.teal,
                    verified != 'Verified',
                    () {
                      _showConfirmDialog(
                        verified == 'Verified'
                            ? 'Unverify Business'
                            : 'Verify Business',
                        verified == 'Verified'
                            ? 'Remove verification from ${b['name']}?'
                            : 'Mark ${b['name']} as verified?',
                        () {
                          setState(() => _business['verified'] =
                              verified == 'Verified'
                                  ? 'Unverified'
                                  : 'Verified');
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                // Suspend / Reactivate
                if (status == 'Active')
                  Expanded(
                    child: _actionBtn('Suspend', AppColors.red, false, () {
                      _showConfirmDialog('Suspend Business',
                          'Suspend ${b['name']}? All jobs will be paused.',
                          () {
                        setState(() => _business['status'] = 'Suspended');
                      });
                    }),
                  )
                else if (status == 'Suspended')
                  Expanded(
                    child:
                        _actionBtn('Reactivate', AppColors.green, true, () {
                      _showConfirmDialog(
                          'Reactivate Business', 'Reactivate ${b['name']}?',
                          () {
                        setState(() => _business['status'] = 'Active');
                      });
                    }),
                  ),
                const SizedBox(width: 6),
                // Feature / Unfeature
                Expanded(
                  child: _actionBtn(
                    _featured ? 'Unfeature' : 'Feature',
                    AppColors.amber,
                    !_featured,
                    () => setState(() => _featured = !_featured),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileCard(b),
                  const SizedBox(height: 16),
                  _statsRow(b),
                  const SizedBox(height: 16),
                  // Tabs
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
                          tabs: const [
                            Tab(text: 'Profile'),
                            Tab(text: 'Jobs'),
                            Tab(text: 'Activity'),
                            Tab(text: 'Notes'),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabCtrl,
                            children: [
                              _profileTab(b),
                              _jobsTab(b),
                              _activityTab(),
                              _notesTab(),
                            ],
                          ),
                        ),
                      ],
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

  Widget _profileCard(Map<String, dynamic> b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(b['initials'] as String,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy)),
          ),
          const SizedBox(height: 10),
          Text(b['name'] as String,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal)),
          const SizedBox(height: 2),
          Text(b['category'] as String,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.secondary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined,
                  size: 12, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(b['email'] as String,
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
              const Text('+44 20 7946 0958',
                  style: TextStyle(fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 12, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(b['location'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline,
                  size: 12, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text('${b['size']} employees',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 10),
          // Completion bar (mock 75%)
          Row(
            children: [
              const Text('Profile',
                  style: TextStyle(fontSize: 11, color: AppColors.secondary)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: const LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: AppColors.divider,
                    color: AppColors.teal,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('75%',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusBadge(status: b['status'] as String),
              const SizedBox(width: 6),
              _verifiedBadge(b['verified'] as String),
              const SizedBox(width: 6),
              _planBadge(b['plan'] as String),
            ],
          ),
          const SizedBox(height: 6),
          Text('Joined ${b['joined']}',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.tertiary)),
        ],
      ),
    );
  }

  Widget _statsRow(Map<String, dynamic> b) {
    return Row(
      children: [
        _statCard('Active Jobs', '${b['activeJobs']}', AppColors.teal),
        const SizedBox(width: 10),
        _statCard('Applicants', '12', AppColors.purple),
        const SizedBox(width: 10),
        _statCard('Interviews', '4', AppColors.amber),
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

  Widget _profileTab(Map<String, dynamic> b) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoRow('Name', b['name'] as String),
        _infoRow('Category', b['category'] as String),
        _infoRow('Email', b['email'] as String),
        _infoRow('Phone', '+44 20 7946 0958'),
        _infoRow('Location', b['location'] as String),
        _infoRow('Size', '${b['size']} employees'),
        _infoRow('Plan', b['plan'] as String),
        _infoRow('Verified', b['verified'] as String),
        _infoRow('Status', b['status'] as String),
        _infoRow('Active Jobs', '${b['activeJobs']}'),
        _infoRow('Joined', b['joined'] as String),
      ],
    );
  }

  Widget _jobsTab(Map<String, dynamic> b) {
    final businessId = b['id'] as String;
    final jobs = MockData.adminJobs
        .where((j) => j['businessId'] == businessId)
        .toList();
    if (jobs.isEmpty) {
      return const Center(
        child: Text('No jobs posted',
            style: TextStyle(fontSize: 14, color: AppColors.secondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final j = jobs[i];
        return GestureDetector(
          onTap: () => context.push('/admin/jobs/${j['id']}'),
          child: Container(
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
                      Text(j['title'] as String,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal)),
                      const SizedBox(height: 2),
                      Text(
                          '${j['location']} - ${j['salary']} - ${j['contract']}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.secondary)),
                      const SizedBox(height: 2),
                      Text('${j['applicants']} applicants',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.tertiary)),
                    ],
                  ),
                ),
                StatusBadge(status: j['status'] as String),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _activityTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mockActivity.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
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
                    hintText: 'Add a note...',
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color)),
      ),
    );
  }

  Widget _verifiedBadge(String verified) {
    final isVerified = verified == 'Verified';
    final color = isVerified ? AppColors.teal : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isVerified ? Icons.check_circle : Icons.cancel_outlined,
              size: 11, color: color),
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
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Confirm',
                style: TextStyle(
                    color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
