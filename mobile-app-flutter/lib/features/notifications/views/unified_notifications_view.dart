import 'package:flutter/material.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class UnifiedNotificationsView extends StatefulWidget {
  const UnifiedNotificationsView({super.key});

  @override
  State<UnifiedNotificationsView> createState() => _UnifiedNotificationsViewState();
}

class _UnifiedNotificationsViewState extends State<UnifiedNotificationsView> {
  static const _orange = Color(0xFFF97316);

  String _selectedFilter = 'All';
  late List<Map<String, dynamic>> _allNotifications;

  @override
  void initState() {
    super.initState();
    _allNotifications = _buildNotificationList();
  }

  List<Map<String, dynamic>> _buildNotificationList() {
    final list = <Map<String, dynamic>>[];

    for (final n in MockData.notifications) {
      list.add({
        'role': 'candidate',
        'title': n['title'] as String,
        'time': n['time'] as String,
        'read': n['read'] as bool,
        'icon': n['icon'] as String? ?? 'notifications',
      });
    }

    for (final n in MockData.businessNotifications) {
      list.add({
        'role': 'business',
        'title': n['title'] as String,
        'time': n['time'] as String,
        'read': n['read'] as bool,
        'icon': n['icon'] as String? ?? 'notifications',
      });
    }

    for (final n in MockData.serviceNotifications) {
      list.add({
        'role': 'services',
        'title': n['title'] as String,
        'time': n['time'] as String,
        'read': n['read'] as bool,
        'icon': 'storefront',
      });
    }

    return list;
  }

  void _markAllRead() {
    setState(() {
      for (final n in _allNotifications) {
        n['read'] = true;
      }
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') return _allNotifications;
    final roleKey = _selectedFilter.toLowerCase();
    return _allNotifications.where((n) => n['role'] == roleKey).toList();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'candidate':
        return AppColors.teal;
      case 'business':
        return AppColors.purple;
      case 'services':
        return _orange;
      default:
        return AppColors.teal;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'candidate':
        return 'Candidate';
      case 'business':
        return 'Business';
      case 'services':
        return 'Services';
      default:
        return role;
    }
  }

  IconData _iconFromName(String name) {
    switch (name) {
      case 'work':
        return Icons.work;
      case 'visibility':
        return Icons.visibility;
      case 'event':
        return Icons.event;
      case 'event_available':
        return Icons.event_available;
      case 'chat':
        return Icons.chat;
      case 'star':
        return Icons.star;
      case 'person':
        return Icons.person;
      case 'person_add':
        return Icons.person_add;
      case 'business':
        return Icons.business;
      case 'storefront':
        return Icons.storefront;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Candidate', 'Business', 'Services'];
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.teal, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: filters.map((f) {
                final selected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        color: selected ? Colors.white : AppColors.secondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppColors.teal,
                    backgroundColor: AppColors.background,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => setState(() => _selectedFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),

          // Notification list
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final n = filtered[index];
                      final role = n['role'] as String;
                      final isRead = n['read'] as bool;
                      final color = _roleColor(role);

                      return GestureDetector(
                        onTap: () {
                          setState(() => n['read'] = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
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
                              // Icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _iconFromName(n['icon'] as String),
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _roleLabel(role),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            n['time'] as String,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['title'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            isRead ? FontWeight.w400 : FontWeight.w600,
                                        color: AppColors.charcoal,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
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
