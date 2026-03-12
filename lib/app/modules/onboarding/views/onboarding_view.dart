import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1a1a2e),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.pages.length,
              itemBuilder: (context, index) {
                final page = controller.pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: (page['tagColor'] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(page['icon'] as IconData, size: 60, color: page['tagColor'] as Color),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: (page['tagColor'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: (page['tagColor'] as Color).withOpacity(0.4)),
                        ),
                        child: Text(page['tag'] as String,
                            style: TextStyle(color: page['tagColor'] as Color, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 20),
                      Text(page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.3)),
                      const SizedBox(height: 16),
                      Text(page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, height: 1.6)),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: controller.skip,
                child: const Text('Skip', style: TextStyle(color: Color(0xff58c8c8), fontSize: 15)),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: Column(
                children: [
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(controller.pages.length, (i) {
                      final active = i == controller.currentPage.value;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? const Color(0xff58c8c8) : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  )),
                  const SizedBox(height: 24),
                  Obx(() {
                    final isLast = controller.currentPage.value == controller.pages.length - 1;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: controller.next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff58c8c8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(isLast ? 'Get Started' : 'Next',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: controller.goToLogin,
                    child: Text('Already have an account? Login',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
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
