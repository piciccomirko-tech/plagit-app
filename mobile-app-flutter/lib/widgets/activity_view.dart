import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Unified activity / notifications screen for both Candidate and Business.
/// Mirrors ActivityView.swift.
class ActivityView extends StatefulWidget {
  final bool isBusiness;

  const ActivityView({super.key, this.isBusiness = false});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _MockNotification {
  final String id;
  final String type;
  final String title;
  final String? route;
  final bool isRead;
  final String timeAgo;

  const _MockNotification({
    required this.id,
    required this.type,
    required this.title,
    this.route,
    this.isRead = false,
    required this.timeAgo,
  });
}

class _ActivityViewState extends State<ActivityView> {
  bool _isLoading = true;
  String _selectedFilter = 'All';
  List<_MockNotification> _items = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _items = [
          _MockNotification(id: '1', type: 'interview', title: 'Interview scheduled for Sous Chef position at The Grand Hotel', route: 'interview', timeAgo: '2m', isRead: false),
          _MockNotification(id: '2', type: 'application', title: 'Your application for Head Chef was viewed', route: 'application', timeAgo: '15m', isRead: false),
          _MockNotification(id: '3', type: 'message', title: 'New message from Marco at Ristorante Milano', route: 'message', timeAgo: '1h', isRead: false),
          _MockNotification(id: '4', type: 'match', title: 'You matched with The Ritz for Bartender position', route: 'match', timeAgo: '3h', isRead: true),
          _MockNotification(id: '5', type: 'shortlist', title: 'You were shortlisted for Front Desk Manager', route: 'shortlist', timeAgo: '5h', isRead: true),
          _MockNotification(id: '6', type: 'profile', title: 'Complete your profile to improve match quality', route: 'profile', timeAgo: '1d', isRead: true),
        ];
        _isLoading = false;
      });
    });
  }

  List<_MockNotification> get _filtered {
    if (_selectedFilter == 'Unread') return _items.where((n) => !n.isRead).toList();
    if (_selectedFilter == 'Priority') {
      return _items.where((n) => n.route == 'interview' || n.route == 'match' || n.route == 'application').toList();
    }
    return _items;
  }

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  (IconData, Color) _notifIcon(String? route) {
    switch (route) {
      case 'interview':
        return (Icons.calendar_month, AppColors.indigo);
      case 'application':
      case 'applicant':
        return (Icons.person_add, AppColors.teal);
      case 'message':
        return (Icons.chat_bubble, AppColors.amber);
      case 'shortlist':
        return (Icons.star, AppColors.amber);
      case 'match':
        return (Icons.verified, AppColors.online);
      default:
        return (Icons.notifications, AppColors.teal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            _filterRow(),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.teal)))
            else if (_filtered.isEmpty)
              Expanded(child: _emptyState())
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl + 40 + AppSpacing.md),
                    child: Container(height: 0.5, color: AppColors.divider),
                  ),
                  itemBuilder: (_, i) => _notifRow(_filtered[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          const Spacer(),
          if (_items.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, size: 22, color: AppColors.teal),
              onSelected: (v) {
                if (v == 'read_all') {
                  setState(() {
                    _items = _items.map((n) => _MockNotification(
                      id: n.id, type: n.type, title: n.title, route: n.route, isRead: true, timeAgo: n.timeAgo,
                    )).toList();
                  });
                } else if (v == 'clear') {
                  setState(() => _items = []);
                }
              },
              itemBuilder: (_) => [
                if (_unreadCount > 0)
                  const PopupMenuItem(value: 'read_all', child: Text('Mark All as Read')),
                const PopupMenuItem(value: 'clear', child: Text('Clear All', style: TextStyle(color: AppColors.urgent))),
              ],
            )
          else
            const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _filterRow() {
    final filters = [
      ('All', 'All'),
      ('Unread', 'Unread'),
      ('Priority', 'Priority'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, 0),
      child: Row(
        children: filters.map((f) {
          final active = _selectedFilter == f.$1;
          final isPriority = f.$1 == 'Priority';
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: active ? (isPriority ? AppColors.amber : AppColors.teal) : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: active ? null : Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPriority) ...[
                      Icon(Icons.bolt, size: 10, color: active ? Colors.white : AppColors.secondary),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      f.$2,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _notifRow(_MockNotification n) {
    final (icon, color) = _notifIcon(n.route);
    final isPriority = n.route == 'interview' || n.route == 'match';
    return InkWell(
      onTap: () {
        // Mark as read
        setState(() {
          final idx = _items.indexWhere((i) => i.id == n.id);
          if (idx != -1) {
            _items[idx] = _MockNotification(
              id: n.id, type: n.type, title: n.title, route: n.route, isRead: true, timeAgo: n.timeAgo,
            );
          }
        });
      },
      child: Container(
        color: n.isRead
            ? Colors.transparent
            : (isPriority ? AppColors.amber.withValues(alpha: 0.04) : AppColors.teal.withValues(alpha: 0.04)),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: n.isRead ? AppColors.surface : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: n.isRead ? AppColors.tertiary : color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w500,
                            color: AppColors.charcoal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPriority && !n.isRead) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text('Priority', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.amber)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text(n.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                      if (isPriority && !n.isRead) ...[
                        const Text(' \u{00B7} ', style: TextStyle(color: AppColors.tertiary)),
                        const Icon(Icons.bolt, size: 8, color: AppColors.amber),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: AppSpacing.sm),
                decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none, size: 24, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No activity yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.isBusiness
                  ? 'When candidates apply or send messages, you\'ll see them here.'
                  : 'When you get matches, messages, or interview invites, they\'ll appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
