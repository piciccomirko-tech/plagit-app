import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:path/path.dart' as path;

class ImageHandler {
  final ImagePicker _imagePicker = ImagePicker();

  Future<CroppedFile?> pickAndCropImage({required String source}) async {
    try {
      final XFile? pickedFile;
      if (source == "camera") {
        pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      } else {
        pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile == null) {
        return null;
      }

      return await cropImage(File(pickedFile.path));
    } catch (e) {
      return null;
    }
  }

  Future<CroppedFile?> cropImage(File file) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressQuality: 100,
        maxWidth: 500,
        maxHeight: 500,
        compressFormat: ImageCompressFormat.png,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.blue,
            backgroundColor: Colors.white,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            rectX: 0,
            rectY: 0,
            rectWidth: 500,
            rectHeight: 500,
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetButtonHidden: false,
          ),
        ],
      );

      return croppedFile;
    } catch (e) {
      return null;
    }
  }

  Future<XFile?> compressImage(File file) async {
    try {
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        file.absolute.path,
        quality: 80,
      );

      return result;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImage(File file, String uploadUrl) async {
    try {
     // String fileExtension = path.extension(file.path).toLowerCase();
      // Check the file extension
      if (!file.path.toLowerCase().endsWith('.png')) {
        return null;
      }
      http.MultipartRequest request = http.MultipartRequest('PUT', Uri.parse(uploadUrl));
      request.headers['Authorization'] = "Bearer ${StorageHelper.getToken}";
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      http.StreamedResponse response = await request.send();
      if ([200, 201].contains(response.statusCode)) {
        return response.reasonPhrase;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
