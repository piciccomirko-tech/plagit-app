import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// Business chat thread — mirrors BusinessRealChatView.swift.
class BusinessChatView extends StatefulWidget {
  final String conversationId;
  const BusinessChatView({super.key, required this.conversationId});

  @override
  State<BusinessChatView> createState() => _BusinessChatViewState();
}

class _BusinessChatViewState extends State<BusinessChatView> {
  final _service = BusinessService();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _conversationInfo;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getMessages(widget.conversationId);
      final msgs = (data['messages'] ?? data['data'] ?? []) as List;
      if (mounted) setState(() {
        _messages = msgs.cast<Map<String, dynamic>>();
        _conversationInfo = data['conversation'] as Map<String, dynamic>?;
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _inputCtrl.clear();
    try {
      await _service.sendMessage(widget.conversationId, text);
      await _loadMessages();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidateName = _conversationInfo?['candidateName'] ?? _conversationInfo?['candidate_name'] ?? 'Chat';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => context.pop()),
                  Expanded(child: Text(candidateName.toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal), overflow: TextOverflow.ellipsis)),
                  GestureDetector(
                    onTap: () {
                      final candidateId = _conversationInfo?['candidateId'] ?? _conversationInfo?['candidate_id'];
                      if (candidateId != null) context.push('/business/candidate/$candidateId');
                    },
                    child: const Icon(Icons.person_outline, size: 22, color: AppColors.indigo),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // ── Messages ──
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.indigo))
                  : _messages.isEmpty
                      ? const Center(child: Text('No messages yet', style: TextStyle(color: AppColors.secondary)))
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final m = _messages[i];
                            final isMe = (m['senderType'] ?? m['sender_type']) == 'business';
                            return _MessageBubble(
                              body: m['body']?.toString() ?? m['content']?.toString() ?? '',
                              senderName: isMe ? null : (m['senderName'] ?? m['sender_name'])?.toString(),
                              isMe: isMe,
                            );
                          },
                        ),
            ),

            // ── Input ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(top: BorderSide(color: AppColors.divider)),
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
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.full), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 42, height: 42,
                      decoration: const BoxDecoration(color: AppColors.indigo, shape: BoxShape.circle),
                      child: const Icon(Icons.send, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String body;
  final String? senderName;
  final bool isMe;
  const _MessageBubble({required this.body, this.senderName, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? AppColors.indigo : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (senderName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(senderName!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isMe ? Colors.white70 : AppColors.indigo)),
              ),
            Text(body, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : AppColors.charcoal)),
          ],
        ),
      ),
    );
  }
}
