import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/services/entitlement_service.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_subscription.dart';
import 'package:plagit/models/quick_plug_candidate.dart';
import 'package:plagit/providers/business_providers.dart';

extension _QuickPlugL10n on AppLocalizations {
  String get interestSent {
    switch (localeName) {
      case 'it':
        return 'Interesse inviato';
      case 'ar':
        return 'تم إرسال الاهتمام';
      default:
        return 'Interest sent';
    }
  }

  String get filtersUnavailable {
    switch (localeName) {
      case 'it':
        return 'I filtri Quick Plug non sono ancora disponibili';
      case 'ar':
        return 'فلاتر Quick Plug غير متاحة بعد';
      default:
        return 'Quick Plug filters are not available yet';
    }
  }

  String get quickPlugNoMoreCandidatesTitle {
    switch (localeName) {
      case 'it':
        return 'Nessun altro candidato disponibile per ora';
      case 'ar':
        return 'لا يوجد مرشحون آخرون متاحون الآن';
      default:
        return 'No more candidates available right now';
    }
  }

  String get quickPlugNoMoreCandidatesBody {
    switch (localeName) {
      case 'it':
        return 'Hai già rivisto tutte le card disponibili nel deck attuale.';
      case 'ar':
        return 'لقد راجعت بالفعل كل البطاقات المتاحة في المجموعة الحالية.';
      default:
        return 'You have already reviewed every card in the current deck.';
    }
  }

  String get quickPlugReloadDeck {
    switch (localeName) {
      case 'it':
        return 'Ricarica deck';
      case 'ar':
        return 'إعادة تحميل المجموعة';
      default:
        return 'Reload deck';
    }
  }

  String get quickPlugViewPlans {
    switch (localeName) {
      case 'it':
        return 'Vedi piani';
      case 'ar':
        return 'عرض الخطط';
      default:
        return 'View plans';
    }
  }

  String get quickPlugSwipeLimitReached {
    switch (localeName) {
      case 'it':
        return 'Limite giornaliero di swipe raggiunto';
      case 'ar':
        return 'تم الوصول إلى الحد اليومي للتمريرات';
      default:
        return 'Daily swipe limit reached';
    }
  }

  String quickPlugUpgradeHint(String planName) {
    switch (localeName) {
      case 'it':
        return 'Piano $planName: aggiorna il piano per sbloccare Quick Plug.';
      case 'ar':
        return 'خطة $planName: قم بالترقية لفتح Quick Plug.';
      default:
        return '$planName plan: upgrade your plan to unlock Quick Plug.';
    }
  }

  String quickPlugPlanLimitLine(String planName, int dailyLimit) {
    switch (localeName) {
      case 'it':
        return '$planName: $dailyLimit swipe al giorno disponibili';
      case 'ar':
        return '$planName: $dailyLimit تمريرات متاحة يومياً';
      default:
        return '$planName: $dailyLimit swipes available per day';
    }
  }

  String get quickPlugRequiresPaidPlan {
    switch (localeName) {
      case 'it':
        return 'Quick Plug richiede Pro o Premium';
      case 'ar':
        return 'Quick Plug يتطلب Pro أو Premium';
      default:
        return 'Quick Plug requires Pro or Premium';
    }
  }

  String get quickPlugPassed {
    switch (localeName) {
      case 'it':
        return 'Passato';
      case 'ar':
        return 'تم التخطي';
      default:
        return 'Passed';
    }
  }

  String get quickPlugInterested {
    switch (localeName) {
      case 'it':
        return 'INTERESSATO';
      case 'ar':
        return 'مهتم';
      default:
        return 'INTERESTED';
    }
  }

  String get quickPlugPassLabel {
    switch (localeName) {
      case 'it':
        return 'PASSA';
      case 'ar':
        return 'تخطي';
      default:
        return 'PASS';
    }
  }

  String get verifiedLabel {
    switch (localeName) {
      case 'it':
        return 'Verificato';
      case 'ar':
        return 'موثق';
      default:
        return 'Verified';
    }
  }
}

/// Business Quick Plug — Tinder-style swipe deck for candidate discovery.
/// This is the signature feature of the business side.
class BusinessQuickPlugView extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const BusinessQuickPlugView({
    super.key,
    this.onBackToHome,
  });

  @override
  State<BusinessQuickPlugView> createState() => _BusinessQuickPlugViewState();
}

