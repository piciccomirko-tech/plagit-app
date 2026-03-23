import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/modules/employee/employee_edit_profile/controllers/employee_profile_picture_upload_controller.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/data/data.dart';
import '../../../../common/local_storage/storage_helper.dart';
import '../../../../common/utils/logcat.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/values/my_strings.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/dropdown_item.dart';
import '../../../../models/employee_full_details.dart';
import '../../../../models/nationality_model.dart';
import '../../../../repository/api_helper.dart';
import '../../../../repository/api_helper_impl_with_file_upload.dart';
import '../../../../repository/server_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/client_edit_profile/model/bank_card_model.dart';
import '../../../client/client_edit_profile/model/client_bank_update_model.dart';
import '../../employee_home/controllers/employee_home_controller.dart';
import '../models/bio_request_model.dart';
import '../models/candidate_certificate_model.dart';
import '../models/employee_profile_additional_model.dart';
import '../models/employee_profile_update_model.dart';
import '../widgets/bio_widget.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class EmployeeEditProfileController extends GetxController {
  final CandidateProfilePictureController candidateProfilePictureController =
      Get.find<CandidateProfilePictureController>();

  final employeeHomeController = Get.find<EmployeeHomeController>();

  GlobalKey<FormState>? profileFormKeyEmployee;
  GlobalKey<FormState>? bankFormKeyEmployee;
  GlobalKey<FormState>? additionalFormKeyEmployee;
  // State variables
  RxBool isClientNameValid = false.obs;
  RxString profilePicUrl = ''.obs;
  RxBool isClientCountryValid = false.obs;
  RxInt currentStep = 0.obs; // Track current step
  RxInt profileCompleted = 55.obs; // Track current step
  RxString initialCountryCode = 'AE'.obs; 
  RxString initialDialCode = '+971'.obs;
  String formattedDateOfBirth='';
  // Move to the next form step
  void nextStep() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    getDetails();
    if (currentStep.value < 3) {
      currentStep.value++;
    }
    // });
  }

  void prevStep() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    if (currentStep.value > 0) {
      currentStep.value--;
      getDetails();
    }
    // });
  }
  final AppController _appController = Get.find();
  String getProgressMessage() {
    switch (currentStep.value) {
      case 0:
        return '${profileCompleted.value}% completed! All the fields here are mandatory';
      case 1:
        return '${profileCompleted.value}% completed! Adding at least one card is mandatory!';
      case 2:
        return '${profileCompleted.value}% completed! Please complete all the information';
      case 3:
        return '${profileCompleted.value}% completed! All the steps are now done!';
      default:
        return '';
    }
  }

  RxString clientCountry = 'United Arab Emirates'.obs;
  RxString nationality = 'Italian'.obs;
  // Observable list of cards
  RxList<Map<String, String>> cards = <Map<String, String>>[].obs;
  // Observable to control form visibility
  RxBool showForm = true.obs;
  RxBool isFileUploadSuccess = true.obs;
  // Add a new card
  void addCard2(Map<String, String> card) {
    cards.add(card);
    showForm.value = false; // Switch to carousel view after adding a card
  }

  // Delete a card
  void deleteCard(Map<String, String> card) {
    cards.remove(card);
  }

  @override
  void onClose() {
    // Dispose controllers when done
    tecClientName.dispose();
    tecClientAddress.dispose();
    tecPhoneNumber.dispose();
    tecEmailAddress.dispose();
    tecBusinessName.dispose();
    tecBankName.dispose();
    tecAccountNumber.dispose();
    profileFormKeyEmployee = null;
    bankFormKeyEmployee = null;
    additionalFormKeyEmployee = null;
    super.onClose();
  }

  BuildContext? context;
  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  TextEditingController tecFirstName = TextEditingController();
  TextEditingController tecLastName = TextEditingController();
  TextEditingController tecCountry = TextEditingController();
  TextEditingController tecEmail = TextEditingController();
  TextEditingController tecPresentAddress = TextEditingController();
  TextEditingController tecPermanentAddress = TextEditingController();
  TextEditingController tecEmergencyContact = TextEditingController();
  TextEditingController tecBio = TextEditingController();
  TextEditingController employeeExperience = TextEditingController();
  TextEditingController hourlyRate = TextEditingController();
  TextEditingController tecLocation = TextEditingController();
  TextEditingController tecPostCode = TextEditingController();
  TextEditingController tecNationality = TextEditingController();

  // Form input controllers
  final TextEditingController tecClientName = TextEditingController();
  final TextEditingController tecClientAddress = TextEditingController();
  final TextEditingController tecPhoneNumber = TextEditingController();
  final TextEditingController tecEmailAddress = TextEditingController();
  final TextEditingController tecBusinessName = TextEditingController();

  //business
  final TextEditingController companyName = TextEditingController();
  final TextEditingController tecVatNumber = TextEditingController();
  final TextEditingController tecCompanyRegistration = TextEditingController();
  final TextEditingController tecEmergencyContactNumber =
      TextEditingController();
  final TextEditingController tecAdditionalEmailAddress =
      TextEditingController();

  // Bank Form Controllers
  final TextEditingController tecBankName = TextEditingController();
  final TextEditingController tecAccountNumber = TextEditingController();
  final TextEditingController tecShortCode = TextEditingController();
  final TextEditingController tecAdditionalOne = TextEditingController();
  final TextEditingController tecAdditionalTwo = TextEditingController();

  RxString bioErrorText = ''.obs;
  TextEditingController tecDob = TextEditingController();
  RxInt uploadPercent = 0.obs;
  RxString selectedCountry = "United Kingdom".obs;

  Rx<EmployeeFullDetails> employee = EmployeeFullDetails().obs;
  RxBool loading = false.obs;
  RxString rating = ''.obs;
  RxString position = 'Manager'.obs;
  // RxString hourlyRate = ''.obs;
  RxString selectedGender = 'Male'.obs;

  late BankCardModel bankCardModel;

  @override
  void onInit() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    fetchSkills();
    getDetails();

    _getNationalityList();
    // });
    profileFormKeyEmployee = GlobalKey<FormState>();

    super.onInit();
  }

  void switchFormKey(int step) {
    // Dispose or replace the keys based on the active step
    profileFormKeyEmployee = step == 0 ? GlobalKey<FormState>() : null;
    bankFormKeyEmployee = step == 1 ? GlobalKey<FormState>() : null;
    additionalFormKeyEmployee = step == 2 ? GlobalKey<FormState>() : null;
  }

  RxList<Certificate> certificates = <Certificate>[].obs;
  RxList<File> cv = <File>[].obs; // List to hold selected files
  RxString cvUrl = ''.obs; //selected file link (network/local)
  // Position Object holding both name and id
  var positionObj = {'name': 'Manager'.obs, 'id': ''.obs};
  String? getNameByIdFromActivePositions(String id) {
    var matchedPosition = appController.allActivePositions.firstWhere(
      (position) => position.id == id,
      orElse: () => DropdownItem(
          id: '', name: ''), // Return a default empty item instead of null
    );

    // Return the 'name' if it's not empty, otherwise return null
    return matchedPosition.name!.isNotEmpty ? matchedPosition.name : null;
  }

  // Method to add selected files
  void addSelectedFiles(List<File> files) {
    var uuid = Uuid(); // Instantiate UUID generator
    // certificates.clear(); // Clear the previous selection

    for (var file in files) {
      certificates.add(
        Certificate(
            certificateName: file.path.split('/').last,
            attachment: file.path, // Use file path as attachment
            certificateId: "local_certificate_$uuid"),
      );
    }
  }

  // Method to remove a selected certificate
  void removeCertificateFile(String filePath) {
    certificates.removeWhere((cert) => cert.attachment == filePath);
  }

  // Function to add a CV file
  void addCv(File file) {
    cv.clear(); // If you want to allow only one CV at a time, clear the previous CV
    cv.add(file); // Add the new CV file
  }

  // Function to remove a CV file
  void removeCv(File file) {
    cv.remove(file); // Remove the selected CV file from the list
  }

  // RxList<String> skillList = <String>[].obs;
  RxList<String> nationalityList = <String>[].obs;
  RxList<String> languageList = <String>[].obs;
  Rx<String> selectedPositionName = 'Manager'.obs;
  RxList<NationalityDetailsModel> nationalities =
      <NationalityDetailsModel>[].obs;

  // Text Controllers
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();
  final TextEditingController employeeHeightController =
      TextEditingController();
  final TextEditingController employeeHigherEducationController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();

  // List of skills and languages
  // RxList<String> skills = <String>[].obs;
  RxList<String> languages = <String>[].obs;

  // Dropdowns and other fields
  RxString selectedDressSize = 'XL'.obs;

  // List of all available options
  RxList<String> allSkills =
      <String>[].obs; // List of all skills from appController
  RxList<String> allLanguages =
      Data.language.toList().obs; // All languages from Data.language

  // List of selected items (those shown in chips)
  // RxList<String> selectedSkills = <String>[].obs;
  RxList<Map<String, String>> selectedSkills = <Map<String, String>>[].obs;

  RxList<String> selectedLanguages = <String>[].obs;
  RxString uploadTitle = "Uploading...".obs;

  // void onSkillsChange(String? skill) {
  //   skillList.add(skill ?? "");
  //   LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(skillList);
  //   skillList.value = uniqueSet.toList();
  //   skillList.refresh();
  // }

  // void onSkillClearClick({required int index}) {
  //   skillList.removeAt(index);
  //   skillList.refresh();
  // }

