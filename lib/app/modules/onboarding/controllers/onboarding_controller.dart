import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.storefront_rounded,
      'tag': 'FOR BUSINESSES',
      'tagColor': const Color(0xff58c8c8),
      'title': 'Hire Hospitality Staff in Minutes',
      'subtitle': 'Post a job, browse verified candidates, and book your team — all from one place. No agencies, no hassle.',
    },
    {
      'icon': Icons.person_search_rounded,
      'tag': 'FOR CANDIDATES',
      'tagColor': const Color(0xffFFA800),
      'title': 'Get Hired for Jobs Near You',
      'subtitle': 'Build your profile once and get discovered by top restaurants and venues. Work on your own schedule.',
    },
    {
      'icon': Icons.handshake_rounded,
      'tag': 'PLAGIT PLATFORM',
      'tagColor': const Color(0xff00C92C),
      'title': 'The #1 Staffing Platform for Hospitality',
      'subtitle': 'Join thousands of businesses and professionals already using Plagit across the UK, Italy and beyond.',
    },
  ];

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  void skip() => _completeOnboarding();
  void goToLogin() => _completeOnboarding(goLogin: true);

  void _completeOnboarding({bool goLogin = false}) {
    StorageHelper.setOnboardingSeen = true;
    Get.offAllNamed(goLogin ? Routes.login : Routes.loginRegisterHints);
  }
}
