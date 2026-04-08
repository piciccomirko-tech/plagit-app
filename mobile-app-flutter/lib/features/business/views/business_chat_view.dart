import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/models/business_conversation.dart';
import 'package:plagit/models/conversation.dart'; // ChatMessage
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/repositories/business_repository.dart';

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
  List<ChatMessage> _messages = [];
  BusinessConversation? _conversation;
  bool _canSend = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(() {
      final canSend = _inputCtrl.text.trim().isNotEmpty;
      if (canSend != _canSend) setState(() => _canSend = canSend);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    // Look up conversation from provider
    final msgProvider = context.read<BusinessMessagesProvider>();
    _conversation = msgProvider.conversations
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = BusinessRepository();
      final msgs = await repo.fetchMessages(widget.conversationId);
      if (!mounted) return;
      setState(() {
        _messages = msgs.reversed.toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(0, ChatMessage(
        sender: 'business',
        text: text,
        time: 'Just now',
      ));
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
    final candidateName = _conversation?.candidateName ?? 'Chat';
    final jobContext = _conversation?.jobContext ?? '';

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
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.secondary)),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _loadMessages,
                              child: const Text('Retry', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isBusiness = msg.isFromBusiness;

                          // Show timestamp between groups
                          final showTime = index == _messages.length - 1 ||
                              _messages[index + 1].time != msg.time;

                          return Column(
                            children: [
                              if (showTime)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                                  child: Center(
                                    child: Text(
                                      msg.time,
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
                                    msg.text,
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
