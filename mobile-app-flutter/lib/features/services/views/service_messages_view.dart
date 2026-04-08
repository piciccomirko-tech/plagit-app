import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';

/// Service messages / conversations list.
class ServiceMessagesView extends StatefulWidget {
  const ServiceMessagesView({super.key});

  @override
  State<ServiceMessagesView> createState() => _ServiceMessagesViewState();
}

class _ServiceMessagesViewState extends State<ServiceMessagesView> {
  String _searchText = '';

  List<Map<String, dynamic>> get _conversations =>
      MockData.serviceConversations.cast<Map<String, dynamic>>();

  int get _totalUnread {
    int count = 0;
    for (final c in _conversations) {
      count += (c['unread'] as int? ?? 0);
    }
    return count;
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchText.isEmpty) return _conversations;
    final q = _searchText.toLowerCase();
    return _conversations
        .where((c) =>
            (c['company'] as String).toLowerCase().contains(q) ||
            (c['lastMessage'] as String).toLowerCase().contains(q) ||
            (c['context'] as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _searchBar(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _filtered.isEmpty ? _emptyState() : _conversationList(),
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
                    size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Messages',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.charcoal)),
              if (_totalUnread > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                      color: AppColors.urgent, shape: BoxShape.circle),
                  child: Text('$_totalUnread',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ],
            ],
          ),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.tertiary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchText = v),
                style: const TextStyle(
                    fontSize: 15, color: AppColors.charcoal),
                decoration: const InputDecoration.collapsed(
                    hintText: 'Search conversations...',
                    hintStyle:
                        TextStyle(color: AppColors.tertiary, fontSize: 15)),
              ),
            ),
            if (_searchText.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _searchText = ''),
                child: const Icon(Icons.cancel,
                    size: 16, color: AppColors.tertiary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _conversationList() {
    final list = _filtered;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: list.length,
      itemBuilder: (_, i) => _conversationTile(list[i]),
    );
  }

  Widget _conversationTile(Map<String, dynamic> conv) {
    final initials = conv['companyInitials'] as String;
    final hue = (initials.hashCode % 360).abs().toDouble();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.15, 0.95).toColor();
    final textColor = HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor();
    final unread = conv['unread'] as int? ?? 0;

    return GestureDetector(
      onTap: () => context.push('/services/messages/${conv['id']}'),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: bgColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initials,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv['company'] as String,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.charcoal),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(conv['time'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.tertiary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(conv['context'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.secondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv['lastMessage'] as String,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.secondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle),
                          child: Text('$unread',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                ],
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.chat_bubble_outline,
                  size: 24, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No conversations yet',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text(
                'Start a conversation by contacting a service company',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}
