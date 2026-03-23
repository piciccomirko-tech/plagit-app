import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class DownloadManager {
  static Future<void> downloadAndSaveMedia({
    required String mediaUrl,
    required String mediaType,
    required BuildContext context,
  }) async {
    try {
      bool hasPermission = await Gal.hasAccess();
      if (!hasPermission) {
        hasPermission = await Gal.requestAccess();
        if (!hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission denied to save media")),
          );
          return;
        }
      }

      final fileName = mediaUrl.split('/').last;
      final filePath = "${Directory.systemTemp.path}/$fileName";
      debugPrint("Saving file to: $filePath");

      await Dio().download(mediaUrl, filePath);
      debugPrint("File downloaded: $filePath");

      if (mediaType == "image") {
        await Gal.putImage(filePath);
      } else if (mediaType == "video") {
        await Gal.putVideo(filePath);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Media saved to gallery successfully!")),
      );
    } on GalException catch (e) {
      debugPrint("GalException: ${e.type.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.type.message)),
      );
    } catch (e, stackTrace) {
      debugPrint("Error: $e");
      debugPrint("StackTrace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while saving media")),
      );
    }
  }
}
