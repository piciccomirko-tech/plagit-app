import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/controller/socket_controller.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/utils/google_sign_in.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/enums/social_login.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/login_credentials_model.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/social_login_request_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../../common/utils/exports.dart';
import '../../../../../helpers/responsive_helper.dart';
import '../../../splash/controllers/splash_controller.dart';
import '../interface/login_view_interface.dart';
import '../model/login.dart';
import '../model/new_login_response_model.dart';

class LoginController extends GetxController implements LoginViewInterface {
  BuildContext? context;
  final SocketController socketController = Get.find<SocketController>();

  final ApiHelper _apiHelper = Get.find();
  final AppController _appController = Get.find();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Rx<TextEditingController> tecEmail = TextEditingController().obs;
  Rx<TextEditingController> tecPassword = TextEditingController().obs;

  RxBool rememberMe = false.obs;
  late LoginCredentialsModel savedLoginCredentials;

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void onInit() {
    retrieveLoginCredentials();
    super.onInit();
  }

  @override
  void onReady() {
    analytics.setAnalyticsCollectionEnabled(true);
    super.onReady();
  }

  @override
  void onForgotPasswordPressed() {
    // TODO: implement onForgotPasswordPressed
  }
  bool isValidEmail(String email) {
    // Define a regular expression for basic email format validation
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void onLoginPressed() {
    Utils.unFocus();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isValidEmail(tecEmail.value.text.trim().toLowerCase())) {
        LoginRequestModel loginRequestModel = LoginRequestModel(
            email: tecEmail.value.text.trim().toLowerCase(),
            password: tecPassword.value.text.trim());
        _login(loginRequestModel: loginRequestModel);
        log("payload: ${loginRequestModel}");
      } else {
        LoginRequestModel loginRequestModel = LoginRequestModel(
            userIdNumber: tecEmail.value.text.trim(),
            password: tecPassword.value.text.trim());
        _login(loginRequestModel: loginRequestModel);
        log("payload: ${loginRequestModel.userIdNumber}");
      }
      
    }
  }

  @override
  void onRegisterPressed() {
    Get.offAllNamed(Routes.register);
  }

  Future<void> _login({required LoginRequestModel loginRequestModel}) async {
    CustomLoader.show(context!);
    await _apiHelper
        .login(loginRequestModel)
        .then((Either<CustomError, NewLoginResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        if (customError.errorCode == 401) {
          Utils.showSnackBar(
              message:
                  "Thank you for your registration someone will be in touch with you within 24 hours",
              isTrue: false);
        } else {
          Utils.errorDialog(context!, customError..onRetry);
        }
      }, (NewLoginResponseModel loginResponse) async {
        if (loginResponse.statusCode == 200) {
          _appController.currentUserEmail(loginRequestModel.email!);
          await StorageHelper.setCurrentLoginEmails(email: loginRequestModel.email??'');
          if (rememberMe.value == true) {
            _saveLoginCredentials(login: loginRequestModel);
          }

          _fetchMaintenanceMessage(loginResponse);
        } else if (loginResponse.statusCode == 401) {
          _accountBan();
        } else {
          String errorTitle = "Invalid Information";

          if ((loginResponse.message ?? "").contains("email")) {
            errorTitle = "Invalid Email";
          } else if ((loginResponse.message ?? "").contains("password")) {
            errorTitle = "Wrong Password";
          } else {
            errorTitle = "Something wrong! Please contact to support";
          }

          CustomDialogue.information(
            context: context!,
            title: errorTitle,
            description:
                loginResponse.message ?? "You've provided invalid credentials",
          );
        }
      });
    });
  }

  Future<void> _fetchMaintenanceMessage(NewLoginResponseModel loginResponse) async {
    var result = await _apiHelper.getLaunchingMessage();
    result.fold(
          (failure) {
      },
          (result) {
            if(result.statusCode==200){
              _goToNextRoute(loginResponse.token?.accessToken ?? "",loginResponse.token?.refreshToken ?? "" );
            }else{
              Future.delayed(
                Duration.zero,
                    () {
                  return Get.dialog(
                    WillPopScope(
                      onWillPop: () async {
                        exit(0);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                            height: Get.height * .65,
                            width: Get.height * .4,
                            decoration: BoxDecoration(
                              color: MyColors.lightCard(Get.context!),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 30.h),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: HtmlWidget(buildAsync: false,'${result.message}'),),
                              ),
                                    SizedBox(height: 15.h),
                                    CustomButtons.button(
                                      height: Get.width>600?30.h:50.h,
                                      text: MyStrings.exit.tr,
                                      customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                      fontSize: ResponsiveHelper.isTab(Get.context)?13.sp:18.sp,
                                      onTap: () {
                                        exit(0);
                                      },
                                    ),
                                  ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );
                },
              );
              // showDialog(
              //   context: Get.context!,
              //   barrierDismissible: false, // Prevent closing by tapping outside
              //   builder: (context) => WillPopScope(
              //     onWillPop: () async => false, // Prevent back button dismissal
              //     child: AlertDialog(
              //       title: const Text(""),
              //       content: Text("${result.message}"),
              //       actions: [
              //         TextButton(
              //           onPressed: () {
              //             // Optionally exit the app
              //             Utils.exitApp;
              //           },
              //           child: const Text("Exit"),
              //         ),
              //       ],
              //     ),
              //   ),
              // );
            }
      },
    );
  }

  Future<void> _goToNextRoute(String token, refreshToken) async {
    await _appController.afterSuccessLogin(token);
    await _appController.updateRefreshToken(refreshToken);
    await _fetchSavedPost();
  }

  void _accountBan() {}

  void onRememberMePressed(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> _saveLoginCredentials({required LoginRequestModel login}) async {
    LoginCredentialsModel loginCredentialsModel = LoginCredentialsModel(
        username: login.email!, password: login.password ?? "");

    await StorageHelper.setLoginCredentials(
        loginCredentials: loginCredentialsModel);
  }

  Future<void> retrieveLoginCredentials() async {
    savedLoginCredentials = StorageHelper.getLoginCredentials();
    tecEmail.value.text = savedLoginCredentials.username;
    tecPassword.value.text = savedLoginCredentials.password;
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
          LoginRequestModel loginRequestModel = LoginRequestModel(
              email: userInfo.email,
              isSocialAccount: true,
              accountType: "Google");

          _login(loginRequestModel: loginRequestModel);
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

        if (credential.email != null && credential.givenName != null) {
          SocialLoginRequestModel socialLoginRequestModel =
              SocialLoginRequestModel(
                  email: credential.email ?? 'apple@gmail.com',
                  name: credential.givenName ?? 'Guest',
                  picture: "");

          await StorageHelper.setSocialLoginCredentials(
              socialLogin: socialLoginRequestModel);
        }

        LoginRequestModel loginRequestModel = LoginRequestModel(
            email: credential.email ??
                StorageHelper.getSocialLoginCredentials().email,
            isSocialAccount: true,
            accountType: "Apple");
        _login(loginRequestModel: loginRequestModel);
      } catch (_) {
        Utils.showSnackBar(
            message: MyStrings.somethingWentWrong.tr, isTrue: false);
      }
    }
  }



  Future<void> _fetchSavedPost() async {
    var result = await _apiHelper.getSavedPost();
    result.fold(
          (failure) {
        print("Failed to fetch skills: $failure");
      },
          (skills) {
        savedPostList.clear();
        savedPostList.addAll(skills);
        print('SplashController.fetchSavedPost: ${savedPostList.length}');
      },
    );
  }
}
