import 'dart:io' as i;

import 'package:dartz/dartz.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:mh/app/common/utils/image_handler.dart';
import 'package:mh/app/models/employee_full_details.dart';
import 'package:mh/app/repository/server_urls.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../auth/register/models/client_register_response.dart';
import '../model/client_profile_update.dart';

class ClientSelfProfileController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  TextEditingController tecRestaurantName = TextEditingController();
  TextEditingController tecRestaurantAddress = TextEditingController();
  TextEditingController tecRestaurantPhoneNumber = TextEditingController();
  TextEditingController tecRestaurantEmail = TextEditingController();

  final formKeyClient = GlobalKey<FormState>();

  Country selectedClientCountry = countries.where((element) => element.code == "GB").first;

  RxString restaurantAddressFromMap = "".obs;
  double restaurantLat = 0;
  double restaurantLong = 0;

  Rx<i.File?> pickedImage = Rx<i.File?>(null);
  final ImageHandler imageHandler = ImageHandler();

  Rx<EmployeeFullDetails> employee = EmployeeFullDetails().obs;
  RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getDetails();
  }

  void onClientCountryChange(Country country) {
    selectedClientCountry = country;
  }

  void onRestaurantAddressPressed() {
    Get.toNamed(Routes.restaurantLocation);
  }

  void onUpdatePressed() {
    Utils.unFocus();

    if (formKeyClient.currentState!.validate()) {
      formKeyClient.currentState!.save();

      _updateInfo();
    }
  }

  Future<void> _updateInfo() async {
    ClientProfileUpdate clientProfileUpdate = ClientProfileUpdate(
      id: appController.user.value.userId,
      restaurantName: tecRestaurantName.text.trim(),
      restaurantAddress: tecRestaurantAddress.text.trim().isEmpty
          ? appController.user.value.client?.restaurantAddress ?? ""
          : tecRestaurantAddress.text.trim(),
      email: tecRestaurantEmail.text.trim().toLowerCase(),
      phoneNumber: tecRestaurantPhoneNumber.text.trim(),
      lat: restaurantLat == 0 ? appController.user.value.client?.lat ?? "" : restaurantLat.toString(),
      long: restaurantLong == 0 ? appController.user.value.client?.lat ?? "" : restaurantLong.toString(),
    );

    CustomLoader.show(context!);

    await _apiHelper.updateClientProfile(clientProfileUpdate).then((response) {
      CustomLoader.hide(context!);

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _updateInfo);
      }, (ClientRegistrationResponse clientRegistrationResponse) async {
        if (clientRegistrationResponse.statusCode == 201) {
          await appController.updateToken(clientRegistrationResponse.token!);
          Utils.showSnackBar(message: 'Profile has been updated successfully...', isTrue: true);
        } else if ((clientRegistrationResponse.errors ?? []).isNotEmpty) {
          _errorDialog("Invalid Input",
              clientRegistrationResponse.errors?.first.msg ?? "Please check you input field and try again");
        } else {
          _errorDialog("Something  Wrong", clientRegistrationResponse.message ?? "Failed to Update");
        }
      });
    });
  }

  void _errorDialog(String title, String details) {
    CustomDialogue.information(
      context: context!,
      title: title,
      description: details,
    );
  }

  void handleImageResult(CroppedFile? imageFile) {
    if (imageFile != null) {
      pickedImage.value = i.File(imageFile.path);
      _uploadImage(pickedImage.value!);
    } else {}
  }

  void _uploadImage(i.File imageFile) async {
    CustomLoader.show(context!);
    String? imageUrl =
        await imageHandler.uploadImage(imageFile, '${ServerUrls.serverLiveUrlUser}users/update-profile-image');
    Get.back();
    if (imageUrl != null) {
      _getDetails();
      Utils.showSnackBar(message: "Profile picture has been updated successfully", isTrue: true);
    } else {
      Utils.showSnackBar(message: "Profile picture has been update failed", isTrue: false);
    }
  }

  void showImagePickerBottomSheet(BuildContext context) {
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
              children: [
                InkResponse(
                  onTap: _pickImageFromCamera,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(MyAssets.liveCamera, height: 30, width: 30),
                      SizedBox(height: 10.h),
                      Text('Camera', style: MyColors.l111111_dwhite(context).medium16)
                    ],
                  ),
                ),
                InkResponse(
                  onTap: _pickImageFromGallery,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(MyAssets.gallery, height: 30, width: 30),
                      SizedBox(height: 10.h),
                      Text('Gallery', style: MyColors.l111111_dwhite(context).medium16)
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickImageFromCamera() async {
    Get.back(); // Close the bottom sheet
    CroppedFile? pickedAndCroppedImage = await imageHandler.pickAndCropImage(source: "camera");
    handleImageResult(pickedAndCroppedImage);
  }

  void _pickImageFromGallery() async {
    Get.back(); // Close the bottom sheet

    CroppedFile? pickedAndCroppedImage = await imageHandler.pickAndCropImage(source: "gallery");
    handleImageResult(pickedAndCroppedImage);
  }

  void _getDetails() async {
    loading.value = true;
    Either<CustomError, EmployeeFullDetails> response =
        await _apiHelper.employeeFullDetails(appController.user.value.userId);
    loading.value = false;

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (r) {
      employee.value = r;
      employee.refresh();

      tecRestaurantName.text = employee.value.details?.restaurantName ?? "Name not found";
      tecRestaurantAddress.text = employee.value.details?.restaurantAddress ?? "Address not found";
      tecRestaurantPhoneNumber.text = employee.value.details?.phoneNumber ?? "Phone number not found";
      tecRestaurantEmail.text = employee.value.details?.email ?? "Email not found";
    });
  }
}
