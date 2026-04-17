import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Chat thread for a service company conversation.
class ServiceMessageThreadView extends StatefulWidget {
  final String conversationId;
  const ServiceMessageThreadView({super.key, required this.conversationId});

  @override
  State<ServiceMessageThreadView> createState() =>
      _ServiceMessageThreadViewState();
}

class _ServiceMessageThreadViewState extends State<ServiceMessageThreadView> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, dynamic>> _messages;
  Map<String, dynamic>? _conversation;

  @override
  void initState() {
    super.initState();
    final convos = MockData.serviceConversations.cast<Map<String, dynamic>>();
    for (final c in convos) {
      if (c['id'] == widget.conversationId) {
        _conversation = c;
        break;
      }
    }
    _messages = MockData.serviceChatMessages
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': 'Just now',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final conv = _conversation;
    final companyName = conv?['company'] as String? ?? 'Company';
    final companyId = conv?['companyId'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(companyName),
            // View Company Profile link
            if (companyId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/services/companies/$companyId'),
                    child: const Text('View Company Profile',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.teal,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.teal)),
                  ),
                ),
              ),
            Expanded(child: _messageList()),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _topBar(String companyName) {
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
                child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(companyName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal),
                    overflow: TextOverflow.ellipsis),
                const Text('Inquiry',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.secondary)),
              ],
            ),
          ),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _messageList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final isUser = msg['sender'] == 'user';
        return _messageBubble(msg, isUser);
      },
    );
  }

  Widget _messageBubble(Map<String, dynamic> msg, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.teal
                  : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.lg),
                topRight: const Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(isUser ? AppRadius.lg : 4),
                bottomRight: Radius.circular(isUser ? 4 : AppRadius.lg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg['text'] as String,
                    style: TextStyle(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppColors.charcoal,
                        height: 1.4)),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(msg['time'] as String,
                      style: TextStyle(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.tertiary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.charcoal),
                decoration: const InputDecoration.collapsed(
                    hintText: 'Type a message...',
                    hintStyle:
                        TextStyle(color: AppColors.tertiary, fontSize: 15)),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppColors.teal, shape: BoxShape.circle),
              child: const Icon(Icons.send, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
