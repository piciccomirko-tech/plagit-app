import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/models/conversation.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/repositories/candidate_repository.dart';

class CandidateChatView extends StatefulWidget {
  final String conversationId;
  const CandidateChatView({super.key, required this.conversationId});

  @override
  State<CandidateChatView> createState() => _CandidateChatViewState();
}

class _CandidateChatViewState extends State<CandidateChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _repo = CandidateRepository();
  List<ChatMessage> _messages = [];
  Conversation? _conversation;
  bool _loadingMessages = true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CandidateMessagesProvider>();
    _conversation = provider.conversations.cast<Conversation?>().firstWhere(
      (c) => c?.id == widget.conversationId,
      orElse: () => null,
    );
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _repo.fetchMessages(widget.conversationId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loadingMessages = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Fallback: generate some default messages for non-Ritz conversations
      setState(() {
        if (widget.conversationId == '2') {
          _messages = [
            const ChatMessage(
              sender: 'business',
              text: 'Thank you for your application to the Bartender position.',
              time: '9:00 AM',
            ),
            const ChatMessage(
              sender: 'business',
              text: 'Your application is currently under review by our team.',
              time: '9:01 AM',
            ),
            const ChatMessage(
              sender: 'candidate',
              text: 'Thank you for letting me know. Looking forward to hearing back.',
              time: '9:30 AM',
            ),
          ];
        } else {
          _messages = [
            const ChatMessage(
              sender: 'business',
              text: 'Congratulations! You have been shortlisted for the Chef de Partie position.',
              time: '2:00 PM',
            ),
            const ChatMessage(
              sender: 'candidate',
              text: 'That is wonderful news! What are the next steps?',
              time: '2:15 PM',
            ),
            const ChatMessage(
              sender: 'business',
              text: 'We will be in touch shortly to arrange an interview. Please keep an eye on your notifications.',
              time: '2:20 PM',
            ),
          ];
        }
        _loadingMessages = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        sender: 'candidate',
        text: text,
        time: 'Just now',
      ));
    });
    _textController.clear();

    // Would call repo.sendMessage() in production
    // _repo.sendMessage(widget.conversationId, text);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final company = _conversation?.company ?? 'Chat';
    final jobContext = _conversation?.jobContext ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              company,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            if (jobContext.isNotEmpty)
              Text(
                jobContext,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list (reversed so newest at bottom)
          Expanded(
            child: _loadingMessages
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      // Reversed index
                      final msgIndex =
                          _messages.length - 1 - index;
                      final msg = _messages[msgIndex];
                      final isCandidate = !msg.isFromBusiness;

                      // Show timestamp if first message or different sender/time
                      bool showTime = false;
                      if (msgIndex == 0) {
                        showTime = true;
                      } else {
                        final prev = _messages[msgIndex - 1];
                        if (prev.time != msg.time ||
                            prev.sender != msg.sender) {
                          showTime = true;
                        }
                      }

                      return Column(
                        crossAxisAlignment: isCandidate
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (showTime)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8, top: 8),
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
                          _ChatBubble(
                            text: msg.text,
                            isCandidate: isCandidate,
                          ),
                          const SizedBox(height: 6),
                        ],
                      );
                    },
                  ),
          ),

          // Input bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: AppColors.tertiary,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textController,
                    builder: (context, value, _) {
                      final hasText = value.text.trim().isNotEmpty;
                      return GestureDetector(
                        onTap: hasText ? _sendMessage : null,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: hasText
                                ? AppColors.teal
                                : AppColors.border,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_upward,
                            color: hasText
                                ? Colors.white
                                : AppColors.tertiary,
                            size: 20,
                          ),
                        ),
                      );
                    },
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

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isCandidate;

  const _ChatBubble({
    required this.text,
    required this.isCandidate,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isCandidate ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCandidate
              ? AppColors.teal
              : const Color(0xFFF0F0F2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                Radius.circular(isCandidate ? 16 : 4),
            bottomRight:
                Radius.circular(isCandidate ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: isCandidate
                ? Colors.white
                : AppColors.charcoal,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
