import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomImageWidget extends StatefulWidget {
  final double? height;
  final double? width;
  final String? imgUrl;
  final String? imgAssetPath;
  final BoxFit? fit;
  final double? radius;
  final double? horizontalMargin;
  final double? verticalMargin;

  const CustomImageWidget({
    super.key,
    this.height,
    required this.width,
    this.imgUrl,
    this.imgAssetPath,
    this.fit,
    this.radius,
    this.verticalMargin,
    this.horizontalMargin,
  });

  @override
  State<CustomImageWidget> createState() => _CustomImageWidgetState();
}

class _CustomImageWidgetState extends State<CustomImageWidget> {
  late ImageProvider _imageProvider;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    final String imageUrl = widget.imgUrl ??
        "https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg";

    _imageProvider = CachedNetworkImageProvider(imageUrl);

    _imageProvider.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (image, synchronousCall) {
              if (mounted) {
                setState(() {
                  _isLoaded = true;
                });
              }
            },
            onError: (exception, stackTrace) {
              if (mounted) {
                setState(() {
                  _isLoaded = false;
                });
              }
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: widget.horizontalMargin ?? 0.0,
          vertical: widget.verticalMargin ?? 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius ?? 0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius ?? 0),
        child: widget.imgAssetPath != null
            ? _customAssetImage
            : _isLoaded
                ? Image(
                    image: _imageProvider,
                    height: widget.height,
                    width: widget.width ?? 200,
                    fit: widget.fit ?? BoxFit.cover,
                  )
                : _loadingIndicator(),
      ),
    );
  }

  Widget _loadingIndicator() {
    return Container(
      height: widget.height ?? 200,
      width: widget.width ?? 200,
      color: Colors.grey[300],
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget get _customAssetImage => Image.asset(
        widget.imgAssetPath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
      );
}
