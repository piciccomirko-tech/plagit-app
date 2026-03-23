import 'dart:developer';
import 'package:flutter/services.dart';

import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/utils/google_sign_in.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/enums/social_login.dart';
import 'package:mh/app/enums/user_type.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/new_login_response_model.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/social_login_request_model.dart';
import 'package:mh/app/modules/common_modules/auth/register/models/client_sign_up_request_model.dart';
import 'package:mh/app/modules/common_modules/auth/register/models/employee_sign_up_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../../common/utils/exports.dart';
import '../interface/register_interface.dart';

class RegisterController extends GetxController implements RegisterInterface {
  late SocialLoginRequestModel socialLoginRequestModel;

  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  static const MethodChannel _channel = MethodChannel('facebook_app_events');
  Rx<UserType> userType = UserType.client.obs;

  final GlobalKey<FormState> formKeyClient = GlobalKey<FormState>();

  final PageController pageController = PageController();

  /// getter
  bool get isClientRegistration => userType.value == UserType.client;
  bool get isEmployeeRegistration => userType.value == UserType.employee;
  RxBool termsAndConditionCheck = true.obs;

  /// client information
  TextEditingController tecClientName = TextEditingController();
  TextEditingController tecClientAddress = TextEditingController();
  TextEditingController tecClientEmailAddress = TextEditingController();
  TextEditingController tecClientPhoneNumber = TextEditingController();
  TextEditingController tecClientPassword = TextEditingController();
  TextEditingController tecClientCountry = TextEditingController();

  Country selectedClientWisePhoneNumber =
      countries.where((element) => element.code == "GB").first;
  RxString selectedClientCountry = "United Kingdom".obs;

  RxString restaurantAddressFromMap = "".obs;
  double restaurantLat = 0;
  double restaurantLong = 0;




  // Variables for client validation flags
  RxBool isClientNameValid = true.obs;
  RxBool isClientAddressValid = true.obs;
  RxBool isClientEmailValid = true.obs;
  RxBool isClientPhoneValid = true.obs;
  RxBool isClientCountryValid = true.obs;
  RxBool isClientPasswordValid = true.obs;

  /// Employee
  final GlobalKey<FormState> formKeyEmployee = GlobalKey<FormState>();
  TextEditingController tecEmployeeFirstName = TextEditingController();
  TextEditingController tecEmployeeLastName = TextEditingController();
  TextEditingController tecEmployeeAddress = TextEditingController();
  TextEditingController tecEmployeeEmail = TextEditingController();
  TextEditingController tecEmployeePassword = TextEditingController();

  RxString selectedEmployeeCountry = "United Kingdom".obs;
  RxString selectedPosition = 'Manager'.obs;
  RxString selectedPositionId = '63ea4ee911aef3765b25190d'.obs;
  Employees? employees;

  RxString employeeAddressFromMap = "".obs;
  double employeeLat = 0;
  double employeeLong = 0;

  // validity check by rahat
  RxBool isFirstNameValid = true.obs;
  RxBool isLastNameValid = true.obs;
  RxBool isEmployeeAddressValid = true.obs;
  RxBool isEmailValid = true.obs;
  RxBool isPositionValid = true.obs;
  RxBool isCountryValid = true.obs;
  RxBool isEmployeePasswordValid = true.obs;
  Future<void> logCompleteRegistrationEvent(String email) async {
    // Log the complete_registration event with parameters
    try {
      await _channel.invokeMethod('logEvent', {
        'eventName': 'fb_registration_method',
        'parameters': {
          'registration_method': email,
        },
      });
    }catch(e){
    }
  }

