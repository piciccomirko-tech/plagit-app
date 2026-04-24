import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/app_back_title_bar.dart';
import 'package:plagit/core/widgets/app_selection_bar.dart';
import 'package:plagit/core/widgets/header_action_icon.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/models/business_conversation.dart';
import 'package:plagit/providers/recent_searches_provider.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

const _tealMain = Color(0xFF00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _indigo = Color(0xFF5856D6);
const _urgent = Color(0xFFFF3B30);

class BusinessMessagesView extends StatefulWidget {
  const BusinessMessagesView({super.key});
  @override
  State<BusinessMessagesView> createState() => _BusinessMessagesViewState();
}

class _BusinessMessagesViewState extends State<BusinessMessagesView> {
  String _filter = 'All';

  // ── Selection mode (same pattern as candidate messages tab) ──
  bool _selecting = false;
  final Set<String> _selected = {};

  static const _filters = ['All', 'Unread', 'Interviews', 'Jobs'];

  void _enterSelection(String id) {
    setState(() {
      _selecting = true;
      _selected.add(id);
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selecting = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  String _filterLabel(AppLocalizations l, String filter) {
    switch (filter) {
      case 'Unread':
        return l.filterUnread;
      case 'Interviews':
        return l.interviews;
      case 'Jobs':
        return l.jobs;
      default:
        return l.filterAll;
    }
  }

  String _searchMessagesTitle(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'it':
        return 'Cerca messaggi';
      case 'ar':
        return 'ابحث في الرسائل';
      default:
        return 'Search Messages';
    }
  }

  String _clearSelectionLabel(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'it':
        return 'Deseleziona';
      case 'ar':
        return 'إلغاء التحديد';
      default:
        return 'Clear';
    }
  }

  String _noConversationsTitle(BuildContext context, String filter) {
    final code = Localizations.localeOf(context).languageCode;
    switch (filter) {
      case 'Unread':
        switch (code) {
          case 'it':
            return 'Nessuna conversazione non letta';
          case 'ar':
            return 'لا توجد محادثات غير مقروءة';
          default:
            return 'No unread conversations';
        }
      case 'Interviews':
        switch (code) {
          case 'it':
            return 'Nessuna conversazione di colloquio';
          case 'ar':
            return 'لا توجد محادثات مقابلة';
          default:
            return 'No interview conversations';
        }
      case 'Jobs':
        switch (code) {
          case 'it':
            return 'Nessuna conversazione di lavoro';
          case 'ar':
            return 'لا توجد محادثات وظائف';
          default:
            return 'No job conversations';
        }
      default:
        return AppLocalizations.of(context)!.noMessagesYet;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<BusinessMessagesProvider>().load(),
    );
  }

  void _openSearchScreen(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          scope: RecentSearchScope.businessMessages,
          title: _searchMessagesTitle(context),
          hintText: l.searchConversationsHint,
          resultsBuilder: (ctx, query) {
            final convos = ctx.watch<BusinessMessagesProvider>().conversations;
            final q = query.toLowerCase();
            final results = convos
                .where(
                  (c) =>
                      c.candidateName.toLowerCase().contains(q) ||
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
                  onTap: () => ctx.push('/business/chat/${c.id}'),
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
                    ),
                    child: Row(
                      children: [
                        ProfilePhoto(
                          initials: c.candidateInitials,
                          size: 44,
                          square: true,
                          hueSeed: c.candidateName,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.candidateName,
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
                                  l.rePrefix(c.jobContext),
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
                                c.lastMessage,
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

  List<BusinessConversation> _applyFilters(List<BusinessConversation> all) {
    var list = all;
    if (_filter == 'Unread') {
      list = list.where((c) => c.unread > 0).toList();
    } else if (_filter == 'Interviews') {
      list = list
          .where((c) => c.jobContext.toLowerCase().contains('interview'))
          .toList();
    } else if (_filter == 'Jobs') {
      list = list
          .where(
            (c) =>
                c.jobContext.toLowerCase().contains('position') ||
                c.jobContext.toLowerCase().contains('job'),
          )
          .toList();
    }
    // Sort: unread first, then interview-related, then by time
    list.sort((a, b) {
      if (a.unread > 0 && b.unread == 0) return -1;
      if (a.unread == 0 && b.unread > 0) return 1;
      final aInterview = a.jobContext.toLowerCase().contains('interview');
      final bInterview = b.jobContext.toLowerCase().contains('interview');
      if (aInterview && !bInterview) return -1;
      if (!aInterview && bInterview) return 1;
      return 0;
    });
    return list;
  }

  bool _isInterviewRelated(BusinessConversation c) =>
      c.jobContext.toLowerCase().contains('interview');
  bool _needsReply(BusinessConversation c) =>
      c.unread > 0 && c.lastMessage.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<BusinessMessagesProvider>();
    final allConvos = provider.conversations;
    final convos = _applyFilters(allConvos);
    final totalUnread = provider.totalUnread;
    final unreadCount = allConvos.where((c) => c.unread > 0).length;

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR — selection-aware
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: _selecting
                  ? _buildSelectionBar(allConvos)
                  : _buildDefaultBar(totalUnread, allConvos),
            ),

            // (Search now lives on a dedicated full-screen route.)

            // FILTER CHIPS
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final active = _filter == f;
                  final count = f == 'Unread' ? unreadCount : 0;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: active ? _tealMain : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: active
                            ? null
                            : Border.all(
                                color: const Color(0xFFD1D1D6),
                                width: 0.5,
                              ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _filterLabel(l, f),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: active ? Colors.white : _secondary,
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : _tealMain.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: active ? Colors.white : _tealMain,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // CONTENT
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
                      const Icon(
                        CupertinoIcons.wifi_slash,
                        size: 40,
                        color: _tertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        style: const TextStyle(fontSize: 14, color: _secondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () =>
                            context.read<BusinessMessagesProvider>().load(),
                        child: Text(
                          l.retryAction,
                          style: TextStyle(
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
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _tealMain.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.bubble_left_bubble_right,
                            size: 24,
                            color: _tealMain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'All'
                              ? l.noMessagesYet
                              : _noConversationsTitle(context, _filter),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _filter == 'All'
                              ? l.whenCandidatesMessage
                              : l.trySwitchingFilter,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
                  itemCount: convos.length,
                  itemBuilder: (context, i) {
                    final c = convos[i];
                    return Dismissible(
                      key: ValueKey('bconvo_${c.id}'),
                      direction: _selecting
                          ? DismissDirection.none
                          : DismissDirection.endToStart,
                      background: _buildSwipeBackground(context),
                      confirmDismiss: (_) => _confirmSingleDelete(c),
                      onDismissed: (_) {
                        context
                            .read<BusinessMessagesProvider>()
                            .deleteConversation(c.id);
                      },
                      child: _conversationRow(c, i < convos.length - 1),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _conversationRow(BusinessConversation c, bool showDivider) {
    final l = AppLocalizations.of(context)!;
    final isUnread = c.unread > 0;
    final isInterview = _isInterviewRelated(c);
    final words = c.candidateName.split(' ');
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : c.candidateInitials;
    final isSelected = _selected.contains(c.id);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (_selecting) {
              _toggleSelected(c.id);
            } else {
              context.push('/business/chat/${c.id}');
            }
          },
          onLongPress: () => _enterSelection(c.id),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? _tealMain.withValues(alpha: 0.08)
                  : (isUnread ? _tealMain.withValues(alpha: 0.03) : _cardBg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: _selecting ? 32 : 0,
                  child: _selecting
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10, top: 18),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _tealMain
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: isSelected ? _tealMain : _tertiary,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
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
                // ── Larger candidate ID-style headshot (was 48 circle) ──
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ProfilePhoto(
                        photoUrl:
                            null, // candidate photoUrl not yet on conversation model
                        initials: initials,
                        size: 56,
                        square: true,
                        hueSeed: c.candidateName,
                      ),
                      if (isUnread)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _tealMain,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${c.unread}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + time row
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              c.candidateName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: const Color(0xFF1C1C1E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 13,
                            color: _tealMain,
                          ),
                          const Spacer(),
                          Text(
                            c.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: isUnread ? _tealMain : _tertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Context badges
                      Row(
                        children: [
                          if (c.jobContext.isNotEmpty)
                            Flexible(
                              child: Text(
                                l.rePrefix(c.jobContext),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _tealMain,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (isInterview) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: _indigo.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l.interviewLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: _indigo,
                                ),
                              ),
                            ),
                          ],
                          if (_needsReply(c) && !isInterview) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF9500,
                                ).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l.reply,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF9500),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Message preview
                      Text(
                        c.lastMessage,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isUnread
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: isUnread
                              ? const Color(0xFF3A3A3C)
                              : _secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ForwardChevron(size: 12, color: isUnread
                        ? _tealMain.withValues(alpha: 0.5)
                        : const Color(0xFFC7C7CC),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 76, right: 16),
            child: Container(height: 0.5, color: const Color(0xFFF2F2F7)),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP BAR BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDefaultBar(
    int totalUnread,
    List<BusinessConversation> allConvos,
  ) {
    final l = AppLocalizations.of(context)!;
    return AppBackTitleBar(
      title: l.messagesTitle,
      onBack: () => context.canPop() ? context.pop() : null,
      padding: EdgeInsets.zero,
      backBackgroundColor: _surface,
      centerTitle: false,
      titleSpacing: 12,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.messagesTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
          if (totalUnread > 0)
            Text(
              l.unreadCount(totalUnread),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _tealMain,
              ),
            ),
        ],
      ),
      trailingMinWidth: 58,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderActionIcon(
            onTap: () => _openSearchScreen(context),
            icon: const Icon(
              CupertinoIcons.search,
              size: 20,
              color: Color(0xFF3C3C43),
            ),
          ),
          const SizedBox(width: 16),
          HeaderActionIcon(
            onTap: allConvos.isEmpty
                ? null
                : () => _showOverflowMenu(allConvos),
            icon: Icon(
              CupertinoIcons.ellipsis,
              size: 22,
              color: allConvos.isEmpty ? _tertiary : _charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(List<BusinessConversation> allConvos) {
    final l = AppLocalizations.of(context)!;
    final count = _selected.length;
    return AppSelectionBar(
      selectedCount: count,
      onCancel: _exitSelection,
      padding: EdgeInsets.zero,
      title: count == 0 ? l.selectItems : l.countSelected(count),
      titleStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _charcoal,
        letterSpacing: -0.2,
      ),
      leading: GestureDetector(
        onTap: _exitSelection,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(CupertinoIcons.xmark, size: 16, color: _charcoal),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              if (_selected.length == allConvos.length) {
                _selected.clear();
              } else {
                _selected
                  ..clear()
                  ..addAll(allConvos.map((c) => c.id));
              }
            }),
            child: Text(
              _selected.length == allConvos.length
                  ? _clearSelectionLabel(context)
                  : l.selectAll,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _tealMain,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: count == 0 ? null : () => _confirmBulkDelete(),
            child: Icon(
              CupertinoIcons.trash_fill,
              size: 20,
              color: count == 0 ? _tertiary : _urgent,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DELETE FLOWS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSwipeBackground(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      color: _urgent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.trash_fill, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.delete,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmSingleDelete(BusinessConversation c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            l.deleteConversation,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _charcoal,
            ),
          ),
          content: Text(
            l.removeChatBody(c.candidateName),
            style: const TextStyle(fontSize: 14, color: _secondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelAction, style: const TextStyle(color: _secondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.delete,
                style: const TextStyle(color: _urgent, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  Future<void> _confirmBulkDelete() async {
    final count = _selected.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            l.deleteConversationsCount(count),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _charcoal,
            ),
          ),
          content: Text(
            l.deleteSelectedNote,
            style: const TextStyle(fontSize: 14, color: _secondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelAction, style: const TextStyle(color: _secondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.delete,
                style: const TextStyle(color: _urgent, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    context.read<BusinessMessagesProvider>().deleteConversations(_selected);
    _exitSelection();
  }

  Future<void> _confirmDeleteAll(List<BusinessConversation> allConvos) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            l.deleteAllConversations,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _charcoal,
            ),
          ),
          content: Text(
            l.clearInboxBody(allConvos.length),
            style: const TextStyle(fontSize: 14, color: _secondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancelAction, style: const TextStyle(color: _secondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.deleteAll,
                style: const TextStyle(color: _urgent, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    context.read<BusinessMessagesProvider>().deleteAllConversations();
  }

  void _showOverflowMenu(List<BusinessConversation> allConvos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return Container(
          decoration: const BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                _BusinessMenuItem(
                  icon: CupertinoIcons.checkmark_circle,
                  label: l.selectConversations,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selecting = true);
                  },
                ),
                _BusinessMenuItem(
                  icon: CupertinoIcons.trash_fill,
                  label: l.deleteAll,
                  color: _urgent,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDeleteAll(allConvos);
                  },
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l.cancelAction,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _charcoal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// OVERFLOW MENU ITEM
// ═══════════════════════════════════════════════════════════════

class _BusinessMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BusinessMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = _charcoal,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