class _BusinessQuickPlugViewState extends State<BusinessQuickPlugView>
    with SingleTickerProviderStateMixin {
  static const _deckBackground = Color(0xFF10141C);
  double _dragX = 0;
  bool _isAnimatingOut = false;
  String? _syncedPlanKey;

  late AnimationController _animController;
  late Animation<double> _animX;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    if (provider.swipesUsed >= provider.dailyLimit) {
      provider.swipe(interested);
      return;
    }

    _isAnimatingOut = true;
    final targetX = interested ? 500.0 : -500.0;

    _animX = Tween<double>(begin: _dragX, end: targetX).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward(from: 0).then((_) async {
      if (!mounted) return;
      try {
        await provider.swipe(interested);

        setState(() {
          _dragX = 0;
          _isAnimatingOut = false;
        });

        _animController.reset();

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                interested
                    ? AppLocalizations.of(context).interestSent
                    : AppLocalizations.of(context).quickPlugPassed,
              ),
              duration: const Duration(milliseconds: 1200),
              behavior: SnackBarBehavior.floating,
              backgroundColor:
                  interested ? AppColors.teal : AppColors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _dragX = 0;
          _isAnimatingOut = false;
        });
        _animController.reset();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(milliseconds: 1600),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.red,
          ),
        );
      }
    });
  }

  // -- Color from name hash for avatar --
  Color _avatarColor(String name) {
    final hash = name.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();
  }

  void _syncPlanState(BusinessSubscription subscription) {
    _queueDeckBootstrapForPlan(subscription);
  }

  Future<void> _retryDeckLoad(BusinessSubscription subscription) async {
    final canUseQuickPlug = EntitlementService.canUseQuickPlug(subscription);
    final dailyLimit = EntitlementService.dailySwipeLimit(subscription);
    _syncedPlanKey = '${subscription.plan.name}:$dailyLimit:$canUseQuickPlug';

    final provider = context.read<BusinessQuickPlugProvider>();
    provider.syncEntitlements(
      canUseQuickPlug: canUseQuickPlug,
      dailyLimit: dailyLimit,
    );
    if (canUseQuickPlug) {
      await provider.load();
    }
  }

  void _queueDeckBootstrapForPlan(
    BusinessSubscription subscription, {
    bool force = false,
  }) {
    final canUseQuickPlug = EntitlementService.canUseQuickPlug(subscription);
    final dailyLimit = EntitlementService.dailySwipeLimit(subscription);
    final planKey = '${subscription.plan.name}:$dailyLimit:$canUseQuickPlug';
    if (!force && _syncedPlanKey == planKey) return;
    _syncedPlanKey = planKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<BusinessQuickPlugProvider>();
      provider.syncEntitlements(
        canUseQuickPlug: canUseQuickPlug,
        dailyLimit: dailyLimit,
      );
      if (canUseQuickPlug) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<BusinessAuthProvider>().subscription;
    final canUseQuickPlug = EntitlementService.canUseQuickPlug(subscription);
    _syncPlanState(subscription);
    final provider = context.watch<BusinessQuickPlugProvider>();

    if (!canUseQuickPlug) {
      return Scaffold(
        backgroundColor: _deckBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _buildLockedPrompt(subscription)),
              _buildTopChrome(),
            ],
          ),
        ),
      );
    }

    // Loading state
    if (provider.loading) {
      return Scaffold(
        backgroundColor: _deckBackground,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              ),
              _buildTopChrome(),
            ],
          ),
        ),
      );
    }

    // Error state
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: _deckBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.error!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async => _retryDeckLoad(subscription),
                        child: Text(
                          AppLocalizations.of(context).retryAction,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildTopChrome(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _deckBackground,
      body: SafeArea(
        child: _buildBody(provider, subscription),
      ),
    );
  }

  Widget _buildTopChrome() {
    return Positioned(
      top: 16,
      left: 20,
      right: 20,
      child: Row(
        children: [
          _glassCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!.call();
                return;
              }
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/business/home');
              }
            },
          ),
          const Spacer(),
          _glassCircleButton(
            icon: Icons.tune_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).filtersUnavailable),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1200),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _glassCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  // -- Body --
  Widget _buildBody(
    BusinessQuickPlugProvider provider,
    BusinessSubscription subscription,
  ) {
    if (!provider.showUpgrade && !provider.hasCards) {
      return Stack(
        children: [
          Positioned.fill(child: _buildEmptyState()),
          _buildTopChrome(),
        ],
      );
    }

    if (provider.showUpgrade) {
      return Stack(
        children: [
          Positioned.fill(
            child: _buildUpgradePrompt(subscription, provider.dailyLimit),
          ),
          _buildTopChrome(),
        ],
      );
    }

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
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).quickPlugNoMoreCandidatesTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).quickPlugNoMoreCandidatesBody,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.72)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<BusinessQuickPlugProvider>().load();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  AppLocalizations.of(context).quickPlugReloadDeck,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedPrompt(BusinessSubscription subscription) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 34,
                color: AppColors.amber,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).quickPlugRequiresPaidPlan,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)
                  .quickPlugUpgradeHint(subscription.plan.displayName),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                subscription.plan.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.push('/business/subscription'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).quickPlugViewPlans,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.charcoal,
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

  // -- Upgrade Prompt --
  Widget _buildUpgradePrompt(
    BusinessSubscription subscription,
    int dailyLimit,
  ) {
    final planLine = AppLocalizations.of(context)
        .quickPlugPlanLimitLine(subscription.plan.displayName, dailyLimit);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 48, color: AppColors.amber),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).quickPlugSwipeLimitReached,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              planLine,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.72)),
              textAlign: TextAlign.center,
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
                child: Text(
                  AppLocalizations.of(context).quickPlugViewPlans,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
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
    final cardWidth = screenWidth - 8;
    final deck = provider.deck;
    final currentIndex = provider.currentIndex;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (currentIndex + 1 < deck.length)
          _buildBackgroundCard(deck[currentIndex + 1], cardWidth),

        if (provider.hasCards)
          _buildForegroundCard(provider.currentCard!, cardWidth),

        _buildTopChrome(),

        if (_dragX > 40)
          Positioned(
            top: 72,
            left: 28,
            child: Transform.rotate(
              angle: -0.2,
              child: _buildSwipeLabel(
                AppLocalizations.of(context).quickPlugInterested,
                AppColors.green,
              ),
            ),
          ),
        if (_dragX < -40)
          Positioned(
            top: 72,
            right: 28,
            child: Transform.rotate(
              angle: 0.2,
              child: _buildSwipeLabel(
                AppLocalizations.of(context).quickPlugPassLabel,
                AppColors.red,
              ),
            ),
          ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _floatingActionButton(
                onTap: () => _processSwipe(false),
                size: 62,
                fill: Colors.white.withValues(alpha: 0.95),
                icon: Icons.close_rounded,
                iconColor: AppColors.red,
                shadowColor: Colors.black.withValues(alpha: 0.18),
              ),
              const SizedBox(width: 28),
              _floatingActionButton(
                onTap: () => _processSwipe(true),
                size: 68,
                fill: AppColors.teal,
                icon: Icons.favorite_rounded,
                iconColor: Colors.white,
                shadowColor: AppColors.teal.withValues(alpha: 0.34),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _floatingActionButton({
    required VoidCallback onTap,
    required double size,
    required Color fill,
    required IconData icon,
    required Color iconColor,
    required Color shadowColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.42, color: iconColor),
      ),
    );
  }

  // -- Background Card --
  Widget _buildBackgroundCard(QuickPlugCandidate nextCandidate, double cardWidth) {
    return Transform.translate(
      offset: const Offset(0, 16),
      child: Transform.scale(
        scale: 0.96,
        child: Opacity(
          opacity: 0.55,
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
    final deck = context.read<BusinessQuickPlugProvider>().deck;
    final currentIndex = context.read<BusinessQuickPlugProvider>().currentIndex;
    final metaParts = <String>[
      if (candidate.location.isNotEmpty) candidate.location,
      if (candidate.experience.isNotEmpty) candidate.experience,
    ];

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 0.72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCandidatePhoto(candidate),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.34, 0.62, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                children: List.generate(deck.length, (index) {
                  final isActive = index == currentIndex;
                  final isViewed = index < currentIndex;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: index == deck.length - 1 ? 0 : 4),
                      decoration: BoxDecoration(
                        color: isViewed || isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 118,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (candidate.verified)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context).verifiedLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    candidate.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: -0.6,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    candidate.role,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (metaParts.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      metaParts.join(' · '),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (candidate.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: candidate.tags.take(3).map((tag) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (candidate.summary.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      candidate.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => context.push('/business/candidate/${candidate.id}'),
                  child: Container(
                    width: 42,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildCandidatePhoto(QuickPlugCandidate candidate) {
    final photoUrl = _candidatePhotoUrl(candidate);
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildPhotoFallback(candidate),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _buildPhotoFallback(candidate);
      },
    );
  }

  Widget _buildPhotoFallback(QuickPlugCandidate candidate) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _avatarColor(candidate.name).withValues(alpha: 0.92),
            AppColors.charcoal,
          ],
        ),
      ),
      child: Center(
        child: Text(
          candidate.initials,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.2,
          ),
        ),
      ),
    );
  }

  String _candidatePhotoUrl(QuickPlugCandidate candidate) {
    final imageId = (candidate.id.hashCode.abs() % 70) + 1;
    return 'https://i.pravatar.cc/900?img=$imageId';
  }

  // -- Swipe Label --
  Widget _buildSwipeLabel(String text, Color color) {
    final opacity = (_dragX.abs() / 120).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
