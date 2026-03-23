import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/data/data.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_strings.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/client_edit_profile.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../common_modules/auth/register/models/client_register_response_model.dart';
import '../../client_home_premium/controllers/client_home_premium_controller.dart';
import '../model/bank_card_model.dart';
import '../model/client_bank_update_model.dart';
import '../model/client_business_update_model.dart';
import '../model/client_profile_update.dart';

class ClientEditProfileController extends GetxController {
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

RxBool isButtonVisible=true.obs;
  // State variables
  RxBool isClientNameValid = false.obs;
  RxString profilePicUrl = ''.obs;
  RxBool isClientCountryValid = false.obs;
  RxInt currentStep = 0.obs; // Track current step
  RxInt profileCompleted = 71.obs; // Track current step
  RxString initialCountryCode = 'BD'.obs;
  RxString initialDialCode = '+880'.obs;
  RxBool isAddiEmailValid = false.obs;
  // Move to the next form step
  void nextStep() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    _getUserDetails();
    // });
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void prevStep() async {
    if (currentStep.value > 0) {
      currentStep.value--;
      // WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getUserDetails();
      // });
    }
  }

  @override
  void onReady() {
    super.onReady();
    // _getUserDetails();
    // Get.forceAppUpdate(); // Forces an app-wide UI refresh after loading details
    log("am ready");
  }

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
  // Observable list of cards
  RxList<Map<String, String>> cards = <Map<String, String>>[].obs;
  // Observable to control form visibility
  RxBool showForm = true.obs;

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
    profileFormKeyClient = null;
    businessFormKeyClient = null;
    bankFormKeyClient = null;
    super.onClose();
  }

  //older codes
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  TextEditingController tecRestaurantAddress = TextEditingController();

  //  GlobalKey<FormState> profileFormKeyClient = GlobalKey<FormState>();
  //  GlobalKey<FormState> businessFormKeyClient = GlobalKey<FormState>();
  //  GlobalKey<FormState> bankFormKeyClient = GlobalKey<FormState>();
  GlobalKey<FormState>? profileFormKeyClient;
  GlobalKey<FormState>? businessFormKeyClient;
  GlobalKey<FormState>? bankFormKeyClient;
  Country selectedClientCountry =
      countries.where((element) => element.code == "GB").first;

  RxString restaurantAddressFromMap = "".obs;
  double restaurantLat = 0;
  double restaurantLong = 0;

  var sourceOfFunds = ''.obs;
  RxBool loading = false.obs;

  late BankCardModel bankCardModel;

  @override
  void onInit() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    _getUserDetails(); // Fetch user details and populate fields
    // Get.forceAppUpdate(); // Forces an app-wide UI refresh after loading details
   
    // });
     profileFormKeyClient = GlobalKey<FormState>();
    super.onInit();
  }

  void switchFormKey(int step) {
    // Dispose or replace the keys based on the active step
    profileFormKeyClient = step == 0 ? GlobalKey<FormState>() : null;
    businessFormKeyClient = step == 2 ? GlobalKey<FormState>() : null;
    bankFormKeyClient = step == 3 ? GlobalKey<FormState>() : null;
  }

