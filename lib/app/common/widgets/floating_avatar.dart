import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// Floating Lottie avatar button — fixed at bottom-right of every screen.
/// Tapping it shows a chat bubble with context-aware navigation tips.
class FloatingAvatar extends StatefulWidget {
  final Widget child;

  const FloatingAvatar({super.key, required this.child});

  @override
  State<FloatingAvatar> createState() => _FloatingAvatarState();
}

class _FloatingAvatarState extends State<FloatingAvatar>
    with SingleTickerProviderStateMixin {
  bool _showBubble = false;
  late AnimationController _bubbleAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bubbleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = CurvedAnimation(parent: _bubbleAnim, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _bubbleAnim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _showBubble = !_showBubble);
    if (_showBubble) {
      _bubbleAnim.forward();
    } else {
      _bubbleAnim.reverse();
    }
  }

  void _dismiss() {
    if (_showBubble) _toggle();
  }

  String _getTip() {
    final route = Get.currentRoute;

    if (route.contains('splash')) {
      return 'Welcome to Plagit! The app is loading...';
    }
    if (route.contains('onboarding')) {
      return 'Swipe left to explore features, or tap Skip to jump ahead.';
    }
    if (route.contains('subscription')) {
      return 'Subscribe for premium features, or continue for free.';
    }
    if (route.contains('login')) {
      return 'Enter your credentials to sign in. New here? Tap Register.';
    }
    if (route.contains('register')) {
      return 'Fill in your details to create an account and get started.';
    }
    if (route.contains('welcome')) {
      return 'Choose your role — looking for a job or hiring staff?';
    }
    if (route.contains('admin-home') || route.contains('admin-dashboard')) {
      return 'Manage requests, employees, and clients from your dashboard.';
    }
    if (route.contains('client-home') || route.contains('client-dashboard')) {
      return 'Post jobs, manage hires, and track your employees here.';
    }
    if (route.contains('employee-home') || route.contains('employee-dashboard')) {
      return 'Browse available shifts, check your schedule, and track earnings.';
    }
    if (route.contains('chat') || route.contains('live-chat')) {
      return 'Chat directly with employers or candidates in real time.';
    }
    if (route.contains('notification')) {
      return 'Stay updated with your latest alerts and messages.';
    }
    if (route.contains('settings')) {
      return 'Update your preferences, language, and account settings.';
    }
    if (route.contains('profile')) {
      return 'Keep your profile updated to improve your match score.';
    }
    if (route.contains('calender')) {
      return 'View and manage your upcoming shifts on the calendar.';
    }
    if (route.contains('job')) {
      return 'Browse job details, apply, or manage your postings.';
    }

    return 'Need help? Explore the app or check Settings for more options.';
  }

  @override
  Widget build(BuildContext context) {
    // Don't show on splash or onboarding
    final route = Get.currentRoute;
    final hideOnRoutes = ['/splash', '/onboarding'];
    final shouldHide = hideOnRoutes.any((r) => route.startsWith(r));

    return Stack(
      children: [
        // Main app content
        widget.child,

        if (!shouldHide) ...[
          // Dismiss layer
          if (_showBubble)
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

          // Chat bubble
          Positioned(
            bottom: 90,
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnim,
              alignment: Alignment.bottomRight,
              child: Container(
                width: 240,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3035),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded,
                            color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Quick Tip',
                          style: TextStyle(
                            color: const Color(0xFF5DDDD4).withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTip(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Lottie button
          Positioned(
            bottom: 20,
            right: 16,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0D3035),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5DDDD4).withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Lottie.asset(
                    'assets/animations/avatar_pulse.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
