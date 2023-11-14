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
        // height: height ?? 200,
        // width: width ?? 200,
        fit: fit,
        imageUrl: url,
        placeholder: (context, url) => Container(
          color: Colors.white,
          child: const Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ],
          );
        },
      ),
    );
  }
}
