import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/models/notification_item.dart';
import 'package:plagit/providers/business_providers.dart';

/// Business Notifications screen.
/// Mirrors BusinessRealNotificationsView.swift with typed models.
class BusinessNotificationsView extends StatefulWidget {
  const BusinessNotificationsView({super.key});

  @override
  State<BusinessNotificationsView> createState() =>
      _BusinessNotificationsViewState();
}

class _BusinessNotificationsViewState extends State<BusinessNotificationsView> {
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
                child: Icon(Icons.chevron_left,
                    size: 22, color: AppColors.charcoal)),
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
      onTap: () {
        if (!isRead) {
          context.read<BusinessNotificationsProvider>().markRead(n.id);
        }
      },
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
                  Text(n.time,
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
