import 'dart:io' as i;
import 'package:dartz/dartz.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mh/app/common/utils/image_handler.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/repository/server_urls.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/employee_full_details.dart';
import '../../../../repository/api_helper.dart';

class EmployeeSelfProfileController extends GetxController {
  BuildContext? context;
  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  final formKeyClient = GlobalKey<FormState>();

  TextEditingController tecFirstName = TextEditingController();
  TextEditingController tecLastName = TextEditingController();
  TextEditingController tecCountry = TextEditingController();
  TextEditingController tecPhoneNumber = TextEditingController();
  TextEditingController tecEmail = TextEditingController();
  TextEditingController tecPresentAddress = TextEditingController();
  TextEditingController tecPermanentAddress = TextEditingController();
  TextEditingController tecEmergencyContact = TextEditingController();
  TextEditingController tecDob = TextEditingController();

  RxString selectedCountry = "United Kingdom".obs;

  Rx<EmployeeFullDetails> employee = EmployeeFullDetails().obs;
  RxBool loading = false.obs;

  RxString rating = ''.obs;

  Rx<i.File?> pickedImage = Rx<i.File?>(null);
  final ImageHandler imageHandler = ImageHandler();

  @override
  void onInit() {
    _getDetails();
    super.onInit();
  }

  void onCountryChange(String? country) {
    selectedCountry.value = country!;
  }

  void onUpdatePressed() {}

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

      tecFirstName.text = employee.value.details?.firstName ?? "";
      tecLastName.text = employee.value.details?.lastName ?? "";
      tecCountry.text = employee.value.details?.countryName ?? "";
      tecDob.text = employee.value.details?.dateOfBirth == null
          ? ""
          : employee.value.details!.dateOfBirth.toString().split(" ").first;
      tecPhoneNumber.text = employee.value.details?.phoneNumber ?? "";
      tecEmail.text = employee.value.details?.email ?? "";
      tecPresentAddress.text = employee.value.details?.presentAddress ?? "";
      tecPermanentAddress.text = employee.value.details?.permanentAddress ?? "";
      tecEmergencyContact.text = employee.value.details?.phoneNumber ?? "";
      rating.value = '${employee.value.details?.rating ?? 0.0} (${employee.value.details?.totalRating ?? 0})';
    });
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
}
