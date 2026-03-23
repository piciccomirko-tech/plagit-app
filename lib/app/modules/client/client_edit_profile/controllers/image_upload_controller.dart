import 'dart:io';
import 'dart:isolate';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:mh/app/common/widgets/custom_loader.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/local_storage/storage_helper.dart';
import '../../../../common/utils/exports.dart';
import '../../../../repository/api_helper_impl_with_file_upload.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../client_home_premium/controllers/client_home_premium_controller.dart';
import 'client_edit_profile_controller.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfilePictureController extends GetxController {
  var selectedImage = Rxn<File>(); // Observable for the selected image
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 100,);

    if (pickedFile != null) {
      _cropImage(pickedFile);
      // selectedImage.value = File(pickedFile.path);
    }
  }

  // Function to capture an image using the camera
  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera,imageQuality: 100,);

    if (pickedFile != null) {
      _cropImage(pickedFile);
      // selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> _cropImage(pickedImage) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage!.path,
        compressQuality: 100,
        maxWidth: 500,
        maxHeight: 600,
        compressFormat: ImageCompressFormat.png,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: MyStrings.cropImage.tr,
              toolbarColor: MyColors.c_C6A34F,
              toolbarWidgetColor: Colors.white,
              statusBarColor: MyColors.c_C6A34F,
              backgroundColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]),
          IOSUiSettings(
              title: MyStrings.cropImage.tr,
              cancelButtonTitle: MyStrings.cancel.tr,
              doneButtonTitle: MyStrings.done.tr,
              rectX: 0,
              rectY: 0,
              rectWidth: 500,
              rectHeight: 600,
              aspectRatioLockEnabled: true,
              aspectRatioPickerButtonHidden: true,
              resetButtonHidden: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ]),
        ],
      );

      if (croppedFile != null) {
        selectedImage.value  = File(croppedFile.path);
      } else {
        Utils.showSnackBar(
            message: MyStrings.failedToCropProfileImage.tr, isTrue: false);
      }
    } catch (_) {}
  }

  // Function to upload the selected image
  Future<void> uploadProfileImage() async {
    CustomLoader.show(Get.context!);
    if (selectedImage.value == null) {
      Utils.showSnackBar(
          message: "Please select an image first.", isTrue: false);
      // Get.snackbar("Error", "Please select an image first.");
      CustomLoader.hide(Get.context!);
      return;
    }

    // Prepare the data for the API call
    Map<String, dynamic> data = {
      "profilePicture": selectedImage.value!.path, // File path
      "token": StorageHelper.getToken, // Replace with actual token
      "percentReceivePort":
          ReceivePort().sendPort, // Dummy port for progress updates (optional)
      "responseReceivePort":
          ReceivePort().sendPort, // Dummy port for response handling (optional)
    };

    // Call the upload function from the helper class
    dio.Response? response =
        await ApiHelperImplementWithFileUpload.updateProfilePicture(data);

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      CustomLoader.hide(Get.context!);
      // Get.find<ClientEditProfileController>().getPublicUserDetails();
      Utils.showSnackBar(
          message: "Profile image uploaded successfully.", isTrue: true);
      final clientHomeController = Get.find<ClientHomePremiumController>();
      final clientEditProfileController =
          Get.find<ClientEditProfileController>();
      final AppController appController = Get.find();

      final commonSocialFeedController = Get.find<CommonSocialFeedController>();

      commonSocialFeedController.getSocialPost();
      await clientEditProfileController.getPublicUserDetails();
      await clientHomeController.getPublicClientDetails();
      await clientHomeController
          .getProfileCompletion(appController.user.value.userId);

      // Get.snackbar("Success", "Profile image uploaded successfully.");
      selectedImage.value = null;
    } else {
      CustomLoader.hide(Get.context!);
      Utils.showSnackBar(
          message: "Failed to upload profile image.", isTrue: false);
      // Get.snackbar("Error", "Failed to upload profile image.");
    }
  }
}
