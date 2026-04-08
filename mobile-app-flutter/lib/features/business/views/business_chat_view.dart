import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

/// Business chat thread view.
class BusinessChatView extends StatefulWidget {
  final String conversationId;
  const BusinessChatView({super.key, required this.conversationId});

  @override
  State<BusinessChatView> createState() => _BusinessChatViewState();
}

class _BusinessChatViewState extends State<BusinessChatView> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late List<Map<String, dynamic>> _messages;
  Map<String, dynamic>? _conversation;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _conversation = MockData.businessConversations
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (c) => c['id'] == widget.conversationId,
          orElse: () => <String, dynamic>{},
        );
    _messages = MockData.businessChatMessages
        .map((m) => Map<String, dynamic>.from(m))
        .toList()
        .reversed
        .toList();
    _inputCtrl.addListener(() {
      final canSend = _inputCtrl.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
    });
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(0, {
        'sender': 'business',
        'text': text,
        'time': 'Just now',
      });
    });
    _inputCtrl.clear();
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidateName =
        _conversation?['candidateName'] as String? ?? 'Chat';
    final jobContext =
        _conversation?['jobContext'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              candidateName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            if (jobContext.isNotEmpty)
              Text(
                jobContext,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Quick action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => context.push('/business/applicant/ba1'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Profile', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => context.push('/business/schedule-interview'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    side: const BorderSide(color: AppColors.purple),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Invite to Interview', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isBusiness = msg['sender'] == 'business';
                final text = msg['text'] as String? ?? '';
                final time = msg['time'] as String? ?? '';

                // Show timestamp between groups
                final showTime = index == _messages.length - 1 ||
                    _messages[index + 1]['time'] != time;

                return Column(
                  children: [
                    if (showTime)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Center(
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: isBusiness
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isBusiness
                              ? AppColors.teal
                              : const Color(0xFFF0F0F2),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isBusiness ? 16 : 4),
                            bottomRight: Radius.circular(isBusiness ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            color: isBusiness
                                ? Colors.white
                                : AppColors.charcoal,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom input bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.tertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _canSend ? _send : null,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _canSend
                            ? AppColors.teal
                            : AppColors.teal.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
