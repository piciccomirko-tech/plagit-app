import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/onboarding/controllers/onboarding_welcome_controller.dart';
import 'package:mh/app/modules/onboarding/widgets/onboarding_welcome_logo.dart';

/// Dark welcome step: role choice + value prop. Wire navigation from [OnboardingWelcomeController] later.
class OnboardingWelcomeView extends StatelessWidget {
  const OnboardingWelcomeView({super.key});

  static const double _horizontalPad = 32;
  static const double _buttonHeight = 56;
  static const double _buttonRadius = 18;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingWelcomeController());
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: MyColors.frameBg,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MyColors.frameBg,
              MyColors.frameBg,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8 + bottomInset * 0.25),
                      const _LogoHero(),
                      const SizedBox(height: 44),
                      Text(
                        'Swipe. Match. Work.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: MyAssets.fontKlavika,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          letterSpacing: -0.8,
                          color: MyColors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: Text(
                          'The fastest way to connect hospitality talent and businesses.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: MyAssets.fontKlavika,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 0.1,
                            color: MyColors.c_858585,
                          ),
                        ),
                      ),
                      const SizedBox(height: 44),
                      SizedBox(
                        width: double.infinity,
                        height: _buttonHeight,
                        child: FilledButton(
                          onPressed: controller.onContinueAsCandidate,
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(MyColors.primaryLight),
                            foregroundColor:
                                WidgetStateProperty.all(MyColors.c_111111),
                            elevation: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.pressed)) {
                                return 0;
                              }
                              return 3;
                            }),
                            shadowColor: WidgetStateProperty.all(
                              MyColors.primaryLight.withOpacity(0.4),
                            ),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(_buttonRadius),
                              ),
                            ),
                          ),
                          child: Text(
                            'Continue as Candidate',
                            style: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: _buttonHeight,
                        child: OutlinedButton(
                          onPressed: controller.onContinueAsBusiness,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MyColors.white,
                            backgroundColor: MyColors.box.withOpacity(0.45),
                            side: BorderSide(
                              color: MyColors.primaryLight.withOpacity(0.55),
                              width: 1.25,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_buttonRadius),
                            ),
                          ),
                          child: Text(
                            'Continue as Business',
                            style: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'No long CVs. No wasted time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: MyAssets.fontKlavika,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                          letterSpacing: 0.35,
                          color: MyColors.icon.withOpacity(0.55),
                        ),
                      ),
                      SizedBox(height: 28 + bottomInset),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Larger logo with soft brand glow and circular plate for hierarchy.
class _LogoHero extends StatelessWidget {
  const _LogoHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 168,
          height: 168,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: MyColors.primaryLight.withOpacity(0.14),
                blurRadius: 48,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: MyColors.primaryLight.withOpacity(0.06),
                blurRadius: 72,
                spreadRadius: 12,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MyColors.box,
              border: Border.all(
                color: MyColors.primaryLight.withOpacity(0.22),
                width: 1,
              ),
            ),
            child: const OnboardingWelcomeLogo(size: 120),
          ),
        ),
      ],
    );
  }
}