  // Method to validate all fields
  bool validateEmployeeFields() {
    // Validate first name
    if (tecEmployeeFirstName.text.isEmpty) {
      isFirstNameValid.value = false;
    } else {
      isFirstNameValid.value = true;
    }

    // Validate last name
    if (tecEmployeeLastName.text.isEmpty) {
      isLastNameValid.value = false;
    } else {
      isLastNameValid.value = true;
    }

    // Validate email
    if (!GetUtils.isEmail(tecEmployeeEmail.text)) {
      // Check if it's a valid email
      isEmailValid.value = false;
    } else {
      isEmailValid.value = true;
    }

    // Validate position
    if (selectedPosition.value.isEmpty) {
      isPositionValid.value = false;
    } else {
      isPositionValid.value = true;
    }

    // Validate country
    if (selectedEmployeeCountry.value.isEmpty) {
      isCountryValid.value = false;
    } else {
      isCountryValid.value = true;
    }
    // Validate password
    if (tecEmployeePassword.text.isEmpty) {
      isEmployeePasswordValid.value = false;
    } else {
      isEmployeePasswordValid.value = true;
    }
// log("f anme: ${isFirstNameValid}");
// log("last anme: ${isLastNameValid}");
// log("email: ${isEmailValid}");

// log("position: ${isPositionValid}");
// log("emp pass: ${isEmployeePasswordValid}");
// log("country : ${isCountryValid}");
    // Return overall validation result
    return isFirstNameValid.value &&
        isLastNameValid.value &&
        isEmailValid.value &&
        isPositionValid.value &&
        isEmployeePasswordValid.value &&
        isCountryValid.value;
  }

  bool validateClientFields() {
    // Validate restaurant name
    if (tecClientName.text.isEmpty) {
      isClientNameValid.value = false;
    } else {
      isClientNameValid.value = true;
    }

    // Validate restaurant address
    if (tecClientAddress.text.isEmpty) {
      isClientAddressValid.value = false;
    } else {
      isClientAddressValid.value = true;
    }

    // Validate email address
    if (!GetUtils.isEmail(tecClientEmailAddress.text)) {
      isClientEmailValid.value = false;
    } else {
      isClientEmailValid.value = true;
    }

    // Validate phone number
    if (tecClientPhoneNumber.text.isEmpty) {
      isClientPhoneValid.value = false;
    } else {
      isClientPhoneValid.value = true;
    }

    // Validate country selection
    if (selectedClientCountry.value.isEmpty) {
      isClientCountryValid.value = false;
    } else {
      isClientCountryValid.value = true;
    }

    // Validate password
    if (tecClientPassword.text.isEmpty) {
      isClientPasswordValid.value = false;
    } else {
      isClientPasswordValid.value = true;
    }
    // log("name: ${ isClientNameValid.value}");
    // log("address: ${ isClientAddressValid.value}");
    // log("email: ${ isClientEmailValid.value}");
    // log("phone: ${ isClientPhoneValid.value}");
    // log("country: ${ isClientCountryValid.value}");

    // Return overall validation result for client
    return isClientNameValid.value &&
        isClientAddressValid.value &&
        isClientEmailValid.value &&
        isClientPhoneValid.value &&
        isClientCountryValid.value;
  }

  ///----------------Common-------------------------------------------
  @override
  void onPositionChange(String? position) {
    selectedPosition.value = position!;
    isPositionValid.value = position.isNotEmpty ? true : false;
  }

  @override
  void onContinuePressed() {
    Utils.unFocus();

    if (isClientRegistration) {
      if (validateClientFields()) {
        _clientRegisterPressed();
      } else {
        // Utils.showSnackBar(
        //     message: 'Please fill in all required fields', isTrue: false);
      }
    } else if (isEmployeeRegistration) {
      if (validateEmployeeFields()) {
        _employeeRegisterPressed();
      } else {
        // Utils.showSnackBar(
        //     message: 'Please fill in all required fields', isTrue: false);
      }
    }
  }

  @override
  void onLoginPressed() {
    Get.offAllNamed(Routes.login);
  }

