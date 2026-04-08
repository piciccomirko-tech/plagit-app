import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class UnifiedMessagesView extends StatelessWidget {
  const UnifiedMessagesView({super.key});

  int _totalUnread() {
    int count = 0;
    for (final c in MockData.conversations) {
      count += (c['unread'] as int? ?? 0);
    }
    for (final c in MockData.businessConversations) {
      count += (c['unread'] as int? ?? 0);
    }
    for (final c in MockData.serviceConversations) {
      count += (c['unread'] as int? ?? 0);
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final totalUnread = _totalUnread();
    final isEmpty = MockData.conversations.isEmpty &&
        MockData.businessConversations.isEmpty &&
        MockData.serviceConversations.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const Text(
              'Messages',
              style: TextStyle(
                color: AppColors.charcoal,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalUnread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalUnread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 48, color: AppColors.tertiary),
                  const SizedBox(height: 12),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Candidate Messages ──
                  if (MockData.conversations.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'CANDIDATE MESSAGES',
                      borderColor: AppColors.teal,
                    ),
                    const SizedBox(height: 12),
                    _ConversationCard(
                      children: [
                        for (int i = 0;
                            i < MockData.conversations.length;
                            i++) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.divider),
                          _CandidateRow(conv: MockData.conversations[i]),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Business Messages ──
                  if (MockData.businessConversations.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'BUSINESS MESSAGES',
                      borderColor: AppColors.purple,
                    ),
                    const SizedBox(height: 12),
                    _ConversationCard(
                      children: [
                        for (int i = 0;
                            i < MockData.businessConversations.length;
                            i++) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.divider),
                          _BusinessRow(
                              conv: MockData.businessConversations[i]),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Service Inquiries ──
                  if (MockData.serviceConversations.isNotEmpty) ...[
                    _SectionHeader(
                      label: 'SERVICE INQUIRIES',
                      borderColor: AppColors.amber,
                    ),
                    const SizedBox(height: 12),
                    _ConversationCard(
                      children: [
                        for (int i = 0;
                            i < MockData.serviceConversations.length;
                            i++) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.divider),
                          _ServiceRow(
                              conv: MockData.serviceConversations[i]),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ── Section Header ──

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color borderColor;

  const _SectionHeader({required this.label, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: borderColor, width: 2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Conversation Card Wrapper ──

class _ConversationCard extends StatelessWidget {
  final List<Widget> children;
  const _ConversationCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

// ── Candidate Row ──

class _CandidateRow extends StatelessWidget {
  final Map<String, dynamic> conv;
  const _CandidateRow({required this.conv});

  @override
  Widget build(BuildContext context) {
    final company = conv['company'] as String? ?? '';
    final jobContext = conv['jobContext'] as String? ?? '';
    final lastMessage = conv['lastMessage'] as String? ?? '';
    final time = conv['time'] as String? ?? '';
    final unread = conv['unread'] as int? ?? 0;
    final initial = company.isNotEmpty ? company[0] : '?';

    return InkWell(
      onTap: () => context.push('/candidate/chat/${conv['id']}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.teal.withValues(alpha: 0.15),
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    jobContext,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Business Row ──

class _BusinessRow extends StatelessWidget {
  final Map<String, dynamic> conv;
  const _BusinessRow({required this.conv});

  @override
  Widget build(BuildContext context) {
    final candidateName = conv['candidateName'] as String? ?? '';
    final initials = conv['candidateInitials'] as String? ?? '?';
    final jobContext = conv['jobContext'] as String? ?? '';
    final lastMessage = conv['lastMessage'] as String? ?? '';
    final time = conv['time'] as String? ?? '';
    final unread = conv['unread'] as int? ?? 0;

    return InkWell(
      onTap: () => context.push('/business/chat/${conv['id']}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.purple.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidateName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    jobContext,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service Row ──

class _ServiceRow extends StatelessWidget {
  final Map<String, dynamic> conv;
  const _ServiceRow({required this.conv});

  @override
  Widget build(BuildContext context) {
    final company = conv['company'] as String? ?? '';
    final initials = conv['companyInitials'] as String? ?? '?';
    final contextText = conv['context'] as String? ?? '';
    final lastMessage = conv['lastMessage'] as String? ?? '';
    final time = conv['time'] as String? ?? '';
    final unread = conv['unread'] as int? ?? 0;

    return InkWell(
      onTap: () => context.push('/services/messages/${conv['id']}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.amber.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contextText,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
