import 'package:dartz/dartz.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/modules/auth/login/model/login_credentials_model.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../interface/login_view_interface.dart';
import '../model/login.dart';
import '../model/login_response.dart';

class LoginController extends GetxController implements LoginViewInterface {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController _appController = Get.find();

  final formKey = GlobalKey<FormState>();

  Rx<TextEditingController> tecUserId = TextEditingController().obs;
  Rx<TextEditingController> tecPassword = TextEditingController().obs;

  RxBool rememberMe = false.obs;
  late LoginCredentialsModel savedLoginCredentials;

  @override
  void onInit() {
    retrieveLoginCredentials();
    super.onInit();
  }

  @override
  void onForgotPasswordPressed() {
    // TODO: implement onForgotPasswordPressed
  }

  @override
  void onLoginPressed() {
    Utils.unFocus();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      _login();
    }
  }

  @override
  void onRegisterPressed() {
    Get.offAndToNamed(Routes.register);
  }

  Future<void> _login() async {
    Login login = Login(password: tecPassword.value.text.trim());

    if (GetUtils.isEmail(tecUserId.value.text.trim())) {
      login.email = tecUserId.value.text.trim().toLowerCase();
    } else {
      login.userIdNumber = tecUserId.value.text.trim();
    }

    CustomLoader.show(context!);

    await _apiHelper.login(login).then((Either<CustomError, LoginResponse> response) {
      CustomLoader.hide(context!);

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _login);
      }, (LoginResponse loginResponse) {
        if (loginResponse.statusCode == 200) {
          if (rememberMe.value == true) {
            _saveLoginCredentials(login: login);
          }
          _goToNextRoute(loginResponse.token ?? "");
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
            description: loginResponse.message ?? "You provide invalid credential",
          );
        }
      });
    });
  }

  Future<void> _goToNextRoute(String token) async {
    await _appController.afterSuccessLogin(token);
  }

  void _accountBan() {}

  void onRememberMePressed(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> _saveLoginCredentials({required Login login}) async {
    LoginCredentialsModel loginCredentialsModel = LoginCredentialsModel(
        username: login.email != null && login.email != '' ? login.email ?? '' : login.userIdNumber ?? '',
        password: login.password);

    await StorageHelper.setLoginCredentials(loginCredentials: loginCredentialsModel);
  }

  Future<void> retrieveLoginCredentials() async {
    savedLoginCredentials = StorageHelper.getLoginCredentials();
    tecUserId.value.text = savedLoginCredentials.username;
    tecPassword.value.text = savedLoginCredentials.password;
  }
}