// Fetch user details from API and populate the fields
  Future<void> _getUserDetails() async {
   
    final clientHomeController = Get.find<ClientHomePremiumController>();
    clientHomeController.getPublicClientDetails();
    clientHomeController.getProfileCompletion(appController.user.value.userId);
    log("getting details..");
    try {
       isButtonVisible.value=false;
      loading.value = true;
      //  log("Starting API call to get user details...");

      // API call to get user details
      Either<CustomError, ClientEditProfileModel> response = await _apiHelper
          .clientDetails(appController.user.value.client?.id ?? "");
      response.fold(
        (error) {
          // Handle the error case
          loading.value = false;
           isButtonVisible.value=true;
        },
        (clientProfile) async {
          // Handle the success case where clientProfile is non-null
          if (clientProfile.details == null) {
            loading.value = false;
             isButtonVisible.value=true;
            return;
          }

          UserDetails details = clientProfile.details!;

          // Populate form fields with API data
          tecClientName.text = details.restaurantName ?? '';
          tecRestaurantAddress.text = details.restaurantAddress ?? '';
          // tecPhoneNumber.text =
          //     details.phoneNumber != null ? '${details.phoneNumber}' : '';
          log("phn num get from db: ${details.phoneNumber}");
          Map<String, String>? result =
              Data.getCountryAndMainNumber(details.phoneNumber!.startsWith('+')? "${details.phoneNumber}": "+${details.phoneNumber}");
          if (result != null) {
            tecPhoneNumber.text = result['mainNumber'] ?? '';
            initialCountryCode.value = result['isoCode'] ?? '';
            initialDialCode.value=result['dialCode'] ??'';
          }
          log("phn: ${tecPhoneNumber.text}");

          log("result: ${result}");

          tecEmailAddress.text = details.email ?? '';
          tecBankName.text =
              details.bankName != null ? ' ${details.bankName}' : '';
          tecAccountNumber.text = details.accountNumber ?? '';
          tecShortCode.text = details.routingNumber ?? '';
          //business form
          log("test- ${details.routingNumber}");
          companyName.text = details.companyName ??
              ''; // Uncomment if companyName field exists
          clientCountry.value = details.countryName ??
              ''; // Uncomment if companyName field exists
          tecVatNumber.text =
              details.vatNumber ?? ''; // Adjust based on your data
          tecCompanyRegistration.text =
              details.companyRegisterNumber ?? ''; // Adjust if available in API

          tecAdditionalEmailAddress.text = details.additionalEmailAddress ?? '';
          isAddiEmailValid.value = details.additionalEmailAddress != null &&
              RegExp(r'^[^@]+@[^@]+\.[^@]+')
                  .hasMatch(details.additionalEmailAddress!);

          tecEmergencyContactNumber.text = details.emergencyContactNumber ?? '';
          log("additional email: ${details.additionalEmailAddress}");
          log("emergency contact: ${details.emergencyContactNumber}");
          // bank details

          tecBankName.text = details.bankName ?? '';
          tecAccountNumber.text = details.accountNumber ?? '';
          tecShortCode.text = details.routingNumber ?? '';
          // tecAdditionalOne.text = details.additionalOne ?? '';
          // tecAdditionalTwo.text = details.additionalTwo ?? '';

          // Fetch the profile completion percentage from the API
          profileCompleted.value = details.profileCompleted ?? 0;
          log("edit profile completed: ${details.profileCompleted}");
          profilePicUrl.value = details.profilePicture ?? '';
          log("profile img: ${details.profilePicture}");
           isButtonVisible.value=true;
          sourceOfFunds.value = details.sourceOfFunds ?? '';
          convertCardInfo(sourceOfFund: details.sourceOfFunds ?? "");
          loading.value = false;
        },
      );
    } catch (_) {
      loading.value = false;
       isButtonVisible.value=true;
    }
    
  }

  Future<void> getPublicUserDetails() async {
    log("helloooo");
    await _getUserDetails();
  }

  void onClientCountryChange(Country country) {
    clientCountry.value = country.name;
  }

  void onRestaurantAddressPressed() {
    Get.toNamed(Routes.restaurantLocation);
  }

  Future<bool> onProfileUpdatePressed() async {
    Utils.unFocus();
    // Validate form and save its state before proceeding
    if (profileFormKeyClient == null) {
      Utils.showSnackBar(
          message: "Please fill out all required fields", isTrue: false);
      return false;
    }

    // Validate form and save its state if the key is available
    if (profileFormKeyClient?.currentState?.validate() ?? false) {
      profileFormKeyClient?.currentState?.save();
      return await _updateProfileInfo(); // Proceed with API call if the form is valid
    } else {
      // Utils.showSnackBar(
      //   message: "Please fill out all required fields",
      //   isTrue: false,
      // );
      return false;
    }
  }

  Future<bool> onBusinessUpdatePressed() async {
    Utils.unFocus();
    // Validate form and save its state before proceeding
    if (businessFormKeyClient == null) {
      Utils.showSnackBar(
          message: "Please fill out all required fields", isTrue: false);
      return false;
    }
    // Validate form and save its state if the key is available
    if (businessFormKeyClient?.currentState?.validate() ?? false) {
      businessFormKeyClient?.currentState?.save();

      return await _updateBusinessInfo(); // Proceed with API call if the form is valid
    } else {
      Utils.showSnackBar(
        message: "Please fill out all required fields",
        isTrue: false,
      );
      return false;
    }
  }

  Future<bool> onUpdateClientBank() async {
    Utils.unFocus();
    // Validate form and save its state before proceeding
    if (bankFormKeyClient == null) {
      Utils.showSnackBar(
          message: "Please fill out all required fields", isTrue: false);
      return false;
    }
    // Validate form and save its state if the key is available
    if (bankFormKeyClient?.currentState?.validate() ?? false) {
      bankFormKeyClient?.currentState?.save();
      return await updateClientBankDetails(); // Proceed with API call if valid
    } else {
      Utils.showSnackBar(
        message: "Please fill out all required fields",
        isTrue: false,
      );
      return false;
    }
  }

  // Method to update bank details
  Future<bool> updateClientBankDetails() async {
    loading.value = true;
     isButtonVisible.value=false;
    // Collect data from TextEditingController instances
    ClientBankDetailsModel bankDetailsModel = ClientBankDetailsModel(
      id: appController.user.value.client?.id ?? "",
      bankName: tecBankName.text.trim(),
      accountNumber: tecAccountNumber.text.trim(),
      routingNumber: tecShortCode.text.trim(),
      additionalOne: tecAdditionalOne.text.trim(),
      additionalTwo: tecAdditionalTwo.text.trim(),
    );
    log("bankDetailsModel: ${bankDetailsModel.toJson()}");
    bool success =
        false; // Call the API helper method to update client bank details
    Either<CustomError, Response> result =
        await _apiHelper.updateClientBankDetails(
      clientBankDetailsModel: bankDetailsModel,
    );
    log("bankDetails Res: ${result.asRight.body}");
    // Handle the API response
    result.fold(
      (CustomError error) {
        loading.value = false;
        // Handle error, show dialog or snack bar
        Utils.showSnackBar(message: "Error: ${error.msg}", isTrue: false);
        success = false;
      },
      (Response response) {
        loading.value = false;

        // Check response status code and show appropriate messages
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success response
          Utils.showSnackBar(
              message: "Bank details updated successfully!", isTrue: true);
          success = true;
        } else if (response.statusCode == 400) {
          // Bad request response
          Utils.showSnackBar(
              message: "Invalid request. Please check the details you entered.",
              isTrue: false);
          success = false;
        } else if (response.statusCode == 401) {
          // Unauthorized response
          Utils.showSnackBar(
              message: "Unauthorized access. Please log in again.",
              isTrue: false);
          success = false;
        } else if (response.statusCode == 404) {
          // Not found response
          Utils.showSnackBar(
              message:
                  "Bank details not found. Please verify your information.",
              isTrue: false);
          success = false;
        } else if (response.statusCode == 500) {
          // Server error response
          Utils.showSnackBar(
              message: "Server error. Please try again later.", isTrue: false);
          success = false;
        } else {
          // Any other status code
          Utils.showSnackBar(
              message:
                  "An unexpected error occurred (Code: ${response.statusCode}).",
              isTrue: false);
          success = false;
        }
      },
    );
       isButtonVisible.value=true;
    return success;
  }

  Future<bool> _updateProfileInfo() async {
    loading.value = true;
     isButtonVisible.value=false;
    ClientProfileUpdate clientProfileUpdate = ClientProfileUpdate(
      id: appController.user.value.client?.id ?? "",
      restaurantName: tecClientName.text.trim(),
      restaurantAddress: tecRestaurantAddress.text.trim().isEmpty
          ? appController.user.value.client?.restaurantAddress ?? ""
          : tecRestaurantAddress.text.trim(),
      email: tecEmailAddress.text.trim().toLowerCase(),
      phoneNumber: "${initialDialCode.startsWith('+') ? initialDialCode : '+$initialDialCode'}${tecPhoneNumber.text.trim().startsWith('+') ? tecPhoneNumber.text.trim().substring(1) : tecPhoneNumber.text.trim()}",

      // phoneNumber: "${initialDialCode + tecPhoneNumber.text.trim()}",
      lat: restaurantLat == 0
          ? appController.user.value.client?.lat ?? ""
          : restaurantLat.toString(),
      long: restaurantLong == 0
          ? appController.user.value.client?.long ?? ""
          : restaurantLong.toString(),
      countryName: clientCountry.value,
    );
    // Ensure context is not null before using it
    if (context != null) {
      CustomLoader.show(context!);
    }
    log("payload being sent for clinet: ${clientProfileUpdate.toJson}");
    bool success = false;
    await _apiHelper.updateClientProfile2(clientProfileUpdate).then((response) {
      if (context != null) {
        CustomLoader.hide(context!);
      }
      response.fold((CustomError customError) {
        loading.value = false;
        Utils.errorDialog(context!, customError..onRetry);
        success = false;
      }, (ClientRegistrationResponse clientRegistrationResponse) async {
        log("clientRegistrationResponse.statusCode ${clientRegistrationResponse.statusCode}");
        loading.value = false;
        if (clientRegistrationResponse.statusCode == 201 ||
            clientRegistrationResponse.statusCode == 200) {
          // await appController
          //     .updateToken(clientRegistrationResponse.token ?? "");
          // await appController.user.
          log("token: ${clientRegistrationResponse.token}");

          // Get.back();
          Utils.showSnackBar(
              message: MyStrings.profileUpdated.tr, isTrue: true);
          success = true;
           loading.value = false;
           nextStep();
        } else if ((clientRegistrationResponse.errors ?? []).isNotEmpty) {
          loading.value = false;
          _errorDialog(
              MyStrings.invalidInput.tr,
              clientRegistrationResponse.errors?.first.msg ??
                  MyStrings.pleaseCheckInputField.tr);
          success = false;
        } else {
          loading.value = false;
          _errorDialog(MyStrings.somethingWentWrong.tr,
              clientRegistrationResponse.message ?? MyStrings.failedToUpdate);
          success = false;
        }
      });
    });
     await  appController.fetchAndUpdateUserData(appController.user.value.userId);
      isButtonVisible.value=true;
        loading.value = false;
    return success;
  }

  Future<bool> _updateBusinessInfo() async {
    loading.value = true;
     isButtonVisible.value=false;
    ClientBusinessUpdate clientBusinessUpdate = ClientBusinessUpdate(
      id: appController.user.value.client?.id ?? "",
      companyRegisterNumber: tecCompanyRegistration.text.trim(),
      companyName: companyName.text.trim(),
      vatNumber: tecVatNumber.text.trim(),
      emergencyContactNumber: tecEmergencyContactNumber.text.trim(),
      additionalEmailAddress: tecAdditionalEmailAddress.text.trim(),
    );
    // Ensure context is not null before using it
    if (context != null) {
      CustomLoader.show(context!);
    }
    bool success = false;
    //   log("business form payload being sent-> additional email: ${clientBusinessUpdate.additionalEmailAddress}");
    log("business form payload being sent : ${clientBusinessUpdate.toJson()}");
    await _apiHelper
        .updateClientBusiness(clientBusinessUpdate)
        .then((response) {
      // if (context != null) {
      //   CustomLoader.hide(context!);
      // }
      response.fold((CustomError customError) {
        loading.value = false;
        Utils.errorDialog(context!, customError..onRetry);
        success = false;
      }, (ClientRegistrationResponse clientRegistrationResponse) async {
        loading.value = false;
        log("clientRegistrationResponse res : ${clientRegistrationResponse.toJson()}");
        log("clientRegistrationResponse res status: ${clientRegistrationResponse.statusCode}");
        if (clientRegistrationResponse.statusCode == 201 ||
            clientRegistrationResponse.statusCode == 200) {
          // await appController
          //     .updateToken(clientRegistrationResponse.token ?? "");

          // Get.back();
          Utils.showSnackBar(
              message: MyStrings.profileUpdated.tr, isTrue: true);
          success = true;
        } else if ((clientRegistrationResponse.errors ?? []).isNotEmpty) {
          loading.value = false;
          _errorDialog(
              MyStrings.invalidInput.tr,
              clientRegistrationResponse.errors?.first.msg ??
                  MyStrings.pleaseCheckInputField.tr);
          success = false;
        } else {
          loading.value = false;
          _errorDialog(MyStrings.somethingWentWrong.tr,
              clientRegistrationResponse.message ?? MyStrings.failedToUpdate);
          success = false;
        }
      });
    });
     isButtonVisible.value=true;
    return success;
  }

  void _errorDialog(String title, String details) {
    if (context != null) {
      CustomDialogue.information(
        context: context!, // Safe use of context after null check
        title: title,
        description: details,
      );
    } else {
      // Handle the case where context is null, for example by logging an error
    }
  }

  void addCard() => Get.toNamed(Routes.cardAdd, arguments: [
        Get.find<AppController>().user.value.client?.email,
        'clientEditProfile'
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
        CustomLoader.show(Get.context!);
        _apiHelper
            .removeCard()
            .then((Either<CustomError, Response> responseData) {
          CustomLoader.hide(Get.context!);
          responseData.fold((CustomError customError) {
            Utils.errorDialog(Get.context!, customError);
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

  String get getProfilePicture {
    return profilePicUrl.value.contains("google")
        ? profilePicUrl.value
        : profilePicUrl.value.imageUrl;
  }

  void onClientAddressPressed({required String module}) {
    Get.toNamed(Routes.restaurantLocation, arguments: module);
  }
}
