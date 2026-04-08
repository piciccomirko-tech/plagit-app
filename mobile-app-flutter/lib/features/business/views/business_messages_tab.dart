import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// Business conversations list — mirrors BusinessRealMessagesView.swift.
class BusinessMessagesTab extends StatefulWidget {
  const BusinessMessagesTab({super.key});

  @override
  State<BusinessMessagesTab> createState() => _BusinessMessagesTabState();
}

class _BusinessMessagesTabState extends State<BusinessMessagesTab> {
  final _service = BusinessService();
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getConversations();
      final convs = (data['conversations'] ?? data['data'] ?? []) as List;
      if (mounted) setState(() { _conversations = convs.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Messages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.indigo))
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_error!, style: const TextStyle(color: AppColors.urgent)),
                        TextButton(onPressed: _load, child: const Text('Retry')),
                      ]))
                    : _conversations.isEmpty
                        ? const Center(child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.divider),
                              SizedBox(height: 12),
                              Text('No messages yet', style: TextStyle(color: AppColors.secondary)),
                              SizedBox(height: 4),
                              Text('Messages from candidates will appear here', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                            ],
                          ))
                        : RefreshIndicator(
                            color: AppColors.indigo,
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _conversations.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                              itemBuilder: (_, i) {
                                final c = _conversations[i];
                                final unread = (c['unreadCount'] ?? c['unread_count'] ?? 0) as int;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.indigo.withValues(alpha: 0.12),
                                    child: Text(
                                      (c['candidateName'] ?? c['candidate_name'] ?? 'C').toString().substring(0, 1).toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.indigo),
                                    ),
                                  ),
                                  title: Text(
                                    c['candidateName'] ?? c['candidate_name'] ?? 'Candidate',
                                    style: TextStyle(fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal, color: AppColors.charcoal),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (c['jobTitle'] != null || c['job_title'] != null)
                                        Text(c['jobTitle'] ?? c['job_title'], style: const TextStyle(fontSize: 12, color: AppColors.indigo)),
                                      Text(
                                        c['lastMessage'] ?? c['last_message'] ?? '',
                                        style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: unread > 0
                                      ? Container(
                                          width: 22, height: 22,
                                          decoration: const BoxDecoration(color: AppColors.indigo, shape: BoxShape.circle),
                                          child: Center(child: Text('$unread', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
                                        )
                                      : null,
                                  onTap: () => context.push('/business/chat/${c['id']}'),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
