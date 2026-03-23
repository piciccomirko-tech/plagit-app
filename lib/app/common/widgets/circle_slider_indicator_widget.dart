import 'package:mh/app/common/utils/exports.dart';

import 'package:flutter/material.dart';


class CircleSliderIndicatorWidget extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final Color color;
  final Color selectedColor;

  const CircleSliderIndicatorWidget({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.color,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the total width of each indicator item
    final double itemWidth = 38.0; // 30.0 (max width) + 8.0 (horizontal margins)
    
    // Create a scroll controller
    final scrollController = ScrollController(
      initialScrollOffset: currentIndex * itemWidth,
    );

    // Scroll to the current index after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        final screenWidth = MediaQuery.of(context).size.width;
        final targetPosition = (currentIndex * itemWidth) - (screenWidth - itemWidth) / 2;
        final maxScroll = (itemCount * itemWidth - screenWidth).clamp(0.0, double.infinity);
        scrollController.animateTo(
          targetPosition.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(), // Prevent manual scrolling
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itemCount, (index) {
          return Container(
            width: index == currentIndex ? 30.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: index == currentIndex ? selectedColor : color,
            ),
          );
        }),
      ),
    );
  }
}









// class CircleSliderIndicatorWidget extends StatelessWidget {
//   final int currentIndex;
//   final int itemCount;
//   final Color color;
//   final Color selectedColor;
//
//   const CircleSliderIndicatorWidget({
//     super.key,
//     required this.currentIndex,
//     required this.itemCount,
//     required this.color,
//     required this.selectedColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       // physics: Bo(),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(itemCount, (index) {
//           return Container(
//             width: index == currentIndex ? 30.0 : 8.0,
//             height: 8.0,
//             margin: const EdgeInsets.symmetric(horizontal: 4.0),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20.0),
//               // shape: index == currentIndex ? BoxShape.rectangle : BoxShape.circle,
//               color: index == currentIndex ? selectedColor : color,
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }