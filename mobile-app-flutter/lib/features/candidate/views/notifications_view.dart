import 'package:flutter/material.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late List<Map<String, dynamic>> _notifications;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Jobs', 'Applications', 'Messages'];

  @override
  void initState() {
    super.initState();
    _notifications = MockData.notifications
        .map((n) => Map<String, dynamic>.from(n))
        .toList();
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    final type = _selectedFilter.toLowerCase();
    return _notifications.where((n) => n['type'] == type).toList();
  }

  IconData _iconForType(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'visibility':
        return Icons.visibility;
      case 'event':
        return Icons.event;
      case 'chat':
        return Icons.chat;
      case 'star':
        return Icons.star;
      case 'person':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String iconName) {
    switch (iconName) {
      case 'work':
        return AppColors.teal;
      case 'visibility':
        return AppColors.amber;
      case 'event':
        return AppColors.purple;
      case 'chat':
        return AppColors.teal;
      case 'star':
        return AppColors.gold;
      case 'person':
        return AppColors.teal;
      default:
        return AppColors.teal;
    }
  }

  void _markAsRead(int index) {
    final actualIndex = _notifications.indexOf(_filteredNotifications[index]);
    if (actualIndex != -1 && _notifications[actualIndex]['read'] == false) {
      setState(() {
        _notifications[actualIndex] = Map<String, dynamic>.from(
          _notifications[actualIndex],
        )..['read'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
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
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final selected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: selected
                            ? null
                            : Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Notification list
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final n = items[index];
                      final isRead = n['read'] == true;
                      final iconName = n['icon'] as String? ?? 'work';
                      final iconColor = _colorForType(iconName);

                      return GestureDetector(
                        onTap: () => _markAsRead(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Leading icon
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _iconForType(iconName),
                                  size: 20,
                                  color: iconColor,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title'] as String? ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isRead
                                            ? FontWeight.w400
                                            : FontWeight.w700,
                                        color: AppColors.charcoal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Time + unread dot
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    n['time'] as String? ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                  if (!isRead) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.teal,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
