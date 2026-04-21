import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/models/notification_item.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Business Notifications screen.
/// Mirrors BusinessRealNotificationsView.swift with typed models.
class BusinessNotificationsView extends StatefulWidget {
  const BusinessNotificationsView({super.key});

  @override
  State<BusinessNotificationsView> createState() =>
      _BusinessNotificationsViewState();
}

class _BusinessNotificationsViewState extends State<BusinessNotificationsView> {
  static final RegExp _compactRelativeTimePattern = RegExp(
    r'^(\d+)\s*(m|min|mins|minute|minutes|h|hr|hrs|hour|hours|d|day|days)\s*ago$',
    caseSensitive: false,
  );

  String _localizedNotificationTime(String rawTime) {
    final normalized = rawTime.trim();
    if (normalized.isEmpty) {
      return rawTime;
    }

    final lower = normalized.toLowerCase();
    if (lower == 'today') {
      return _localizedToday();
    }
    if (lower == 'yesterday') {
      return _localizedYesterday();
    }
    if (lower == 'now' || lower == 'just now') {
      return _localizedNow();
    }

    final compactMatch = _compactRelativeTimePattern.firstMatch(lower);
    if (compactMatch != null) {
      final count = int.tryParse(compactMatch.group(1) ?? '');
      final unit = compactMatch.group(2) ?? '';
      if (count == null) {
        return rawTime;
      }
      if (unit.startsWith('m')) {
        return _localizedMinutesAgo(count);
      }
      if (unit.startsWith('h')) {
        return _localizedHoursAgo(count);
      }
      if (unit.startsWith('d')) {
        return count == 1 ? _localizedYesterday() : _localizedDaysAgo(count);
      }
    }

    final parsedDate = DateTime.tryParse(normalized);
    if (parsedDate == null) {
      return rawTime;
    }

    final localDate = parsedDate.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDay =
        DateTime(localDate.year, localDate.month, localDate.day);
    final dayDiff = today.difference(notificationDay).inDays;

    if (dayDiff <= 0) {
      final diff = now.difference(localDate);
      if (diff.inMinutes < 1) {
        return _localizedNow();
      }
      if (diff.inHours < 1) {
        return _localizedMinutesAgo(diff.inMinutes);
      }
      return _localizedHoursAgo(diff.inHours);
    }
    if (dayDiff == 1) {
      return _localizedYesterday();
    }
    return _localizedDaysAgo(dayDiff);
  }

  String _languageCode() =>
      Localizations.localeOf(context).languageCode.toLowerCase();

  String _localizedToday() {
    switch (_languageCode()) {
      case 'it':
        return 'Oggi';
      case 'ar':
        return 'اليوم';
      default:
        return 'Today';
    }
  }

  String _localizedYesterday() {
    switch (_languageCode()) {
      case 'it':
        return 'Ieri';
      case 'ar':
        return 'أمس';
      default:
        return 'Yesterday';
    }
  }

  String _localizedNow() {
    switch (_languageCode()) {
      case 'it':
        return 'ora';
      case 'ar':
        return 'الآن';
      default:
        return 'now';
    }
  }

  String _localizedMinutesAgo(int count) {
    switch (_languageCode()) {
      case 'it':
        return '$count min fa';
      case 'ar':
        return count == 1 ? 'قبل دقيقة' : 'قبل $count دقائق';
      default:
        return '${count}m ago';
    }
  }

  String _localizedHoursAgo(int count) {
    switch (_languageCode()) {
      case 'it':
        return '$count h fa';
      case 'ar':
        return count == 1 ? 'قبل ساعة' : 'قبل $count ساعات';
      default:
        return '${count}h ago';
    }
  }

  String _localizedDaysAgo(int count) {
    switch (_languageCode()) {
      case 'it':
        return '$count g fa';
      case 'ar':
        return count == 1 ? 'قبل يوم' : 'قبل $count أيام';
      default:
        return '${count}d ago';
    }
  }
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Unread'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessNotificationsProvider>().load();
    });
  }

  List<NotificationItem> _applyFilter(List<NotificationItem> all) {
    if (_selectedFilter == 'Unread') {
      return all.where((n) => !n.read).toList();
    }
    return all;
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'push':
        return Icons.notifications;
      case 'email':
        return Icons.email;
      case 'in_app':
        return Icons.apps;
      case 'sms':
        return Icons.message;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessNotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(provider.unreadCount),
            _filterChips(),
            Expanded(child: _body(provider)),
          ],
        ),
      ),
    );
  }

  Widget _topBar(int unreadCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Notifications',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
          if (unreadCount > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('$unreadCount',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white)),
            ),
          ],
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xs),
      child: Row(
        children: [
          ..._filters.map((f) {
            final active = _selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: active
                        ? null
                        : Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(f,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              active ? Colors.white : AppColors.secondary)),
                ),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _body(BusinessNotificationsProvider provider) {
    // Loading state
    if (provider.loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.teal));
    }

    // Error state
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => context.read<BusinessNotificationsProvider>().load(),
              child: const Text('Retry',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.teal)),
            ),
          ],
        ),
      );
    }

    // Content
    final filtered = _applyFilter(provider.notifications);

    if (filtered.isEmpty) {
      return _emptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      itemCount: filtered.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _notificationRow(filtered[i]),
      ),
    );
  }

  Widget _notificationRow(NotificationItem n) {
    final isRead = n.read;
    return GestureDetector(
      onTap: () => _handleNotificationTap(n, isRead),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isRead ? AppColors.background : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead ? AppColors.surface : AppColors.tealLight,
              ),
              child: Icon(_typeIcon(n.type),
                  size: 14,
                  color: isRead ? AppColors.tertiary : AppColors.teal),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isRead ? FontWeight.w400 : FontWeight.w500,
                          color: AppColors.charcoal)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_localizedNotificationTime(n.time),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification, bool isRead) {
    if (!isRead) {
      context.read<BusinessNotificationsProvider>().markRead(notification.id);
    }

    final destinationRoute = notification.destinationRoute;
    if (destinationRoute == null || destinationRoute.isEmpty) {
      return;
    }

    context.push(destinationRoute);
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealLight,
              ),
              child: const Icon(Icons.notifications_none,
                  size: 20, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No notifications',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            const Text(
                'You\'ll be notified about new applicants, interviews, and messages.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}
