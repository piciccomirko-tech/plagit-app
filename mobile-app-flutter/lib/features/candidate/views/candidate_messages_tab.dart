import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class CandidateMessagesTab extends StatefulWidget {
  const CandidateMessagesTab({super.key});

  @override
  State<CandidateMessagesTab> createState() => _CandidateMessagesTabState();
}

class _CandidateMessagesTabState extends State<CandidateMessagesTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> get _allConversations =>
      MockData.conversations.cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchQuery.isEmpty) return _allConversations;
    final q = _searchQuery.toLowerCase();
    return _allConversations
        .where((c) =>
            (c['company'] as String).toLowerCase().contains(q))
        .toList();
  }

  int get _totalUnread => _allConversations.fold<int>(
      0, (sum, c) => sum + (c['unread'] as int));

  Color _avatarColor(String name) {
    final hue = MockData.companyHue(name).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.50).toColor();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _filteredConversations;
    final unread = _totalUnread;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Messages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(
                    color: AppColors.tertiary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.tertiary, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Conversations
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, i) {
                      final conv = conversations[i];
                      return _ConversationTile(
                        conv: conv,
                        avatarColor:
                            _avatarColor(conv['company'] as String),
                        onTap: () => context.push(
                          '/candidate/chat/${conv['id']}',
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

class _ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conv;
  final Color avatarColor;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conv,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final company = conv['company'] as String;
    final initial = company.isNotEmpty ? company[0] : '?';
    final unread = conv['unread'] as int;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Middle column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: unread > 0
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conv['jobContext'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conv['lastMessage'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: unread > 0
                              ? AppColors.charcoal
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Right column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      conv['time'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (unread > 0)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 56, top: 14),
              child: Divider(height: 0, thickness: 0.5, color: AppColors.divider),
            ),
          ],
        ),
      ),
    );
  }
}
