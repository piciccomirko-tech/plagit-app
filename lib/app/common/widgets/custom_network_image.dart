import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../utils/exports.dart';

class CustomNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double radius;

  const CustomNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        // height: radius,
        // width: radius,
        // height:   200.h,
        // width:  400.w,
        fit: fit,
        imageUrl: url,
        placeholder: (BuildContext context, String url) => const Center(
          child: CupertinoActivityIndicator(),
        ),
        errorWidget: (context, url, error) {

          return Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
