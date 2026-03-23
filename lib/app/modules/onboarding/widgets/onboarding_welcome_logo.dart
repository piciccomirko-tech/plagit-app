import 'package:flutter/material.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';

/// Plagit mark: uses [MyAssets.logo] when available; otherwise a simple branded placeholder.
class OnboardingWelcomeLogo extends StatelessWidget {
  const OnboardingWelcomeLogo({
    super.key,
    this.size = 88,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        MyAssets.logo,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _Placeholder(size: size),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return _Placeholder(size: size);
        },
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MyColors.box,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: MyColors.primaryLight.withOpacity(0.35)),
      ),
      child: Icon(
        Icons.work_outline_rounded,
        size: size * 0.45,
        color: MyColors.primaryLight,
      ),
    );
  }
}