// Define skillList to hold id and name as a map
  RxList<Map<String, String>> skillList = <Map<String, String>>[].obs;

// Fetch skills from API and populate `skillList`
  void fetchSkills() async {
    var result = await _apiHelper.getAllSkills();
    result.fold(
      (failure) {
        if (kDebugMode) {
          print("Failed to fetch skills: $failure");
        }
      },
      (skills) {
        // Assuming skills is a list of SkillModel
        skillList.value = skills
            .map((skill) => {
                  'skillId': skill.id,
                  'skillName': skill.name,
                })
            .toList();
      },
    );
  }

// Handle skill selection
  void onSkillsChange(String skillId, String skillName) {
    if (!selectedSkills.any((skill) => skill['skillId'] == skillId)) {
      selectedSkills.add({'skillId': skillId, 'skillName': skillName});
    }
  }

// Remove selected skill
  void onSkillClearClick({required int index}) {
    selectedSkills.removeAt(index);
  }

  Future<void> _getNationalityList() async {
    Either<CustomError, NationalityModel> response =
        await _apiHelper.getNationalities();
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (NationalityModel responseData) {
      if (responseData.status == "success") {
        nationalities.value = responseData.nationalities ?? [];
      }
    });
  }

  void onNationalityChange(String? nationality) {
    nationalityList.add(nationality ?? "");
    LinkedHashSet<String> uniqueSet =
        LinkedHashSet<String>.from((nationalityList));
    nationalityList.value = uniqueSet.toList();
    nationalityList.refresh();
  }

  void onNationalityClearClick({required int index}) {
    nationalityList.removeAt(index);
    nationalityList.refresh();
  }

  void onLanguageChange(String? language) {
    languageList.add(language ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(languageList);
    languageList.value = uniqueSet.toList();
    languageList.refresh();
  }

  void onLanguageClearClick({required int index}) {
    languageList.removeAt(index);
    languageList.refresh();
  }

  void onCountryChange(String? country) {
    selectedCountry.value = country!;
  }

    // Observable variables for button visibility
  var isSaveNextVisible = true.obs;
  var isPreviousVisible = true.obs;
  var isSubmitVisible = false.obs;
  var isButtonVisible = true.obs;

  // Example methods to update visibility
  void updateButtonVisibility(int currentStep, bool apiSuccess) {
    if (currentStep == 0) {
      isPreviousVisible.value = false; // No "Previous" button on the first step
      isSaveNextVisible.value = apiSuccess;
      isSubmitVisible.value = false;
    } else if (currentStep < 3) {
      isPreviousVisible.value = true; // Show "Previous" button on other steps
      isSaveNextVisible.value = apiSuccess;
      isSubmitVisible.value = false;
    } else {
      isPreviousVisible.value = true;
      isSaveNextVisible.value = false;
      isSubmitVisible.value = apiSuccess; // Show "Submit" button on the last step
    }
  }

  Future<bool> onProfileUpdatePressed() async {
    //  _appController.setTokenFromLocal();
    return await _updateEmployeeProfileWithoutFiles();
    
    
  }

  Future<bool> onAdditionalUpdatePressed() async {
    return await _updateEmployeeAdditionalProfile();
  }

  Future<void> removeCertificate(String certificateId) async {
    try {
      if (!certificateId.startsWith('local_certificate_')) {
        // Call the API to remove the certificate
         isButtonVisible.value=false;
        var result = await _apiHelper.deleteCertificate(
          userId: appController
              .user.value.userId, // Replace with the actual user ID
          certificateId: certificateId,
        );

        // Check if the API call was successful
        result.fold(
          (error) {
            // Handle API error (show message, etc.)
            if (kDebugMode) {
              print("Error: ${error.msg}");
            }
            Utils.showSnackBar(
                message: "Fail to remove Certificate", isTrue: false);
            // You can show an alert/snackbar to inform the user
          },
          (response) {
            // Remove the certificate from the local list if successful
            certificates.removeWhere(
                (certificate) => certificate.certificateId == certificateId);
            Utils.showSnackBar(
                message: "Certificate removed successfully", isTrue: true);
            // Optionally, show a success message
            if (kDebugMode) {
              print("Certificate removed successfully");
            }
          },
        );
      } else {
        certificates.removeWhere(
            (certificate) => certificate.certificateId == certificateId);
        Utils.showSnackBar(
            message: "Local Certificate removed from successfully",
            isTrue: true);
      }
    } catch (e) {
      Utils.showSnackBar(message: "Fail to remove Certificate", isTrue: false);
      // Handle unexpected errors
      if (kDebugMode) {
        print("Unexpected error: $e");
      }
    }
     isButtonVisible.value=true;
  }

  Future<bool> _updateEmployeeProfileWithoutFiles() async {
    bool isSuccess = false;
    isButtonVisible.value=false;
    CustomLoader.loading();
    try {
      loading.value = true; // Start loading


       // Prepare the basic data for the employee update
      var employeeUpdateData = EmployeeProfileRequestModel(
        id: appController.user.value.userId,
        firstName: tecFirstName.text.trim(),
        lastName: tecLastName.text.trim(),
 
      dateOfBirth: formattedDateOfBirth,
        email: tecEmail.text.trim(),
        gender: selectedGender.value.trim(),
        hourlyRate: hourlyRate.text.trim(),
        employeeExperience: employeeExperience.text.trim(),
        positionId: positionObj['id']?.value ?? '',
        presentAddress: tecLocation.text.trim(),
        postCode: tecPostCode.text.trim(),
        // "phoneNumber": tecPhoneNumber.text.trim(),
phoneNumber: "${initialDialCode.startsWith('+') ? initialDialCode : '+$initialDialCode'}${tecPhoneNumber.text.trim().startsWith('+') ? tecPhoneNumber.text.trim().substring(1) : tecPhoneNumber.text.trim()}",

        // phoneNumber: "${initialDialCode + tecPhoneNumber.text.trim()}",
        countryName: selectedCountry.value.trim(),
        nationality: tecNationality.text,
      );
 
  if(     (formattedDateOfBirth == null || formattedDateOfBirth.isEmpty)){
     // Prepare the basic data for the employee update
       employeeUpdateData = EmployeeProfileRequestModel(
        id: appController.user.value.userId,
        firstName: tecFirstName.text.trim(),
        lastName: tecLastName.text.trim(),
 
      // dateOfBirth: formattedDateOfBirth ?? '',
        email: tecEmail.text.trim(),
        gender: selectedGender.value.trim(),
        hourlyRate: hourlyRate.text.trim(),
        employeeExperience: employeeExperience.text.trim(),
        positionId: positionObj['id']?.value ?? '',
        presentAddress: tecLocation.text.trim(),
        postCode: tecPostCode.text.trim(),
        // "phoneNumber": tecPhoneNumber.text.trim(),
phoneNumber: "${initialDialCode.startsWith('+') ? initialDialCode : '+$initialDialCode'}${tecPhoneNumber.text.trim().startsWith('+') ? tecPhoneNumber.text.trim().substring(1) : tecPhoneNumber.text.trim()}",

        // phoneNumber: "${initialDialCode + tecPhoneNumber.text.trim()}",
        countryName: selectedCountry.value.trim(),
        nationality: tecNationality.text,
      );
 }
      

      // Create FormData from the map
      // dio.FormData formData = dio.FormData.fromMap(employeeUpdateData);
      log("payload being senttttt: ${employeeUpdateData.toJson()}");
      // Send the request to update the profile
      // var response = await dio.Dio().put(
      //   '${ServerUrls.serverLiveUrlUser}users/app/employee-update/profile', // replace with your actual API endpoint
      //   data: formData,
      //   options: dio.Options(
      //     headers: {
      //       "Authorization": "Bearer ${StorageHelper.getToken}",
      //     },
      //   ),
      // );
      final result = await _apiHelper.updateEmployeeProfile(
        employeeProfileRequestModel: employeeUpdateData,
      );

      log("resposne empl prf: ${result}");
      // Handle the response
      result.fold(
        (error) {
          Utils.showSnackBar(
            message: "Failed to update profile: ${error.msg}",
            isTrue: false,
          );
        },
        (success) async {
          if (success.statusCode == 200 || success.statusCode == 201) {
            // await appController.refreshUserProfile(); // Refresh the user profile

      // Fetch updated user data and update the AppController
     
            Utils.showSnackBar(
              message: "Profile updated successfully",
              isTrue: true,
            );
          } else {
            Utils.showSnackBar(
              message: "Unexpected status code: ${success.statusCode}",
              isTrue: false,
            );
          }
        },
      );
    } catch (e) {
      // Log detailed error information
      if (e is dio.DioError) {
        // log("DioError: ${e.message}");
        // log("DioError response data: ${e.response?.data}");
        // log("DioError status code: ${e.response?.statusCode}");
        // log("url: ${ServerUrls.serverLiveUrlUser}/users/app/employee-update/profile");

        Utils.showSnackBar(
          message:
              "Failed to update profile: ${e.response?.data['message'] ?? e.message}",
          isTrue: false,
        );
      } else {
        log("Error: $e");
        Utils.showSnackBar(
          message: "Error: Failed to update profile. Please try again.",
          isTrue: false,
        );
      }
    } finally {
       await appController.fetchAndUpdateUserData(appController.user.value.userId);
      uploadPercent.value = 0;
      loading.value = false; // Ensure loading stops even if an error occurs
    isButtonVisible.value=true;
    }
    return isSuccess;
  }

  Future<bool> _updateEmployeeAdditionalProfile() async {
    bool isSuccess = false;
     isButtonVisible.value=false;
    CustomLoader.loading();
    try {
      loading.value = true; // Start loading

      EmployeeProfileAdditionalModel employeeProfileAdditionalModel =
          EmployeeProfileAdditionalModel(
        id: appController.user.value.userId ?? '',
        languages: languageList.toList(),
        // skills: selectedSkills
        //     .map((skill) => skill['skillId'])
        //     .whereType<String>()
        //     .toList(),
// Map selectedSkills to include both skillId and skillName in the format you want
        skills: selectedSkills
            .map((skill) => {
                  "skillId": skill['skillId'] ?? '',
                  "skillName": skill['skillName'] ?? ''
                })
            .toList(),
        height: int.tryParse(employeeHeightController.text.trim()),
        dressSize: selectedDressSize.value.trim(),
        emergencyContact: emergencyContactController.text.trim(),
        higherEducation: employeeHigherEducationController.text.trim(),
        bio: bioController.text.trim(),
        currentOrganisation: organizationController.text.trim(),
      );
      log("additional payload being sent: ${employeeProfileAdditionalModel.toJson()}");
      final result = await _apiHelper.updateEmployeeAdditionalDetails(
        employeeProfileAdditionalModel: employeeProfileAdditionalModel,
      );

      result.fold(
        (error) {
          // Handle error and show snackbar with error message
          Utils.showSnackBar(
              message: "Failed to update profile: ${error.msg}", isTrue: false);
        },
        (success) {
          isSuccess = true;
          log("additional result: ${success.body}");
          // Check the status code directly from the response
          if (success.statusCode == 200 || success.statusCode == 201) {
            Utils.showSnackBar(
                message: "Profile updated successfully", isTrue: true);
          } else if (success.statusCode == 400) {
            Utils.showSnackBar(
                message: "Bad request: Please check the entered details.",
                isTrue: false);
          } else if (success.statusCode == 401) {
            Utils.showSnackBar(
                message: "Unauthorized: Please login again.", isTrue: false);
          } else if (success.statusCode == 500) {
            Utils.showSnackBar(
                message: "Server error: Please try again later.",
                isTrue: false);
          } else {
            // Default case for any other status code
            Utils.showSnackBar(
                message:
                    "Unexpected error occurred. Status code: ${success.statusCode}",
                isTrue: false);
          }
        },
      );

//       isSuccess = true;
    } catch (e) {
      isSuccess = false;
      Utils.showSnackBar(
          message: "Error: Failed to update profile. Please try again.",
          isTrue: false);
      // Get.back();
    } finally {
       await appController.fetchAndUpdateUserData(appController.user.value.userId);
      uploadPercent.value = 0;
      loading.value = false; // Ensure loading stops even if an error occurs
    isButtonVisible.value=true;
    }
    return isSuccess;
  }

  void uploadOnlyCvWithIsolate(File cvFile) async {
    ReceivePort percentReceivePort = ReceivePort();

    percentReceivePort.listen((message) {
      if (message == -1) {
        if (kDebugMode) {
          print("CV upload failed.");
        }
      } else {
        if (kDebugMode) {
          print("CV upload progress: $message%");
        }
      }
    });

    Isolate.spawn(uploadCvIsolate, {
      "token": StorageHelper.getToken,
      "cvFile": cvFile,
      "percentSendPort": percentReceivePort.sendPort,
    });
  
  }

  void uploadCvIsolate(Map<String, dynamic> data) {
    ApiHelperImplementWithFileUpload.uploadCvUpdated(
      token: data["token"],
      cvFile: data["cvFile"],
      percentSendPort: data["percentSendPort"],
    );
  }

// void uploadOnlyCertificatesWithIsolate(List<Map<String, dynamic>> certificates) async {
//   ReceivePort percentReceivePort = ReceivePort();

//   percentReceivePort.listen((message) {
//     if (message == -1) {
//       print("Certificate upload failed.");
//     } else {
//       print("Certificates upload progress: $message%");
//     }
//   });

//   Isolate.spawn(uploadCertificatesIsolate, {
//     "token": StorageHelper.getToken,
//     "userId": "user_id_here",
//     "certificates": certificates,
//     "percentSendPort": percentReceivePort.sendPort,
//   });
// }
  Future<bool> updateEmployeeCvAndCertificates() async {
    bool isSuccess = false;
     isButtonVisible.value=false;
    CustomLoader.loading();
    try {
      loading.value = true; // Start loading

      // Prepare the basic data for the employee update
      Map<String, dynamic> employeeUpdateData = {
        "id": appController.user.value.userId,
      };
      // Create FormData from the map
      dio.FormData formData = dio.FormData.fromMap(employeeUpdateData);

      // Add the CV file if it exists
      if (cv.isNotEmpty) {
        File cvFile = cv.last;
        if (cvFile.path.startsWith("http") || cvFile.path.isEmpty) {
        } else {
          final fileExtension = p.extension(cvFile.path).toLowerCase();
          // Determine correct MediaType
          MediaType contentType;
          switch (fileExtension) {
            case '.pdf':
              contentType = MediaType('application', 'pdf');
              break;
            case '.jpg':
            case '.jpeg':
              contentType = MediaType('image', 'jpeg');
              break;
            case '.png':
              contentType = MediaType('image', 'png');
              break;
            default:
              contentType = MediaType('application', 'octet-stream'); // fallback
          }
          formData.files.add(MapEntry(
              "cv",
              await dio.MultipartFile.fromFile(cvFile.path,
                  filename: cvFile.path.split('/').last,
                  contentType: contentType)));
        }
        uploadTitle.value = "Uploading CV...";
      }

      // Add any other selected document files
// Add selected certificate documents
      if (certificates.isNotEmpty) {
        for (var certificate in certificates) {
          if (certificate.attachment != null &&
              certificate.attachment!.startsWith("http")) {
            continue; // Skip remote files
          }
          if (certificate.attachment != null) {
            formData.files.add(
              MapEntry(
                "certificates[]", // Assuming "documents[]" is the correct key for multiple files
                await dio.MultipartFile.fromFile(
                  certificate
                      .attachment!, // Use the attachment (file path) from the Certificate object
                  filename: certificate.certificateName ??
                      'Unknown', // Use the certificate name as the file name
                  contentType: MediaType(
                      'application', 'pdf'), // Assuming the files are PDFs
                ),
              ),
            );

            // Optionally, add certificate name as a separate field if required by your API
            formData.fields.add(MapEntry(
                "certificateName", certificate.certificateName ?? 'Unknown'));
          }
        }
        uploadTitle.value = "Uploading Certificates...";
      }

      // Show progress dialog
      _showPercentIsolate();

      ReceivePort responseReceivePort = ReceivePort();
      ReceivePort percentReceivePort = ReceivePort();

      responseReceivePort.listen((response) async {
        percentReceivePort.close();
        responseReceivePort.close();
        loading.value = false; // Stop loading after operation
        if (response != null && response["data"] != null) {
          if ([200, 201].contains(response["data"]["statusCode"])) {
            isSuccess = true;
            // Get.back();
            Utils.showSnackBar(
                message: "Document updated successfully", isTrue: true);
            //nextStep();
          } else {
            isSuccess = false;
            Get.back();
            Utils.showSnackBar(
                message:
                    "Failed to update documents: ${response["data"]["message"]}",
                isTrue: false);
          }
        } else {
          isSuccess = false;
          Get.back();
          Utils.showSnackBar(
              message: "Server Error: Failed to update profile.",
              isTrue: false);
        }
      });

      percentReceivePort.listen((message) {
        uploadPercent.value = message;
        if (uploadPercent.value == 100 && currentStep.value == 2) {
          Get.back(); // Close dialog once 100% is reached
        }
      });

// Prepare data for the isolate
      Map<String, dynamic> data = {
        "basicData": employeeUpdateData,

        // Path of the CV if selected
        "cv": cv.isNotEmpty ? cv.last.path : null,

        // Convert certificates to a list of maps containing their fields (certificateName and attachment)
        "certificates": certificates.isNotEmpty
            ? certificates
                .map((certificate) => {
                      "certificateName": certificate
                          .certificateName, // Name of the certificate
                      "filePath": certificate
                          .attachment, // Path to the file (attachment)
                    })
                .toList()
            : [], // If no certificates are selected, pass an empty list

        "responseReceivePort": responseReceivePort.sendPort,
        "percentReceivePort": percentReceivePort.sendPort,
        "token": StorageHelper.getToken, // Pass the token if needed
      };

      // Spawn isolate to handle profile update with file uploads
      await Isolate.spawn(
          ApiHelperImplementWithFileUpload.updateEmployeeProfile, data);

      isSuccess = true;
    } catch (e) {
      isSuccess = false;
      Utils.showSnackBar(
          message: "Error: Failed to update profile. Please try again.",
          isTrue: false);
      // Get.back();
    } finally {
       isButtonVisible.value=true;
      uploadPercent.value = 0;
      loading.value = false; // Ensure loading stops even if an error occurs
    }
    return isSuccess;
  }

  Future _showPercentIsolate() {
    if (context == null) {
      return Future.value(); // Exit early if context is null
    }

    return showDialog(
      context: Get.context!,
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

  Future<bool> onUpdateCandidateBank() async {
   
    Utils.unFocus();
    // Validate form and save its state before proceeding
    // if (bankFormKeyEmployee == null) {
    //   Utils.showSnackBar(
    //       message: "Please fill out all required fields", isTrue: false);
    //   return false;
    // }
    // Validate form and save its state if the key is available
    // if (bankFormKeyEmployee?.currentState?.validate() ?? false) {
    //   bankFormKeyEmployee?.currentState?.save();

      return await updateCandidateBankDetails(); // Proceed with API call if the form is valid
    // } else {
    //   Utils.showSnackBar(
    //     message: "Please fill out all required fields",
    //     isTrue: false,
    //   );
    //   return false;
    // }
  }

  // Method to update bank details
  Future<bool> updateCandidateBankDetails() async {
    // CustomLoader.loading();
     isButtonVisible.value=false;
    loading.value = true;
    // Collect data from TextEditingController instances
    ClientBankDetailsModel bankDetailsModel = ClientBankDetailsModel(
      id: appController.user.value.employee?.id ?? "",
      bankName: tecBankName.text.trim(),
      accountNumber: tecAccountNumber.text.trim(),
      routingNumber: tecShortCode.text.trim(),
      // additionalOne: tecAdditionalOne.text.trim(),
      // additionalTwo: tecAdditionalTwo.text.trim(),
      // companyName: companyName.text.trim(),
      // vatNumber: tecVatNumber.text.trim(),
      // companyRegisterNumber: tecCompanyRegistration.text.trim(),
    );
    log("emp bank sending: ${bankDetailsModel.toJson()}");
    bool success =
        false; // Call the API helper method to update client bank details
    Either<CustomError, Response> result =
        await _apiHelper.updateEmployeeBankDetails(
      clientBankDetailsModel: bankDetailsModel,
    );

    // Handle the API response
    result.fold(
      (CustomError error) {
        loading.value = false;
        // CustomLoader.hide(context!);
        // Handle error, show dialog or snack bar
        Utils.showSnackBar(message: "Error: ${error.msg}", isTrue: false);
        success = false;
      },
      (Response response) {
        loading.value = false;
        if (context != null) {
          CustomLoader.hide(context!);
        }
        // Handle success, show success message
        Utils.showSnackBar(
            message: "Bank details updated successfully!", isTrue: true);
        success = true;
      },
    );
     isButtonVisible.value=true;
    return success;
  }

  void getDetails() async {
    isButtonVisible.value=false;
    // employeeHomeController.getPublicEmployeeDetails();
    employeeHomeController
        .getProfileCompletion(appController.user.value.userId);
    log("getting employee details");
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
      tecBio.text = employee.value.details?.bio ?? "";
      tecLastName.text = employee.value.details?.lastName ?? "";
      selectedCountry.value = employee.value.details?.countryName ?? "";
      // tecCountry.text = employee.value.details?.countryName ?? "";
      hourlyRate.text = "${employee.value.details?.contractorHourlyRate?.toStringAsFixed(2)}";
      nationality.value = employee.value.details?.nationality ?? "";
tecDob.text = employee.value.details?.dateOfBirth == null
    ? ""
    : DateFormat('dd/MM/yyyy').format(employee.value.details!.dateOfBirth!);
      // selectedGender.value = employee.value.details?.gender ?? "";
      tecPostCode.text = employee.value.details?.postCode ?? "";
      // Map<String, String>? result = Data.getCountryAndMainNumber(
      //      employee.value.details?.phoneNumber?? '');
      // if (result != null) {
      //   tecPhoneNumber.text = result['mainNumber'] ?? '';
      //   initialCountryCode.value = result['isoCode'] ?? '';
      //   initialDialCode.value = result['dialCode'] ?? '';
      // }
      Map<String, String>? result = Data.getCountryAndMainNumber(
  employee.value.details?.phoneNumber?.startsWith('+') == true
      ? "${employee.value.details!.phoneNumber}"
      : "+${employee.value.details?.phoneNumber}"
);

if (result != null) {
  tecPhoneNumber.text = result['mainNumber'] ?? '';
  initialCountryCode.value = result['isoCode'] ?? '';
  initialDialCode.value = result['dialCode'] ?? '';
}

      tecEmail.text = employee.value.details?.email ?? "";
      tecLocation.text = employee.value.details?.presentAddress ?? "";
      tecPermanentAddress.text = employee.value.details?.permanentAddress ?? "";
      employeeExperience.text =
          employee.value.details?.employeeExperience ?? "";
      tecEmergencyContact.text = employee.value.details?.phoneNumber ?? "";
      profilePicUrl.value = employee.value.details?.profilePicture ?? "";
      tecNationality.text =
          employee.value.details?.nationality ?? 'Bangladeshi';
      log(" retrived nationality: ${employee.value.details?.nationality}");
      selectedGender.value = employee.value.details?.gender ?? 'Male';
      log("gender: ${employee.value.details?.gender}");
      positionObj['name']?.value =
          employee.value.details?.positionName ?? 'Manager';
      positionObj['id']?.value = employee.value.details?.positionId ?? '';
      profileCompleted.value = employee.value.details?.profileCompleted ?? 55;
      rating.value =
          '${employee.value.details?.rating ?? 0.0} (${employee.value.details?.totalRating ?? 0})';
// bank info
      tecBankName.text = employee.value.details?.bankName ?? '';
      tecAccountNumber.text = employee.value.details?.accountNumber ?? '';
      tecShortCode.text = employee.value.details?.routingNumber ?? '';
      tecAdditionalOne.text = employee.value.details?.additionalOne ?? '';
      log("addi 1: ${employee.value.details?.additionalOne}");
      tecAdditionalTwo.text = employee.value.details?.additionalTwo ?? '';
      // additional info
      bioController.text = employee.value.details?.bio ?? '';
      selectedDressSize.value = employee.value.details?.dressSize ?? 'L';
      selectedSkills.value = employee.value.details?.skills
              ?.map((skill) => {
                    'skillId': skill.skillId ?? '', // Use the skill's id
                    'skillName': skill.skillName ??
                        'Manager' // Use the skill's name or a default
                  })
              .toList() ??
          [];
// If employee.value.details?.skills is null, use an empty list log("skill length: ${employee.value.details!.skills.!.toString()} ");
      languageList.value = employee.value.details?.languages
              ?.map((language) => language)
              .toList() ??
          []; // If employee.value?.languages is null, use an empty list
      tecEmergencyContactNumber.text =
          employee.value.details?.emergencyContact ?? '';
      employeeHigherEducationController.text =
          employee.value.details?.higherEducation ?? '';
      bioController.text = employee.value.details?.bio ?? '';
      employeeHeightController.text = employee.value.details?.height == 'null'
          ? ''
          : '${employee.value.details?.height}';
      organizationController.text =
          employee.value.details?.currentOrganisation ?? '';
//certificates
// Assuming `employee.value.details?.certificates` contains the list of certificates from the API response
      cvUrl.value = (employee.value.details?.cv != null &&
              employee.value.details!.cv!.isNotEmpty)
          ? 'https://mh-user-bucket.s3.amazonaws.com/public/users/profile/${employee.value.details?.cv}'
          : '';
      log("Cv name: ${cvUrl.value}");
      certificates.value = [];
      certificates.addAll(
        (employee.value.details?.certificates ?? []).map((cert) {
          // Parse the JSON into a Certificate object and apply the imageUrl extension to the attachment
          Certificate certificate = Certificate.fromJson(cert);

          // Apply the imageUrl extension to the attachment field
          certificate.attachment =
              'https://mh-user-bucket.s3.amazonaws.com/public/users/profile/${certificate.attachment}';
          return certificate;
        }).toList(),
      );
      convertCardInfo(
          sourceOfFund: employee.value.details?.sourceOfFunds ?? "");
    });
     isButtonVisible.value=true;
  }

  void onBioTapped() => Get.bottomSheet(const BioWidget());
  void onUpdateTapped() {
    Get.back();
    CustomLoader.show(context!);
    BioRequestModel bioRequestModel = BioRequestModel(
        id: appController.user.value.employee?.id ?? "", bio: tecBio.text);
    _apiHelper
        .updateEmployeeBio(bioRequestModel: bioRequestModel)
        .then((responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError l) {
        Logcat.msg(l.msg);
      }, (r) {
        if ([200, 201].contains(r.statusCode)) {
          Utils.showSnackBar(
              message: MyStrings.bioHasBeenUpdatedSuccessfully.tr,
              isTrue: true);
        }
      });
    });
  }

  void addCard() => Get.toNamed(Routes.cardAdd, arguments: [
        Get.find<AppController>().user.value.employee?.email,
        'employeeEditProfile'
      ]);

  void convertCardInfo({required String sourceOfFund}) {
    if (sourceOfFund.isNotEmpty) {
      bankCardModel = BankCardModel.fromJson(jsonDecode(sourceOfFund));
    }
  }

  void removeCard() {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.warning.tr,
      msg: "${MyStrings.sureWantTo.tr} ${MyStrings.remove.tr}?",
      confirmButtonText: MyStrings.yes.tr,
      onConfirm: () async {
        Get.back();
        CustomLoader.show(context!);
        _apiHelper
            .removeCard()
            .then((Either<CustomError, Response> responseData) {
          CustomLoader.hide(context!);
          responseData.fold((CustomError customError) {
            Utils.errorDialog(context!, customError);
          }, (response) async {
            if ([200, 201].contains(response.statusCode)) {
              Get.back();
              Utils.showSnackBar(
                  message: MyStrings.cardRemove.tr, isTrue: true);
            } else {
              Utils.showSnackBar(
                  message: MyStrings.somethingWentWrong.tr, isTrue: false);
            }
          });
        });
      },
    );
  }

  String formatString({required String original}) {
    String formatted = '';
    int index = 0;

    for (int i = 0; i < original.length; i++) {
      if (index == 4 || index == 8 || index == 12) {
        formatted += '  ';
      }
      formatted += original[i];
      index++;
    }

    return formatted;
  }

  // Add skill to the selected list if it exists in available skills
  // void addSkill(String skill) {
  //   if (!selectedSkills.contains(skill) && allSkills.contains(skill)) {
  //     selectedSkills.add(skill);
  //   }
  // }

  // void removeSkill(String skill) {
  //   selectedSkills.remove(skill);
  // }
  void addSkill(String skillId, String skillName) {
    // Check if the skill is already selected
    if (!selectedSkills.any((skill) => skill['skillId'] == skillId)) {
      // Add the skill as a map with id and name
      selectedSkills.add({'skillId': skillId, 'skillName': skillName});
    }
  }

  void removeSkill(String skillId) {
    // Remove skill based on its id
    selectedSkills.removeWhere((skill) => skill['skillId'] == skillId);
  }

  // Add language to the selected list if it exists in available languages
  void addLanguage(String language) {
    if (!selectedLanguages.contains(language) &&
        allLanguages.contains(language)) {
      selectedLanguages.add(language);
    }
  }

  void removeLanguage(String language) {
    selectedLanguages.remove(language);
  }

  void onClientAddressPressed({required String module}) {
    Get.toNamed(Routes.restaurantLocation, arguments: module);
  }

  Future<void> uploadEmployeeUpdate({
    required File file,
  }) async {
    loading(true);
    final fileExtension = p.extension(file.path).toLowerCase();
    // Determine correct MediaType
    MediaType contentType;
    switch (fileExtension) {
      case '.pdf':
        contentType = MediaType('application', 'pdf');
        break;
      case '.jpg':
      case '.jpeg':
        contentType = MediaType('image', 'jpeg');
        break;
      case '.png':
        contentType = MediaType('image', 'png');
        break;
      default:
        contentType = MediaType('application', 'octet-stream'); // fallback
    }
    var url = Uri.parse('${ServerUrls.serverLiveUrlUser}users/update-employee');


    var request = http.MultipartRequest('PUT', url)
      ..headers.addAll({
        'Authorization': 'Bearer ${StorageHelper.getToken}',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-BD,en;q=0.9',
        'Origin': 'https://www.plagit.com',
        'Referer': 'https://www.plagit.com/',
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
      })
      ..fields['id'] = appController.user.value.userId
      ..files.add(await http.MultipartFile.fromPath(
        'cv',
        file.path,
        contentType: contentType,
      ));

    var response = await request.send();

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Upload successful');
      }
    } else {
      if (kDebugMode) {
        print('Upload failed with status: ${response.statusCode}');
        print(await response.stream.bytesToString());
      }
    }
    loading(false);
  }
}
