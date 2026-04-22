import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/quick_plug_candidate.dart';
import 'package:plagit/providers/business_providers.dart';

extension _QuickPlugL10n on AppLocalizations {
  String get superInterestedNotified {
    switch (localeName) {
      case 'it':
        return 'Candidato avvisato del tuo super interesse';
      case 'ar':
        return 'تم إشعار المرشح باهتمامك الكبير';
      default:
        return 'Candidate notified of your super interest';
    }
  }

  String get retryAction => retry;

  String get filtersComingSoon {
    switch (localeName) {
      case 'it':
        return 'Filtri disponibili presto';
      case 'ar':
        return 'عوامل التصفية قريبًا';
      default:
        return 'Filters coming soon';
    }
  }
}

/// Business Quick Plug — Tinder-style swipe deck for candidate discovery.
/// This is the signature feature of the business side.
class BusinessQuickPlugView extends StatefulWidget {
  const BusinessQuickPlugView({super.key});

  @override
  State<BusinessQuickPlugView> createState() => _BusinessQuickPlugViewState();
}

class _BusinessQuickPlugViewState extends State<BusinessQuickPlugView>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _isAnimatingOut = false;

  late AnimationController _animController;
  late Animation<double> _animX;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessQuickPlugProvider>().load();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // -- Swipe logic --

  void _processSwipe(bool interested) {
    final provider = context.read<BusinessQuickPlugProvider>();
    if (_isAnimatingOut || !provider.hasCards) return;

    _isAnimatingOut = true;
    final targetX = interested ? 500.0 : -500.0;

    _animX = Tween<double>(begin: _dragX, end: targetX).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward(from: 0).then((_) {
      if (!mounted) return;

      provider.swipe(interested);

      setState(() {
        _dragX = 0;
        _isAnimatingOut = false;
      });

      _animController.reset();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(interested ? 'Added to shortlist!' : 'Passed'),
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            backgroundColor:
                interested ? AppColors.teal : AppColors.red,
          ),
        );
      }
    });
  }

  void _handleSuperInterested() {
    final provider = context.read<BusinessQuickPlugProvider>();
    if (_isAnimatingOut || !provider.hasCards) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).superInterestedNotified),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.gold,
      ),
    );

    _isAnimatingOut = true;
    _animX = Tween<double>(begin: _dragX, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward(from: 0).then((_) {
      if (!mounted) return;

      provider.swipe(true);

      setState(() {
        _dragX = 0;
        _isAnimatingOut = false;
      });

      _animController.reset();
    });
  }

  // -- Color from name hash for avatar --
  Color _avatarColor(String name) {
    final hash = name.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessQuickPlugProvider>();

    // Loading state
    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(provider.error!, style: const TextStyle(color: AppColors.secondary)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => context.read<BusinessQuickPlugProvider>().load(),
                        child: Text(AppLocalizations.of(context).retryAction, style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  // -- Custom App Bar --
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 28, color: AppColors.purple),
          const SizedBox(width: 8),
          const Text(
            'Quick Plug',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.purple,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).filtersComingSoon),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1200),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune, size: 20, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  // -- Body --
  Widget _buildBody(BusinessQuickPlugProvider provider) {
    // Empty state: all candidates reviewed
    if (!provider.showUpgrade && !provider.hasCards) {
      return _buildEmptyState();
    }

    // Upgrade prompt
    if (provider.showUpgrade) {
      return _buildUpgradePrompt();
    }

    // Swipe deck
    return _buildSwipeDeck(provider);
  }

  // -- Empty State --
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 60, color: AppColors.teal),
            ),
            const SizedBox(height: 16),
            const Text(
              "You've seen all candidates!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new profiles',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<BusinessQuickPlugProvider>().load();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.teal, width: 1.5),
                ),
                child: const Text(
                  'Adjust Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Upgrade Prompt --
  Widget _buildUpgradePrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 48, color: AppColors.amber),
            const SizedBox(height: 16),
            const Text(
              'Daily limit reached',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Free plan: 5 swipes per day',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.push('/business/subscription'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Reload to dismiss upgrade state
                context.read<BusinessQuickPlugProvider>().load();
              },
              child: Text(
                'Maybe later',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Swipe Deck --
  Widget _buildSwipeDeck(BusinessQuickPlugProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 48;
    final deck = provider.deck;
    final currentIndex = provider.currentIndex;

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background card (next card peeking)
              if (currentIndex + 1 < deck.length)
                _buildBackgroundCard(deck[currentIndex + 1], cardWidth),

              // Foreground card
              if (provider.hasCards)
                _buildForegroundCard(provider.currentCard!, cardWidth),

              // Swipe labels
              if (_dragX > 40)
                Positioned(
                  top: 40,
                  left: 40,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: _buildSwipeLabel('INTERESTED', AppColors.green),
                  ),
                ),
              if (_dragX < -40)
                Positioned(
                  top: 40,
                  right: 40,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: _buildSwipeLabel('PASS', AppColors.red),
                  ),
                ),
            ],
          ),
        ),

        // Bottom action buttons
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pass button
              GestureDetector(
                onTap: () => _processSwipe(false),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.red, width: 2),
                  ),
                  child: const Icon(Icons.close, size: 28, color: AppColors.red),
                ),
              ),
              // Super interested
              GestureDetector(
                onTap: _handleSuperInterested,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                  child: const Icon(Icons.star, size: 24, color: Colors.white),
                ),
              ),
              // Shortlist button
              GestureDetector(
                onTap: () => _processSwipe(true),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal,
                  ),
                  child: const Icon(Icons.check, size: 28, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -- Background Card --
  Widget _buildBackgroundCard(QuickPlugCandidate nextCandidate, double cardWidth) {
    return Transform.translate(
      offset: const Offset(0, 12),
      child: Transform.scale(
        scale: 0.95,
        child: Opacity(
          opacity: 0.7,
          child: _buildCandidateCard(nextCandidate, cardWidth),
        ),
      ),
    );
  }

  // -- Foreground Card --
  Widget _buildForegroundCard(QuickPlugCandidate candidate, double cardWidth) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final dx = _isAnimatingOut ? _animX.value : _dragX;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.rotate(
            angle: dx * 0.001,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onPanUpdate: _isAnimatingOut
            ? null
            : (details) {
                setState(() {
                  _dragX += details.delta.dx;
                });
              },
        onPanEnd: _isAnimatingOut
            ? null
            : (details) {
                if (_dragX.abs() > 120) {
                  _processSwipe(_dragX > 0);
                } else {
                  setState(() {
                    _dragX = 0;
                  });
                }
              },
        child: _buildCandidateCard(candidate, cardWidth),
      ),
    );
  }

  // -- Candidate Card --
  Widget _buildCandidateCard(QuickPlugCandidate candidate, double cardWidth) {
    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _avatarColor(candidate.name),
              ),
              child: Center(
                child: Text(
                  candidate.initials,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              candidate.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 4),

            // Role + experience
            Text(
              '${candidate.role} \u00B7 ${candidate.experience}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),

            // Location
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place, size: 14, color: AppColors.teal),
                const SizedBox(width: 4),
                Text(
                  candidate.location,
                  style: const TextStyle(fontSize: 13, color: AppColors.teal),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Verified badge
            if (candidate.verified)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.verified, size: 16, color: AppColors.teal),
                  SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: candidate.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Summary
            Text(
              candidate.summary,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Swipe Label --
  Widget _buildSwipeLabel(String text, Color color) {
    final opacity = (_dragX.abs() / 120).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
