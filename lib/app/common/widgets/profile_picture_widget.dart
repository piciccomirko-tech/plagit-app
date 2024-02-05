import 'dart:io' as i;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePictureWidget extends StatefulWidget {
  final String profilePictureUrl;
  const ProfilePictureWidget({super.key, required this.profilePictureUrl});

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  i.File? pickedImage;
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: showImagePickerBottomSheet,
      child: Stack(
        children: [
          Container(
            width: 150.h,
            height: 150.h,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.5,
                  color: MyColors.c_C6A34F,
                )),
            child: pickedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(130), child: Image.file(pickedImage!, fit: BoxFit.cover))
                : CustomNetworkImage(
                    url: widget.profilePictureUrl,
                    radius: 130,
                  ),
          ),
          Positioned.fill(
              child: Align(alignment: Alignment.bottomCenter, child: Image.asset(MyAssets.intersect, width: 90))),
          Positioned.fill(
              bottom: 5,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(MyAssets.camera, width: 30, height: 30, color: MyColors.white))),
        ],
      ),
    );
  }

  Widget _imageSourceWidget({required String imageSource}) => InkResponse(
        onTap: () => _clickToPickImage(imageSource: imageSource),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageSource == "Camera" ? MyAssets.liveCamera : MyAssets.gallery, height: 30, width: 30),
            SizedBox(height: 10.h),
            Text(imageSource, style: MyColors.l111111_dwhite(context).medium16)
          ],
        ),
      );

  void showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.width * 0.5,
        decoration: BoxDecoration(
            color: MyColors.lightCard(context),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Take a picture from".toUpperCase(), style: MyColors.c_C6A34F.semiBold18),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [_imageSourceWidget(imageSource: "Camera"), _imageSourceWidget(imageSource: "Gallery")],
            ),
          ],
        ),
      ),
    );
  }

  void _clickToPickImage({required String imageSource}) async {
    Get.back();

    final XFile? pickedFile = await ImagePicker().pickImage(
      source: imageSource == "Camera" ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      setState(() {
        pickedImage = i.File(pickedFile.path);
      });
      _cropImage();
    } else {
      Utils.showSnackBar(message: "Failed to take profile picture", isTrue: false);
    }
  }

  Future<void> _cropImage() async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage!.path,
        compressQuality: 100,
        maxWidth: 500,
        maxHeight: 600,
        compressFormat: ImageCompressFormat.png,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: MyColors.c_C6A34F,
            toolbarWidgetColor: Colors.white,
            statusBarColor: MyColors.c_C6A34F,
            backgroundColor: Colors.white,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            rectX: 0,
            rectY: 0,
            rectWidth: 500,
            rectHeight: 600,
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetButtonHidden: false,
          ),
        ],
      );

      if (croppedFile != null) {
        pickedImage = File(croppedFile.path);
        _compressImage();
      } else {
        Utils.showSnackBar(message: "Failed to crop profile image", isTrue: false);
      }
    } catch (_) {}
  }

  Future<void> _compressImage() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String targetPath = '$tempPath/compressed_image.jpg';

      final XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
          pickedImage!.path, targetPath, // Use a different target path for the compressed image
          quality: 100,
          minHeight: 500,
          minWidth: 600);

      if (compressedImage != null) {
        pickedImage = File(compressedImage.path);
        _uploadImage();
      } else {
        Utils.showSnackBar(message: "Failed to compress profile image", isTrue: false);
      }
    } catch (_) {}
  }

  void _uploadImage() async {
    CustomLoader.show(context);
    String? imageUrl = await Utils.uploadProfileImage(imageFile: pickedImage!);
    Get.back();
    if ((imageUrl ?? "").isNotEmpty) {
      Utils.showSnackBar(message: MyStrings.pictureUpdated.tr, isTrue: true);
    } else {
      Utils.showSnackBar(message: "Failed to upload profile picture", isTrue: false);
    }
  }
}
