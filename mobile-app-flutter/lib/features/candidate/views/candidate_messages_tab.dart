import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/candidate_service.dart';

class CandidateMessagesTab extends StatefulWidget {
  const CandidateMessagesTab({super.key});

  @override
  State<CandidateMessagesTab> createState() => _CandidateMessagesTabState();
}

class _CandidateMessagesTabState extends State<CandidateMessagesTab> {
  final _service = CandidateService();
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Text('Messages', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, size: 28, color: AppColors.urgent),
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(fontSize: 14, color: AppColors.urgent)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ]))
                  : _conversations.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.teal,
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _conversations.length,
                            itemBuilder: (_, i) {
                              final c = _conversations[i];
                              final unread = (c['unreadCount'] ?? c['unread_count'] ?? 0) as int;
                              final companyName = (c['businessName'] ?? c['business_name'] ?? 'Company').toString();
                              final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C';

                              return Column(children: [
                                GestureDetector(
                                  onTap: () => context.push('/candidate/chat/${c['id']}'),
                                  child: Container(
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Row(children: [
                                      // Avatar — same style as entry icon badges
                                      Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.teal.withValues(alpha: 0.10),
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                        ),
                                        child: Center(child: Text(initial, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.teal))),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(
                                          companyName,
                                          style: TextStyle(fontSize: 16, fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal, color: AppColors.charcoal),
                                        ),
                                        if (c['jobTitle'] != null || c['job_title'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(c['jobTitle'] ?? c['job_title'], style: const TextStyle(fontSize: 12, color: AppColors.teal)),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Text(
                                            c['lastMessage'] ?? c['last_message'] ?? '',
                                            style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ])),
                                      if (unread > 0)
                                        Container(
                                          width: 22, height: 22,
                                          decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                                          child: Center(child: Text('$unread', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))),
                                        )
                                      else
                                        const Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
                                    ]),
                                  ),
                                ),
                                if (i < _conversations.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 64),
                                    child: Divider(height: 1, color: AppColors.divider),
                                  ),
                              ]);
                            },
                          ),
                        ),
        ),
      ]),
    );
  }

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: AppColors.indigo.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
          child: const Icon(Icons.chat_outlined, size: 24, color: AppColors.indigo),
        ),
        const SizedBox(height: 16),
        const Text('No messages yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 6),
        const Text(
          'When you apply to jobs, your conversations with employers will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4),
        ),
      ]),
    ),
  ));
}
