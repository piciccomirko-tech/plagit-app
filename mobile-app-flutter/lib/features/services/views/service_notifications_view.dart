import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

/// Service module notifications view.
class ServiceNotificationsView extends StatefulWidget {
  const ServiceNotificationsView({super.key});

  @override
  State<ServiceNotificationsView> createState() =>
      _ServiceNotificationsViewState();
}

class _ServiceNotificationsViewState extends State<ServiceNotificationsView> {
  static const _orange = Color(0xFFF97316);

  String _selectedFilter = 'All';
  late List<Map<String, dynamic>> _notifications;

  static const _filters = ['All', 'Messages', 'Updates', 'Promotions'];

  @override
  void initState() {
    super.initState();
    _notifications = MockData.serviceNotifications
        .map((n) => Map<String, dynamic>.from(n))
        .toList();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'All') return _notifications;
    final type = _selectedFilter.toLowerCase();
    return _notifications.where((n) => n['type'] == type).toList();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'messages':
        return Icons.chat_bubble;
      case 'promotions':
        return Icons.local_offer;
      case 'updates':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'messages':
        return _orange;
      case 'promotions':
        return _orange;
      case 'updates':
        return AppColors.teal;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const SizedBox(height: AppSpacing.sm),
            _filterChips(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child:
                  _filtered.isEmpty ? _emptyState() : _notificationList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.chevron_left,
                    size: 28, color: AppColors.charcoal)),
          ),
          const Spacer(),
          Text(AppLocalizations.of(context).notifications,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  String _filterLabel(BuildContext context, String filter) {
    final l = AppLocalizations.of(context);
    switch (filter) {
      case 'All':
        return l.filterAll;
      case 'Messages':
        return l.messages;
      case 'Updates':
        return l.filterUpdates;
      case 'Promotions':
        return l.promotionsTab;
      default:
        return filter;
    }
  }

  Widget _filterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: _filters
            .map((f) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color:
                            _selectedFilter == f ? _orange : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: _selectedFilter == f
                            ? null
                            : Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(_filterLabel(context, f),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _selectedFilter == f
                                  ? Colors.white
                                  : AppColors.secondary)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _notificationList() {
    final list = _filtered;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: list.length,
      itemBuilder: (_, i) => _notificationTile(list[i]),
    );
  }

  Widget _notificationTile(Map<String, dynamic> n) {
    final type = n['type'] as String;
    final isRead = n['read'] as bool? ?? true;
    final icon = _iconForType(type);
    final color = _colorForType(type);

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          setState(() => n['read'] = true);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n['title'] as String,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isRead ? FontWeight.w400 : FontWeight.w600,
                          color: AppColors.charcoal)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(n['time'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.tertiary)),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: _orange, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none,
                size: 24, color: _orange),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(AppLocalizations.of(context).noNotifications,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.xs),
          Text(AppLocalizations.of(context).allCaughtUp,
              style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        ],
      ),
    );
  }
}
