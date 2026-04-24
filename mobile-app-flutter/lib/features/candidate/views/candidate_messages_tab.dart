import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/demo_content_helpers.dart';
import 'package:plagit/core/widgets/app_back_title_bar.dart';
import 'package:plagit/core/widgets/header_action_icon.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/conversation.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/providers/recent_searches_provider.dart';


// ═══════════════════════════════════════════════════════════════
// Theme (exact from Swift Theme.swift)
// ═══════════════════════════════════════════════════════════════
const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _divider = Color(0xFFEBEDF0);

BoxShadow get _cardShadow => BoxShadow(
  color: Colors.black.withValues(alpha: 0.05),
  blurRadius: 14,
  offset: const Offset(0, 5),
);

class CandidateMessagesTab extends StatefulWidget {
  const CandidateMessagesTab({super.key});

  @override
  State<CandidateMessagesTab> createState() => _CandidateMessagesTabState();
}

class _CandidateMessagesTabState extends State<CandidateMessagesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateMessagesProvider>().load();
    });
  }

  void _openSearchScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          scope: RecentSearchScope.candidateMessages,
          title: AppLocalizations.of(context).search,
          hintText: AppLocalizations.of(context).messagesSearch,
          resultsBuilder: (ctx, query) {
            final convos = ctx.watch<CandidateMessagesProvider>().conversations;
            final q = query.toLowerCase();
            final results = convos
                .where(
                  (c) =>
                      c.company.toLowerCase().contains(q) ||
                      c.jobContext.toLowerCase().contains(q) ||
                      c.lastMessage.toLowerCase().contains(q),
                )
                .toList();
            if (results.isEmpty) return SearchNoResults(query: query);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = results[i];
                return GestureDetector(
                  onTap: () => ctx.push('/candidate/chat/${c.id}'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEFEFF4),
                        width: 0.5,
                      ),
                      boxShadow: [_cardShadow],
                    ),
                    child: Row(
                      children: [
                        ProfilePhoto(
                          initials: c.company.length >= 2
                              ? c.company.substring(0, 2).toUpperCase()
                              : c.company.toUpperCase(),
                          size: 44,
                          square: true,
                          hueSeed: c.company,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.company,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: _charcoal,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (c.jobContext.isNotEmpty)
                                Text(
                                  AppLocalizations.of(context).rePrefix(c.jobContext),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _tealMain,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 2),
                              Text(
                                localizeDemoLastMessage(context, c.lastMessage),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateMessagesProvider>();
    final convos = provider.conversations;
    final totalUnread = provider.totalUnread;

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ══════════════════════════════════════
            // 1. TOP BAR — selection-aware
            // ══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _buildDefaultBar(),
            ),

            // (Search now lives on a dedicated full-screen route — opened
            //  from the search icon in the top bar above.)

            // ══════════════════════════════════════
            // 3. SUMMARY ROW
            // ══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).conversationCount(convos.length),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _charcoal,
                    ),
                  ),
                  if (totalUnread > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: _tealMain,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context).unreadCount(totalUnread),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _tealMain,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ══════════════════════════════════════
            // 4/5. STATES + LIST
            // ══════════════════════════════════════
            if (provider.loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: _tealMain),
                ),
              )
            else if (provider.error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 40, color: _tertiary),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        style: const TextStyle(fontSize: 14, color: _secondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () =>
                            context.read<CandidateMessagesProvider>().load(),
                        child: Text(
                          AppLocalizations.of(context).retry,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _tealMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (convos.isEmpty)
              Expanded(child: _buildEmpty())
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [_cardShadow],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: convos.length,
                        separatorBuilder: (_, _) => const Padding(
                          padding: EdgeInsets.only(left: 84),
                          child: Divider(height: 1, color: _divider),
                        ),
                        itemBuilder: (context, i) {
                          final c = convos[i];
                          final isUnread = c.unread > 0;
                          return _ConvoRow(
                            conversation: c,
                            isUnread: isUnread,
                            selecting: false,
                            selected: false,
                            onTap: () => context.push('/candidate/chat/${c.id}'),
                            onLongPress: null,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: _tealLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: _tealMain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noMessagesYet,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).whenEmployersMessageYou,
              style: const TextStyle(fontSize: 13, color: _secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP BAR BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDefaultBar() {
    return AppBackTitleBar(
      title: AppLocalizations.of(context).messages,
      onBack: () => context.canPop() ? context.pop() : null,
      padding: EdgeInsets.zero,
      backBackgroundColor: _surface,
      titleStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _charcoal,
        letterSpacing: -0.2,
      ),
      trailingMinWidth: 58,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderActionIcon(
            onTap: () => _openSearchScreen(context),
            icon: const Icon(CupertinoIcons.search, size: 20, color: _charcoal),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CONVERSATION ROW
// ═══════════════════════════════════════════════════════════════

class _ConvoRow extends StatelessWidget {
  final Conversation conversation;
  final bool isUnread;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _ConvoRow({
    required this.conversation,
    required this.isUnread,
    required this.onTap,
    this.selecting = false,
    this.selected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final words = c.company.split(' ');
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : (c.company.length >= 2
              ? c.company.substring(0, 2).toUpperCase()
              : c.company.toUpperCase());

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: selected
            ? _tealMain.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Selection checkbox — slides in when entering selection mode
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: selecting ? 32 : 0,
              child: selecting
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: selected ? _tealMain : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: selected ? _tealMain : _tertiary,
                            width: 1.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    )
                  : null,
            ),
            // ── Larger square ID-style brand photo ──
            ProfilePhoto(
              photoUrl: null, // mock conversations have no photoUrl yet
              initials: initials,
              size: 56,
              square: true,
              verified: true,
              hueSeed: c.company,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.company,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: _charcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 12, color: _tealMain),
                      const Spacer(),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _tealMain,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (c.jobContext.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context).rePrefix(c.jobContext),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _tealMain,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    localizeDemoLastMessage(context, c.lastMessage),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                      color: isUnread ? _charcoal : _secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
