import 'dart:io';
import 'dart:math' as math;
import 'package:mh/app/common/utils/exports.dart';
import '../controllers/login_register_hints_controller.dart';

// ═══════════════════════════════════════════════════════════════════
// Plagit Onboarding — 3-phase cinematic flow
//
//  Phase 1  (0–1.0s)   Splash: warm white bg, logo fades in + scales
//  Phase 2  (1.0–2.4s) Slogan: "Hospitality without limits" center
//  Phase 3  (2.4s+)    Welcome: bg + content stagger entrance
// ═══════════════════════════════════════════════════════════════════

class LoginRegisterHintsView extends GetView<LoginRegisterHintsController> {
  const LoginRegisterHintsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF9), // warm white
      body: _OnboardingFlow(controller: controller),
    );
  }
}

// ─── Phase enum ───
enum _Phase { splash, slogan, welcome }

class _OnboardingFlow extends StatefulWidget {
  final LoginRegisterHintsController controller;
  const _OnboardingFlow({required this.controller});

  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow>
    with TickerProviderStateMixin {
  // Current phase
  _Phase _phase = _Phase.splash;

  // Phase 1: Splash
  late final AnimationController _splash;
  late final Animation<double> _splashFade;
  late final Animation<double> _splashScale;

  // Splash exit (smooth fade-out before slogan)
  late final AnimationController _splashExit;

  // Phase 2: Slogan
  late final AnimationController _slogan;
  late final Animation<double> _sloganFadeIn;
  late final Animation<double> _sloganScale;
  late final Animation<double> _sloganFadeOut;

  // Phase 3: Welcome
  late final AnimationController _enter;
  late final AnimationController _float;
  late final AnimationController _pulse;

  // Cross-fade from white bg to welcome bg
  late final AnimationController _bgReveal;

  // Loading heartbeat state
  late final AnimationController _heartbeat;
  late final Animation<double> _heartbeatScale;
  bool _isLoading = false;

  LoginRegisterHintsController get ctrl => widget.controller;

  @override
  void initState() {
    super.initState();

    // ── Phase 1: Splash entrance (900ms) ──
    _splash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _splashFade = CurvedAnimation(
      parent: _splash,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _splashScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _splash,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Splash exit: logo fades out + scales slightly up (350ms)
    _splashExit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // ── Phase 2: Slogan (1300ms) ──
    _slogan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    // 0–38% (0–500ms): fade in + scale
    _sloganFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slogan,
        curve: const Interval(0.0, 0.38, curve: Curves.easeOut),
      ),
    );
    _sloganScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _slogan,
        curve: const Interval(0.0, 0.38, curve: Curves.easeOut),
      ),
    );
    // 73–100% (950–1300ms): fade out
    _sloganFadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _slogan,
        curve: const Interval(0.73, 1.0, curve: Curves.easeInOut),
      ),
    );

    // ── Background crossfade (700ms) ──
    _bgReveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // ── Phase 3: Welcome stagger (1800ms) ──
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // ── Heartbeat: soft double-beat pulse (1500ms cycle) ──
    _heartbeat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // Double-beat: quick up, down, smaller up, settle
    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.035)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 13,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.035, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 40,
      ),
    ]).animate(_heartbeat);

    _runSequence();
  }

  void _startLoading() {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    _heartbeat.repeat();
  }

  void _stopLoading() {
    _heartbeat.stop();
    _heartbeat.reset();
    if (mounted) setState(() => _isLoading = false);
  }

  void _onLoginTap() {
    if (_isLoading) return;
    _startLoading();
    // Navigate — GetX will push the route; stop loading after a short delay
    ctrl.onLoginPressed();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _stopLoading();
    });
  }

  void _onGetStartedTap() {
    if (_isLoading) return;
    _startLoading();
    ctrl.onSignUpPressed();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _stopLoading();
    });
  }

  Future<void> _runSequence() async {
    // Phase 1: ~6s brand reveal on white page — logo only, pulsing
    _heartbeat.repeat();
    await _splash.forward();
    if (!mounted) return;

    // Logo pulses alone on clean white bg for ~5s after fade-in
    await Future.delayed(const Duration(milliseconds: 5000));
    _heartbeat.stop();
    _heartbeat.reset();
    if (!mounted) return;

    // Transition out: logo fades, bg crossfades to welcome
    _bgReveal.forward();
    await _splashExit.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Phase 2: Cinematic slogan (centered, large)
    setState(() => _phase = _Phase.slogan);
    await _slogan.forward();
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    // Phase 3: Welcome
    setState(() => _phase = _Phase.welcome);
    _enter.forward();
    _float.repeat(reverse: true);
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _splash.dispose();
    _splashExit.dispose();
    _slogan.dispose();
    _bgReveal.dispose();
    _enter.dispose();
    _float.dispose();
    _pulse.dispose();
    _heartbeat.dispose();
    super.dispose();
  }

  // ─── Stagger helper for welcome phase ───
  Widget _stagger((double, double) slot, Widget child, {double dy = 16}) {
    final curve = Interval(slot.$1, slot.$2, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: _enter,
      builder: (_, __) {
        final t = curve.transform(_enter.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, dy * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return SafeArea(
    child: Stack(
      fit: StackFit.expand,
      children: [
       // — Layer 1: Welcome background ...
        AnimatedBuilder(
          animation: _bgReveal,
          builder: (_, child) =>
              Opacity(opacity: _bgReveal.value, child: child),
          child: _WelcomeBackground(),
        ),

        // ── Layer 2: Warm white splash bg (fades out via crossfade) ──
        AnimatedBuilder(
          animation: _bgReveal,
          builder: (_, child) =>
              Opacity(opacity: 1 - _bgReveal.value, child: child),
          child: const ColoredBox(
            color: Color(0xFFFCFBF9),
            child: SizedBox.expand(),
          ),
        ),

        // ── Layer 3: Splash logo — original asset, pulsing ──
        if (_phase == _Phase.splash)
          AnimatedBuilder(
            animation: Listenable.merge([_splash, _splashExit, _heartbeat]),
            builder: (_, __) {
              final enterOpacity = _splashFade.value;
              final exitOpacity = 1.0 - _splashExit.value;
              final exitScale = 1.0 + _splashExit.value * 0.05;
              final hb = _heartbeat.isAnimating ? _heartbeatScale.value : 1.0;
              return Opacity(
                opacity: (enterOpacity * exitOpacity).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: _splashScale.value * exitScale * hb,
                  child: Center(child: _SplashLogo()),
                ),
              );
            },
          ),

        // ── Layer 4: Slogan ──
        if (_phase == _Phase.slogan)
          AnimatedBuilder(
            animation: _slogan,
            builder: (_, __) {
              final fadeIn = _sloganFadeIn.value;
              final fadeOut =
                  _slogan.value < 0.71 ? 1.0 : _sloganFadeOut.value;
              final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: _sloganScale.value,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        'Hospitality without limits',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize: 29.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.6,
                          shadows: const [
                            Shadow(
                              color: Color(0x50000000),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        // ── Layer 5: Welcome content ──
        if (_phase == _Phase.welcome) _buildWelcomeContent(),

        // ── Layer 6: Loading state — dim overlay + elevated pulsing logo ──
        if (_isLoading) ...[
          AnimatedOpacity(
            opacity: 0.45,
            duration: const Duration(milliseconds: 300),
            child: const ColoredBox(
              color: Colors.black,
              child: SizedBox.expand(),
            ),
          ),
          // Pulsing logo above the dim
          Center(
            child: AnimatedBuilder(
              animation: _heartbeat,
              builder: (_, child) => Transform.scale(
                scale: _heartbeatScale.value,
                child: child,
              ),
              child: const _WelcomeLogo(),
            ),
          ),
        ],
      ],
    ),
  );
  }

  // ─── Welcome content with staggered entrance ───
  Widget _buildWelcomeContent() {
    const s = (
      bg:     (0.00, 0.30),
      logo:   (0.06, 0.38),
      title:  (0.16, 0.44),
      tag:    (0.24, 0.50),
      script: (0.30, 0.56),
      slogan: (0.34, 0.60),
      btn1:   (0.42, 0.66),
      btn2:   (0.48, 0.72),
      or_:    (0.56, 0.78),
      social: (0.60, 0.82),
      foot:   (0.68, 0.90),
    );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, box) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Logo with float + heartbeat during loading
                _stagger(
                  s.logo,
                  AnimatedBuilder(
                    animation: Listenable.merge([_float, _heartbeat]),
                    builder: (_, child) {
                      final floatY = math.sin(_float.value * math.pi) * 2.5;
                      final hbScale =
                          _isLoading ? _heartbeatScale.value : 1.0;
                      return Transform.translate(
                        offset: Offset(0, floatY),
                        child: Transform.scale(
                          scale: hbScale,
                          child: child,
                        ),
                      );
                    },
                    child: const _WelcomeLogo(),
                  ),
                ),
                SizedBox(height: 22.h),

                // PLAGIT
                _stagger(
                  s.title,
                  Text(
                    'PLAGIT',
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Tagline
                _stagger(
                  s.tag,
                  Text(
                    'Connect  •  Work  •  Grow',
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xE6FFFFFF),
                      letterSpacing: 1.6,
                    ),
                  ),
                ),

                // "Locally" accent
                _stagger(
                  s.script,
                  Align(
                    alignment: const Alignment(0.42, 0),
                    child: Transform.rotate(
                      angle: -0.035,
                      child: Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Text(
                          'Locally',
                          style: TextStyle(
                            fontFamily: MyAssets.fontMontserrat,
                            fontStyle: FontStyle.italic,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: MyColors.c_C6A34F,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // "Hospitality without limits" — permanent centered statement
                _stagger(
                  s.slogan,
                  Text(
                    'Hospitality without limits',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xD9FFFFFF), // 85%
                      letterSpacing: 1.4,
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // Get Started
                _stagger(
                  s.btn1,
                  _GradientButton(
                    text: 'Get Started',
                    pulse: _pulse,
                    onTap: _onGetStartedTap,
                  ),
                ),
                SizedBox(height: 12.h),

                // Log In
                _stagger(
                  s.btn2,
                  _GlassButton(text: 'Log In', onTap: _onLoginTap),
                ),
                SizedBox(height: 20.h),

                // "or" with white lines
                _stagger(
                  s.or_,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0x80FFFFFF),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontFamily: MyAssets.fontMontserrat,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xE6FFFFFF),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0x80FFFFFF),
                        ),
                      ),
                    ],
                  ),
                  dy: 8,
                ),
                SizedBox(height: 14.h),

                // Social pill
                _stagger(s.social, const _SocialPill(), dy: 10),
                SizedBox(height: 26.h),

                // Footer
                _stagger(
                  s.foot,
                  _Footer(onTap: ctrl.onPolicyPressed),
                  dy: 6,
                ),
                SizedBox(height: 12.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════

/// Splash-phase logo — original asset, large, on warm white bg
class _SplashLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      height: 180.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(42.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3358C8C8),
            blurRadius: 50,
            spreadRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42.r),
        child: Image.asset(
          MyAssets.logo,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackLogo(42.r, 72.sp),
        ),
      ),
    );
  }
}

/// Welcome-phase logo — smaller, with teal halo
class _WelcomeLogo extends StatelessWidget {
  const _WelcomeLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      height: 150.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D58C8C8),
            blurRadius: 44,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.r),
        child: Image.asset(
          MyAssets.logo,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackLogo(36.r, 58.sp),
        ),
      ),
    );
  }
}

