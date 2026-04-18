import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/demo_content_helpers.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/conversation.dart';
import 'package:plagit/repositories/candidate_repository.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealDark = Color(0xFF009490);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _green = Color(0xFF34C759);

/// Premium 1-to-1 chat between a candidate and a business.
///
/// Refined to feel like a polished hiring conversation tool:
///   • Header carries the business identity (square ID-card photo, name,
///     role/job context, verified seal, "Online now" indicator).
///   • Incoming messages get an inline 32 px square photo so the candidate
///     always sees who they are talking to.
///   • Bubbles use a softer shadow and time-stamp under the message.
///   • Composer has a tinted attachment button + a circular gradient send
///     button — same visual language as the rest of the app.
class CandidateChatView extends StatefulWidget {
  final String conversationId;
  const CandidateChatView({super.key, required this.conversationId});

  @override
  State<CandidateChatView> createState() => _CandidateChatViewState();
}

class _CandidateChatViewState extends State<CandidateChatView> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = true;

  // Mock business identity for the header — in a real build this comes
  // from the conversation lookup. Stable for the candidate's only active
  // mock thread (Ritz London).
  static const _businessName = 'The Ritz London';
  static const _businessInitials = 'TR';
  static const _businessRole = 'Luxury Hotel · Hiring Waiter';
  static const _businessPhotoUrl =
      'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=400&h=400&fit=crop&q=80';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final repo = CandidateRepository();
      _messages = await repo.fetchMessages(widget.conversationId);
    } catch (_) {
      // Fallback to mock if API fails
      _messages = ChatMessage.mockRitzMessages();
    }
    if (mounted) setState(() => _loading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// First-message rule: candidate can only type after business has sent
  /// at least one message. For QuickPlug matches, the business initiates.
  /// For regular conversations (non-match), messages always exist.
  bool get _businessHasSentMessage =>
      _messages.any((m) => m.sender != 'candidate');

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _messages.add(ChatMessage.fromJson({
          'sender': 'candidate',
          'text': text,
          'time': DateTime.now().toIso8601String(),
        })));
    _inputCtrl.clear();
    _scrollToBottom();
    // Fire-and-forget to backend
    CandidateRepository().sendMessage(widget.conversationId, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: _tealMain)))
            else
              Expanded(child: _buildMessagesList()),
            _businessHasSentMessage ? _buildComposer() : _buildWaitingBanner(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HEADER — business identity card
  // ─────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        border: Border(bottom: BorderSide(color: Color(0xFFEBEDF0), width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(CupertinoIcons.chevron_left, size: 28, color: _charcoal),
            ),
          ),
          const SizedBox(width: 12),
          // Larger square ID-card photo for the business
          const ProfilePhoto(
            photoUrl: _businessPhotoUrl,
            initials: _businessInitials,
            size: 44,
            square: true,
            verified: true,
            hueSeed: _businessName,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  _businessName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _charcoal,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppLocalizations.of(context).onlineNow,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _green,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const Text('  ·  ', style: TextStyle(fontSize: 11, color: Color(0xFFC7C7CC))),
                    const Flexible(
                      child: Text(
                        _businessRole,
                        style: TextStyle(fontSize: 11, color: _tertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(CupertinoIcons.phone_fill, size: 15, color: _tealMain),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(CupertinoIcons.video_camera_solid, size: 16, color: _tealMain),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // MESSAGES LIST
  // ─────────────────────────────────────────

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final isMine = !m.isFromBusiness;
        // Show the avatar only on the first message of a sequence to keep
        // the rhythm clean — same trick as iMessage / WhatsApp.
        final isFirstOfGroup = i == 0 || _messages[i - 1].isFromBusiness != m.isFromBusiness;
        final isLastOfGroup = i == _messages.length - 1 ||
            _messages[i + 1].isFromBusiness != m.isFromBusiness;
        return _MessageBubble(
          message: m,
          isMine: isMine,
          showAvatar: !isMine && isLastOfGroup,
          showName: !isMine && isFirstOfGroup,
          businessName: _businessName,
          businessInitials: _businessInitials,
          businessPhotoUrl: _businessPhotoUrl,
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // COMPOSER
  // ─────────────────────────────────────────

  Widget _buildWaitingBanner() {
    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: Color(0xFFEBEDF0), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2BB8B0).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, size: 16, color: Color(0xFF2BB8B0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).waitingForBusinessFirstMessage,
                  style: const TextStyle(fontSize: 13, color: _secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    final canSend = _inputCtrl.text.trim().isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        border: Border(top: BorderSide(color: Color(0xFFEBEDF0), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment chip
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(CupertinoIcons.paperclip, size: 17, color: _tealMain),
                ),
              ),
              const SizedBox(width: 8),
              // Text field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 110),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _inputCtrl,
                    onChanged: (_) => setState(() {}),
                    minLines: 1,
                    maxLines: 5,
                    style: const TextStyle(fontSize: 14.5, color: _charcoal, height: 1.35),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).typeMessage,
                      hintStyle: const TextStyle(fontSize: 14.5, color: _tertiary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button — circular gradient when active
              GestureDetector(
                onTap: canSend ? _send : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: canSend
                        ? const LinearGradient(
                            colors: [_tealMain, _tealDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: canSend ? null : _surface,
                    boxShadow: canSend
                        ? [
                            BoxShadow(
                              color: _tealMain.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_up,
                    size: 18,
                    color: canSend ? Colors.white : _tertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MESSAGE BUBBLE — premium polish
// ═══════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showAvatar;
  final bool showName;
  final String businessName;
  final String businessInitials;
  final String businessPhotoUrl;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showAvatar,
    required this.showName,
    required this.businessName,
    required this.businessInitials,
    required this.businessPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Column(
      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showName)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _secondary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.checkmark_seal_fill, size: 11, color: _tealMain),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    AppLocalizations.of(context).businessUpper,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: _tealMain,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          decoration: BoxDecoration(
            color: isMine ? _tealMain : _cardBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
            boxShadow: isMine
                ? [
                    BoxShadow(
                      color: _tealMain.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            localizeDemoChat(context, message.text),
            style: TextStyle(
              fontSize: 14.5,
              color: isMine ? Colors.white : _charcoal,
              height: 1.35,
              letterSpacing: -0.1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.time),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: _tertiary,
                  letterSpacing: -0.1,
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 4),
                const Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 11, color: _tealMain),
              ],
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            SizedBox(
              width: 32,
              child: showAvatar
                  ? ProfilePhoto(
                      photoUrl: businessPhotoUrl,
                      initials: businessInitials,
                      size: 32,
                      square: true,
                      hueSeed: businessName,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$h12:$minute $ampm';
    } catch (_) {
      return '';
    }
  }
}
