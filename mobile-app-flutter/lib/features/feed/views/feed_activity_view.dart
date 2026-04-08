import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/widgets/profile_avatar.dart';

/// Community feed notifications / activity screen.
/// Mirrors FeedActivityView.swift.
class FeedActivityView extends StatefulWidget {
  const FeedActivityView({super.key});

  @override
  State<FeedActivityView> createState() => _FeedActivityViewState();
}

class _MockFeedNotif {
  final String id;
  final String actionType;
  final String actorName;
  final String actorInitials;
  final double actorHue;
  final bool actorVerified;
  final String? preview;
  final bool isRead;
  final String timeAgo;

  const _MockFeedNotif({
    required this.id,
    required this.actionType,
    required this.actorName,
    required this.actorInitials,
    this.actorHue = 0.5,
    this.actorVerified = false,
    this.preview,
    this.isRead = false,
    required this.timeAgo,
  });
}

class _FeedActivityViewState extends State<FeedActivityView> {
  bool _isLoading = true;
  List<_MockFeedNotif> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _notifications = const [
          _MockFeedNotif(id: '1', actionType: 'like', actorName: 'Marco Rossi', actorInitials: 'MR', actorHue: 0.55, actorVerified: true, preview: 'Great opportunity!', timeAgo: '5m'),
          _MockFeedNotif(id: '2', actionType: 'comment', actorName: 'Sophie Laurent', actorInitials: 'SL', actorHue: 0.3, preview: 'I worked at a similar place, highly recommend!', timeAgo: '15m'),
          _MockFeedNotif(id: '3', actionType: 'follow', actorName: 'Carlos Mendez', actorInitials: 'CM', actorHue: 0.7, timeAgo: '1h', isRead: true),
          _MockFeedNotif(id: '4', actionType: 'like', actorName: 'Anna Schmidt', actorInitials: 'AS', actorHue: 0.15, preview: 'Looking for a new challenge', timeAgo: '3h', isRead: true),
          _MockFeedNotif(id: '5', actionType: 'comment', actorName: 'David Kim', actorInitials: 'DK', actorHue: 0.85, actorVerified: true, preview: 'Thanks for sharing this!', timeAgo: '1d', isRead: true),
        ];
        _isLoading = false;
      });
    });
  }

  String _actionText(String type) {
    switch (type) {
      case 'like':
        return 'liked your post';
      case 'comment':
        return 'commented on your post';
      case 'follow':
        return 'started following you';
      default:
        return 'interacted with your content';
    }
  }

  (IconData, Color) _actionIcon(String type) {
    switch (type) {
      case 'like':
        return (Icons.favorite, AppColors.urgent);
      case 'comment':
        return (Icons.chat_bubble, AppColors.teal);
      case 'follow':
        return (Icons.person_add, AppColors.indigo);
      default:
        return (Icons.notifications, AppColors.amber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
                  ),
                  const Spacer(),
                  const Text('Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  const Spacer(),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),

            // Content
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.teal)))
            else if (_notifications.isEmpty)
              Expanded(child: _emptyState())
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl + 44 + AppSpacing.md),
                    child: Container(height: 0.5, color: AppColors.divider),
                  ),
                  itemBuilder: (_, i) => _notifRow(_notifications[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _notifRow(_MockFeedNotif notif) {
    final (icon, color) = _actionIcon(notif.actionType);
    return Container(
      color: notif.isRead ? Colors.transparent : AppColors.teal.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(
            initials: notif.actorInitials,
            hue: notif.actorHue,
            size: 44,
            verified: notif.actorVerified,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(text: notif.actorName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                    TextSpan(text: ' ${_actionText(notif.actionType)}', style: const TextStyle(fontSize: 15, color: AppColors.secondary)),
                  ]),
                ),
                if (notif.preview != null && notif.preview!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(notif.preview!, style: const TextStyle(fontSize: 13, color: AppColors.tertiary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(notif.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, size: 14, color: color),
          if (!notif.isRead) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)),
          ],
        ],
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
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none, size: 24, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No activity yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'When people like, comment, or follow you, it will show here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
