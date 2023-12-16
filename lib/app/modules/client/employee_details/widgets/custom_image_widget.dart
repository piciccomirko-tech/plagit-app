import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String? imgUrl;
  final String? imgAssetPath;
  final BoxFit? fit;
  final double? radius;
  final double? horizontalMargin;
  final double? verticalMargin;

  const CustomImageWidget(
      {super.key,
      required this.height,
      required this.width,
      this.imgUrl,
      this.imgAssetPath,
      this.fit,
      this.radius,
      this.verticalMargin,
      this.horizontalMargin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin ?? 0.0, vertical: verticalMargin ?? 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(radius ?? 0),
          child: imgAssetPath != null ? _customAssetImage : _customNetworkImage),
    );
  }

  Widget get _customNetworkImage => CachedNetworkImage(
        height: height ?? 200,
        width: width ?? 200,
        fit: fit ?? BoxFit.cover,
        imageUrl: imgUrl ?? "https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg",
        placeholder: (context, url) => Container(
          color: Colors.white,
          child: const Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Column(
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
            const Text("No image")
          ],
        ),
      );

  Widget get _customAssetImage => Image.asset(
        imgAssetPath!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
      );
}
