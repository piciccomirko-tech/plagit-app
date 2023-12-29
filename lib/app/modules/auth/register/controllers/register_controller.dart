import 'dart:convert';
import 'dart:io' as i;
import 'dart:io';
import 'dart:isolate';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:mh/app/modules/auth/register/models/employee_extra_field_model.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../enums/user_type.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employees_by_id.dart';
import '../../../../models/sources.dart';
import '../../../../repository/api_helper.dart';
import '../../../../repository/api_helper_impl_with_file_upload.dart';
import '../../../../routes/app_pages.dart';
import '../interface/register_interface.dart';
import '../models/client_register.dart';
import '../models/client_register_response.dart';
import '../models/employee_registration.dart';

class RegisterController extends GetxController implements RegisterInterface {
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();

  final AppController appController = Get.find();

  /// user type will change when user click on employee or client
  /// or swipe page
  Rx<UserType> userType = UserType.client.obs;

  final GlobalKey<FormState> formKeyClient = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyEmployee = GlobalKey<FormState>();

  final PageController pageController = PageController();

  /// getter
  bool get isClientRegistration => userType.value == UserType.client;
  bool get isEmployeeRegistration => userType.value == UserType.employee;

  RxBool termsAndConditionCheck = true.obs;

  RxString restaurantAddressFromMap = "".obs;
  double restaurantLat = 0;
  double restaurantLong = 0;

  /// client information
  TextEditingController tecClientName = TextEditingController();
  TextEditingController tecClientAddress = TextEditingController();
  TextEditingController tecClientEmailAddress = TextEditingController();
  TextEditingController tecClientPhoneNumber = TextEditingController();
  TextEditingController tecClientPassword = TextEditingController();
  TextEditingController tecClientConfirmPassword = TextEditingController();
  TextEditingController tecClientCountry = TextEditingController();

  RxString selectedClientCountry = "United Kingdom".obs;

  // fetch sources
  Sources? sources;
  Employees? employees;

  String selectedSource = "";
  String selectedRefer = "Other";

  RxBool loading = true.obs;

  /// file upload percent and title
  RxString uploadTitle = "Creating new account...".obs;

  RxInt uploadPercent = 0.obs;

  /// employee information
  TextEditingController tecEmployeeFirstName = TextEditingController();
  TextEditingController tecEmployeeLastName = TextEditingController();
  // TextEditingController tecEmployeeDob = TextEditingController();
  TextEditingController tecEmployeeEmail = TextEditingController();
  TextEditingController tecEmployeePhone = TextEditingController();

  RxString selectedEmployeeCountry = "United Kingdom".obs;

  // Rx<DateTime> dateOfBirth = DateTime.now().obs;

  // RxString selectedGender = Data.genders.first.name!.obs;

  //RxString selectedPosition = Data.positions.first.name!.obs;
  RxString selectedPosition = ''.obs;

  RxList<File> profileImage = <File>[].obs;
  RxList<File> cv = <File>[].obs;

  // phone number country code
  Country selectedEmployeeWisePhoneNumber = countries.where((element) => element.code == "GB").first;
  Country selectedClientWisePhoneNumber = countries.where((element) => element.code == "GB").first;

  RxBool employeeExtraFieldDataLoading = false.obs;
  RxList<Fields> extraFieldList = <Fields>[].obs;
  String? documentString;

  @override
  void onInit() {
    _fetchSourceAndRefers();
    super.onInit();
  }

  ///----------------Common-------------------------------------------
  @override
  void onPositionChange(String? position) {
    selectedPosition.value = position!;
  }

  @override
  void onContinuePressed() {
    Utils.unFocus();
    if (isClientRegistration) {
      _clientRegisterPressed();
    } else if (isEmployeeRegistration) {
      _employeeRegisterPressed();
    }
  }

  @override
  void onLoginPressed() {
    Get.toNamed(Routes.login);
  }

  @override
  void onPageChange(int index) {
    onUserTypeClick(UserType.values[index + 1]);
  }

  void onSourceChange(String? value) {
    selectedSource = value!;
  }

  void onReferChange(String? value) {
    selectedRefer = value!;
  }

  @override
  void onTermsAndConditionCheck(bool active) {
    termsAndConditionCheck.value = active;
  }

  @override
  void onTermsAndConditionPressed() {
    Get.toNamed(Routes.termsAndCondition);
  }

  @override
  void onUserTypeClick(UserType userType) {
    if (this.userType.value != userType) {
      this.userType.value = userType;

      pageController.jumpToPage(UserType.values.indexOf(userType) - 1);
    }
  }

  ///---------------Client-----------------------------------------
  void onClientCountryChange(String? country) {
    selectedClientCountry.value = country!;
  }

  void onClientAddressPressed() {
    Get.toNamed(Routes.restaurantLocation);
  }

  void onClientCountryWisePhoneNumberChange(Country phone) {
    selectedClientWisePhoneNumber = phone;
  }

