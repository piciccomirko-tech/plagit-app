import 'dart:io' as i;
import 'package:dartz/dartz.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mh/app/common/utils/image_handler.dart';
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

  Future<void> _getDetails() async {
    loading.value = true;

    await _apiHelper
        .employeeFullDetails(appController.user.value.userId)
        .then((Either<CustomError, EmployeeFullDetails> response) {
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
    });
  }

  void handleImageResult(CroppedFile? imageFile) {
    if (imageFile != null) {
      pickedImage.value = i.File(imageFile.path);
      _uploadImage(pickedImage.value!);
    } else {
    }
  }

  void _uploadImage(i.File imageFile) async {
    String? imageUrl = await imageHandler.uploadImage(imageFile, '${ServerUrls.serverLiveUrlUser}users/update-profile-image');
    if (imageUrl != null) {
    } else {
    }
  }

  void showImagePickerBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.width,
        decoration: BoxDecoration(
            color: MyColors.lightCard(context),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take Photo'),
              onTap: () async {
                Get.back(); // Close the bottom sheet

                CroppedFile? pickedAndCroppedImage = await imageHandler.pickAndCropImage(source: "camera");
                handleImageResult(pickedAndCroppedImage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Get.back(); // Close the bottom sheet

                CroppedFile? pickedAndCroppedImage = await imageHandler.pickAndCropImage(source: "gallery");
                handleImageResult(pickedAndCroppedImage);
              },
            ),
          ],
        ),
      ),
    );
  }
}