  @override
  void onPageChange(int index) {
    onUserTypeClick(UserType.values[index + 1]);
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

  void onClientAddressPressed({required String module}) {
    Get.toNamed(Routes.restaurantLocation, arguments: module);
  }

  void onClientCountryWisePhoneNumberChange(Country phone) {
    selectedClientWisePhoneNumber = phone;
  }

  void _clientRegisterPressed() {
    if (formKeyClient.currentState!.validate()) {
      formKeyClient.currentState!.save();
      if (tecClientPhoneNumber.text.isEmpty) {
        _errorDialog("Warning!", "Please enter your phone number");
      } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(
          selectedClientWisePhoneNumber.dialCode + tecClientPhoneNumber.text)) {
        _errorDialog("Warning!", "Please enter a valid phone number");
      } else if (selectedClientCountry.value.isEmpty) {
        _errorDialog("Warning!", "Please select a country");
      } else if (!termsAndConditionCheck.value) {
        _errorDialog("Warning!", "You must accept our terms and conditions");
      } else {
        _clientRegister();
      }
    }
  }

  void _clientRegister() {
    ClientSignUpRequestModel clientRegistration = ClientSignUpRequestModel(
        restaurantName: tecClientName.text.trim(),
        restaurantAddress: tecClientAddress.text.trim(),
        email: tecClientEmailAddress.text.trim().toLowerCase(),
        phoneNumber: '+' +
            selectedClientWisePhoneNumber.dialCode +
            tecClientPhoneNumber.text.trim(),
        password: tecClientPassword.text.trim(),
        lat: restaurantLat.toString(),
        long: restaurantLong.toString(),
        countryName: selectedClientCountry.value);
    log("paload: ${clientRegistration.toJson()}");
    CustomLoader.show(context!);

    _apiHelper
        .clientRegister(clientRegistration)
        .then((Either<CustomError, NewLoginResponseModel> response) {
      CustomLoader.hide(context!);
      logCompleteRegistrationEvent(
          tecClientEmailAddress.text.trim().toLowerCase());
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _clientRegister);
      }, (NewLoginResponseModel clientRegistrationResponse) async {
        if (clientRegistrationResponse.statusCode == 201) {
          await appController.afterSuccessLogin(clientRegistrationResponse.token?.accessToken ?? "");
          await appController.updateRefreshToken(clientRegistrationResponse.token?.refreshToken ?? "");
        } else if ((clientRegistrationResponse.errors ?? []).isNotEmpty) {
          _errorDialog(
              "Invalid Input",
              clientRegistrationResponse.errors?.first.msg ??
                  "Please check you input field and try again");
        } else {
          _errorDialog("Something  Wrong",
              clientRegistrationResponse.message ?? "Failed to Register");
        }
      });
    });
  }

  ///--------------Employee---------------------------------------

  void onEmployeeCountryChange(String? country) {
    selectedEmployeeCountry.value = country!;
  }

  void _employeeRegisterPressed() {
    if (formKeyEmployee.currentState!.validate()) {
      formKeyEmployee.currentState!.save();
      if (!termsAndConditionCheck.value) {
        _errorDialog("Warning!", "You must accept our terms and condition");
      } else if (selectedPosition.value.isEmpty) {
        isPositionValid.value = false;
        _errorDialog("Warning!", "Please select your position");
      } else if (selectedEmployeeCountry.value.isEmpty) {
        isCountryValid.value = false;
        _errorDialog("Warning!", "Please select a country");
      } else {
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

  Future<void> _employeeRegister() async {
    EmployeeSignUpRequestModel employeeSignUpRequestModel =
        EmployeeSignUpRequestModel(
      firstName: tecEmployeeFirstName.text.trim(),
      lastName: tecEmployeeLastName.text.trim(),
      presentAddress: tecEmployeeAddress.text.trim(),
      email: tecEmployeeEmail.text.trim().toLowerCase(),
      password: tecEmployeePassword.text.trim(),
      lat: employeeLat.toString(),
      long: employeeLong.toString(),
      countryName: selectedEmployeeCountry.value,
      // positionId: Utils.getPositionId(selectedPosition.value),
      positionId: selectedPositionId.value,
    );

    CustomLoader.show(context!);
logCompleteRegistrationEvent(tecEmployeeEmail.text.trim().toLowerCase());
    await _apiHelper
        .employeeRegister(employeeSignUpRequestModel)
        .then((response) {
      CustomLoader.hide(context!);

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _employeeRegister);
      }, (NewLoginResponseModel clientRegistrationResponse) async {
        if (clientRegistrationResponse.statusCode == 201) {
          await appController.afterSuccessLogin(clientRegistrationResponse.token?.accessToken ?? "");
          await appController.updateRefreshToken(clientRegistrationResponse.token?.refreshToken ?? "");
        } else if ((clientRegistrationResponse.errors ?? []).isNotEmpty) {
          _errorDialog(
              "Invalid Input",
              clientRegistrationResponse.errors?.first.msg ??
                  "Please check you input field and try again");
        } else {
          _errorDialog("Something  Wrong",
              clientRegistrationResponse.message ?? "Failed to Register");
        }
      });
    });
  }

  void socialLogin({required SocialLogin type}) async {
    if (type == SocialLogin.google) {
      try {
        GoogleSignInApi.googleSignIn.disconnect();
        final GoogleSignInAccount? userInfo = await GoogleSignInApi.login();
        if (userInfo == null) {
          Utils.showSnackBar(
              message: 'Failed to get info from google', isTrue: false);
        } else {
          socialLoginRequestModel = SocialLoginRequestModel(
              email: userInfo.email,
              name: userInfo.displayName ?? '',
              picture: userInfo.photoUrl ?? '');

          socialRegistration(type: SocialLogin.google);
        }
      } catch (_) {
        Utils.showSnackBar(
            message: MyStrings.somethingWentWrong.tr, isTrue: false);
      }
    } else if (type == SocialLogin.apple) {
      try {
        final AuthorizationCredentialAppleID credential =
            await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ],
        );

        if (credential.email != null) {
          socialLoginRequestModel = SocialLoginRequestModel(
              email: credential.email ?? "",
              name: credential.givenName ?? "",
              picture: "");

          await StorageHelper.setSocialLoginCredentials(
              socialLogin: socialLoginRequestModel);
        } else {
          socialLoginRequestModel = SocialLoginRequestModel(
              email: StorageHelper.getSocialLoginCredentials().email,
              name: StorageHelper.getSocialLoginCredentials().name,
              picture: "");
        }
        socialRegistration(type: SocialLogin.apple);
      } catch (_) {
        Utils.showSnackBar(
            message: MyStrings.somethingWentWrong.tr, isTrue: false);
      }
    }
  }

  void socialRegistration({required SocialLogin type}) {
    if (isClientRegistration) {
      ClientSignUpRequestModel clientRegistration = ClientSignUpRequestModel(
          restaurantName: socialLoginRequestModel.name,
          email: socialLoginRequestModel.email,
          profilePicture: socialLoginRequestModel.picture,
          isSocialAccount: true,
          accountType: type == SocialLogin.google ? "Google" : "Apple");

      CustomLoader.show(context!);

      _apiHelper
          .clientRegister(clientRegistration)
          .then((Either<CustomError, NewLoginResponseModel> response) {
        CustomLoader.hide(context!);

        response.fold((CustomError customError) {
          Utils.errorDialog(context!, customError..onRetry = _clientRegister);
        }, (NewLoginResponseModel clientRegistrationResponse) async {
          if (clientRegistrationResponse.statusCode == 201) {
            await appController.afterSuccessLogin(clientRegistrationResponse.token?.accessToken ?? "");
            await appController.updateRefreshToken(clientRegistrationResponse.token?.refreshToken ?? "");
          } else if ((clientRegistrationResponse.errors ?? []).isNotEmpty) {
            _errorDialog(
                "Invalid Input",
                clientRegistrationResponse.errors?.first.msg ??
                    "Please check you input field and try again");
          } else {
            _errorDialog("Something  Wrong",
                clientRegistrationResponse.message ?? "Failed to Register");
          }
        });
      });
    }
  }
}
