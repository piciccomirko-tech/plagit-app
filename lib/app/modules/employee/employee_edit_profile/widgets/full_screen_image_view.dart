import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/custom_appbar.dart';

class FullScreenImageView extends StatelessWidget {
  final String fileUrl;

  const FullScreenImageView({required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "Image  Viewer",
        context: context,
        centerTitle: true,
      ),
      body: Center(
        child: Image.file(File(fileUrl.toString())
        ),
      ),
    );
  }
}