/// Fallback gradient "P" logo
Widget _fallbackLogo(double radius, double fontSize) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF58C8C8), Color(0xFF3F8E9B)],
      ),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Center(
      child: Text(
        'P',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: MyAssets.fontKlavika,
        ),
      ),
    ),
  );
}

/// Welcome background: image + dark overlay + teal glow
class _WelcomeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          MyAssets.plagitBg,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            MyAssets.loginRegisterHintsBg,
            fit: BoxFit.cover,
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33000000), // 20% — was 30%
                Color(0x8C000000), // 55% — was 67%
                Color(0xD9000000), // 85% — was 91%
              ],
              stops: [0.0, 0.50, 1.0],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Color(0x1458C8C8),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Buttons ───

class _GradientButton extends StatefulWidget {
  final String text;
  final AnimationController pulse;
  final VoidCallback? onTap;
  const _GradientButton(
      {required this.text, required this.pulse, this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  double _s = 1.0;
  void _down(_) => setState(() => _s = 0.97);
  void _up(_) => setState(() => _s = 1.0);
  void _cancel() => setState(() => _s = 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pulse,
      builder: (_, __) {
        final glow = 0.18 + widget.pulse.value * 0.10;
        return AnimatedScale(
          scale: _s,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTapDown: _down,
            onTapUp: _up,
            onTapCancel: _cancel,
            onTap: widget.onTap,
            child: Container(
              height: 60.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58C8C8), Color(0xFF3F8E9B)],
                ),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: const Color(0x26FFFFFF),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(88, 200, 200, glow),
                    blurRadius: 22,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 21.w),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  const _GlassButton({required this.text, this.onTap});

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  double _s = 1.0;
  void _down(_) => setState(() => _s = 0.97);
  void _up(_) => setState(() => _s = 1.0);
  void _cancel() => setState(() => _s = 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _s,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _cancel,
        onTap: widget.onTap,
        child: Container(
          height: 60.w,
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF), // 8%
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: const Color(0x8CFFFFFF), // 55%
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Social login pill ───

class _SocialPill extends StatelessWidget {
  const _SocialPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue with',
                  style: TextStyle(
                    fontFamily: MyAssets.fontMontserrat,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A2A2A),
                  ),
                ),
                SizedBox(width: 14.w),
                if (Platform.isIOS) ...[
                  Image.asset(MyAssets.apple,
                      width: 24.w, height: 24.w, color: Colors.black),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 11.w),
                    child: Container(
                      width: 1,
                      height: 22.w,
                      color: const Color(0x1A000000),
                    ),
                  ),
                ],
                Image.asset(MyAssets.google, width: 24.w, height: 24.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Footer ───

class _Footer extends StatelessWidget {
  final VoidCallback? onTap;
  const _Footer({this.onTap});

  Widget _linkWithLine(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0x99FFFFFF), // 60%
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: text.length * 5.8.w,
          height: 1,
          color: const Color(0x66FFFFFF), // 40%
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _linkWithLine('Privacy Policy'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '·',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0x80FFFFFF),
              ),
            ),
          ),
          _linkWithLine('Terms of Service'),
        ],
      ),
    );
  }
}