  void _clientRegisterPressed() {
    if (formKeyClient.currentState!.validate()) {
      formKeyClient.currentState!.save();

      if (!termsAndConditionCheck.value) {
        _errorDialog("Invalid Input", "you must accept our terms and condition");
      } else {
        _clientRegister();
      }
    }
  }

  Future<void> _clientRegister() async {
    ClientRegistration clientRegistration = ClientRegistration(
        restaurantName: tecClientName.text.trim(),
        restaurantAddress: tecClientAddress.text.trim(),
        email: tecClientEmailAddress.text.trim().toLowerCase(),
        phoneNumber: selectedClientWisePhoneNumber.dialCode + tecClientPhoneNumber.text.trim(),
        sourceId: _getSourceId(),
        referPersonId: _getReferPersonId(),
        password: tecClientPassword.text.trim(),
        lat: restaurantLat.toString(),
        long: restaurantLong.toString(),
        countryName: selectedClientCountry.value);

    CustomLoader.show(context!);

    await _apiHelper.clientRegister(clientRegistration).then((response) {
      CustomLoader.hide(context!);

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _clientRegister);
      }, (ClientRegistrationResponse clientRegistrationResponse) async {
        if (clientRegistrationResponse.statusCode == 201) {
          await appController.afterSuccessRegister(clientRegistrationResponse.token!);
        } else if ((clientRegistrationResponse.errors ?? []).isNotEmpty) {
          _errorDialog("Invalid Input",
              clientRegistrationResponse.errors?.first.msg ?? "Please check you input field and try again");
        } else {
          _errorDialog("Something  Wrong", clientRegistrationResponse.message ?? "Failed to Register");
        }
      });
    });
  }

  /* @override
  void onGenderChange(String? gender) {
    selectedGender.value = gender!;
  }*/

  ///--------------Employee---------------------------------------

  void onEmployeeCountryChange(String? country) {
    selectedEmployeeCountry.value = country!;
    extraFieldList.clear();
    documentString = null;
    _getEmployeeExtraField();
  }

  void onEmployeeCountryWisePhoneNumberChange(Country phone) {
    selectedEmployeeWisePhoneNumber = phone;
  }

  /*void onDatePicked(DateTime dateTime) {
    dateOfBirth.value = dateTime;
    tecEmployeeDob.text = dateTime.toString().split(" ").first.trim();
    dateOfBirth.refresh();
  }*/

  void _employeeRegisterPressed() {
    if (formKeyEmployee.currentState!.validate()) {
      formKeyEmployee.currentState!.save();

      if (cv.isNotEmpty && cv.last.path.split(".").last.toLowerCase() != "pdf") {
        _errorDialog("Invalid Input", "CV must be PDF format");
      } else if (!termsAndConditionCheck.value) {
        _errorDialog("Invalid Input", "you must accept our terms and condition");
      } else if (hasEmptyRequiredLabel() == false) {
        _employeeRegister();
      }
    }
  }

  void _errorDialog(String title, String details) {
    CustomDialogue.information(
      context: context!,
      title: title,
      description: details,
    );
  }

  String _getSourceId() {
    for (Source element in (sources?.sources ?? [])) {
      if (element.name == selectedSource) {
        return element.id;
      }
    }
    return '';
  }

  String _getReferPersonId() {
    if (selectedRefer == "Other") return "";

    for (Employee element in (employees?.users ?? [])) {
      if ("${element.firstName} ${element.lastName} - ${element.userIdNumber}" == selectedRefer) {
        return element.id!;
      }
    }

    return "";
  }

  Future<void> _employeeRegister() async {
    if (extraFieldList.isNotEmpty) {
      List<Map<String, dynamic>> fieldListJson = extraFieldList.map((field) => field.toJson()).toList();
      documentString = jsonEncode(jsonEncode(fieldListJson));
    }
    EmployeeRegistration employeeRegistration = EmployeeRegistration(
        firstName: tecEmployeeFirstName.text.trim(),
        lastName: tecEmployeeLastName.text.trim(),
        email: tecEmployeeEmail.text.trim(),
        phoneNumber: tecEmployeePhone.text.trim(),
        countryName: selectedEmployeeCountry.value,
        positionId: Utils.getPositionId(selectedPosition.value.trim()),
        documents: documentString);

    // update dialogue text

    if (cv.isNotEmpty) {
      uploadTitle.value = "Uploading CV...";
    }
    if (profileImage.isNotEmpty) {
      uploadTitle.value = "Uploading profile image...";
    }
    if (cv.isNotEmpty && profileImage.isNotEmpty) {
      uploadTitle.value = "Uploading CV and profile image...";
    }

    // show dialog
    _showPercentIsolate();

    ReceivePort responseReceivePort = ReceivePort();
    ReceivePort percentReceivePort = ReceivePort();

    responseReceivePort.listen((response) async {
      percentReceivePort.close();
      responseReceivePort.close();

      Get.back(); // hide dialog
      if (response != null) {
        if ([200, 201].contains(response["data"]["statusCode"])) {
          await appController.afterSuccessRegister("");
        } else {
          _errorDialog("Something wrong",
              response["data"]["message"] ?? "Failed to register. Please check you data and try again");
        }
      } else {
        _errorDialog("Server Error", "Failed to register. Please try again");
      }
    });

    percentReceivePort.listen((message) {
      uploadPercent.value = message;
    });

    Map<String, dynamic> data = {
      "basicData": employeeRegistration.toJson,
      "profilePicture": profileImage.isEmpty ? null : profileImage.last.path,
      "cv": cv.isEmpty ? null : cv.last.path,
      "responseReceivePort": responseReceivePort.sendPort,
      "percentReceivePort": percentReceivePort.sendPort,
      "token": "",
    };

    await Isolate.spawn(ApiHelperImplementWithFileUpload.employeeRegister, data);
  }

  Future _showPercentIsolate() {
    return showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator.adaptive(
                backgroundColor: MyColors.c_C6A34F,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        uploadTitle.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Obx(() => Text("${uploadPercent.value}%")),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );
  }

  Future<void> onCvClick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      File file = File(result.files.single.path!);
      int size = await file.length();

      if (size <= 5 * 1024 * 1024) {
        cv
          ..clear()
          ..add(File(result.files.single.path!));
      } else {
        Utils.showSnackBar(message: 'File size must be less than 5MB', isTrue: false);
      }
    } else {
      cv.clear();
    }
  }

  /*Future<void> onProfileImageClick() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      profileImage
        ..clear()
        ..add(File(pickedFile.path));
    } else {
      profileImage.clear();
    }
  }*/

  Widget _imageSourceWidget({required String imageSource}) => InkResponse(
        onTap: () => _clickToPickImage(imageSource: imageSource),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageSource == "Camera" ? MyAssets.liveCamera : MyAssets.gallery, height: 30, width: 30),
            SizedBox(height: 10.h),
            Text(imageSource, style: MyColors.l111111_dwhite(context!).medium16)
          ],
        ),
      );

  void showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.width * 0.5,
        decoration: BoxDecoration(
            color: MyColors.lightCard(context!),
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
      File pickedImage = i.File(pickedFile.path);
      _cropImage(imageFile: pickedImage);
    } else {
      Utils.showSnackBar(message: "Failed to take profile picture", isTrue: false);
    }
  }

  Future<void> _cropImage({required i.File imageFile}) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
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
                CropAspectRatioPreset.ratio16x9,
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
        _compressImage(imageFile: imageFile);
      } else {
        Utils.showSnackBar(message: "Failed to crop profile image", isTrue: false);
      }
    } catch (_) {}
  }

  Future<void> _compressImage({required i.File imageFile}) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String targetPath = '$tempPath/compressed_image.jpg';

      final XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
          imageFile.path, targetPath, // Use a different target path for the compressed image
          quality: 100,
          minHeight: 500,
          minWidth: 600);

      if (compressedImage != null) {
        profileImage
          ..clear()
          ..add(File(imageFile.path));
      } else {
        Utils.showSnackBar(message: "Failed to compress profile image", isTrue: false);
      }
    } catch (_) {}
  }

  Future<void> _fetchSourceAndRefers() async {
    await Future.wait([
      _apiHelper.fetchSources(),
      _apiHelper.getEmployees(isReferred: true),
    ]).then((response) {
      response[0].fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _fetchSourceAndRefers);
      }, (r) {
        sources = r as Sources;
      });

      response[1].fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _fetchSourceAndRefers);
      }, (r) {
        employees = r as Employees;
      });

      loading.value = false;
    });
  }

  Future<void> _getEmployeeExtraField() async {
    employeeExtraFieldDataLoading.value = true;
    Either<CustomError, ExtraFieldModel> responseData =
        await _apiHelper.getEmployeeExtraField(countryName: selectedEmployeeCountry.value.trim());
    employeeExtraFieldDataLoading.value = false;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ExtraFieldModel response) {
      if (response.status == "success" && (response.statusCode == 201 || response.statusCode == 200)) {
        extraFieldList.value = response.extraFieldDetails?.fields ?? [];
      }
    });
  }

  Future<void> uploadExtraFile({required i.File file, required String fileName, required String label}) async {
    String response = await ApiHelperImplementWithFileUpload.uploadExtraFile(file: file, fileName: fileName);
    if (response.isNotEmpty) {
      for (var i in extraFieldList) {
        if (i.label == label) {
          i.value = response;
          return;
        }
      }
    }
  }

  bool hasEmptyRequiredLabel() {
    if (extraFieldList.isEmpty) {
      return false;
    } else {
      for (final Fields field in extraFieldList) {
        final bool required = field.required ?? false;
        final String value = field.value ?? '';

        if (required == true && value.isEmpty) {
          Utils.showSnackBar(message: '${field.placeholder} is required', isTrue: false);
          return true;
        } else {
          continue;
        }
      }
    }
    return false; // No required field with an invalid label found
  }
}
