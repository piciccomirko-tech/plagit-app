import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/admin.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../enums/user_type.dart';
import '../../models/client.dart';
import '../../models/commons.dart';
import '../../models/dropdown_item.dart';
import '../../models/employee.dart';
import '../../models/user.dart';
import '../../modules/client/common/shortlist_controller.dart';
import '../../routes/app_pages.dart';
import '../local_storage/storage_helper.dart';
import '../utils/logcat.dart';

class AppController extends GetxService {
  Rx<Commons>? commons = Commons().obs;

  RxList<DropdownItem> allActivePositions = <DropdownItem>[].obs;
  RxList<DropdownItem> skills = <DropdownItem>[].obs;

  // i dont know why MediaQuery.of(context).viewInsets.bottom not work in bottom sheet on this project
  // that's why store MediaQuery.of(context).viewInsets.bottom (basically keyboard height) in a observable variable
  RxDouble bottomPadding = 0.0.obs;

  Rx<User> user = User(
    userType: UserType.guest,
  ).obs;

  void setTokenFromLocal() {
    _updateUserModel();

    if (user.value.isGuest) {
      _updateFCMToken(isLogin: false);
      Get.offAndToNamed(Routes.loginRegisterHints);
    } else {
      _updateFCMToken();
      activeShortlistService();
      Get.offAndToNamed(user.value.userType!.homeRoute);
    }
  }

  void _updateUserModel() {
    if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
      if (!_isTokenExpire()) {
        Client temp = Client.fromJson(JwtDecoder.decode(StorageHelper.getToken));
        if (temp.role == "CLIENT") {
          user.value.userType = UserType.client;
          user.value.client = temp;
        } else if (temp.role == "EMPLOYEE") {
          user.value.userType = UserType.employee;
          user.value.employee = Employee.fromJson(JwtDecoder.decode(StorageHelper.getToken));
        } else if (temp.role == "ADMIN") {
          user.value.userType = UserType.admin;
          user.value.admin = Admin.fromJson(JwtDecoder.decode(StorageHelper.getToken));
        } else {
          user.value.userType = UserType.guest;
        }

        user.refresh();
      } else {
        Logcat.msg("Token Expire");
        Get.offAllNamed(Routes.login);
      }
    } else {
      Logcat.msg("User Token not found in local");
    }
  }

  bool _isTokenExpire() => JwtDecoder.isExpired(StorageHelper.getToken);

  Future<void> afterSuccessRegister({required String email}) async {
    // if (token.isEmpty) {
    //   user.value.userType = UserType.guest;
    //   Get.offAllNamed(Routes.employeeRegisterSuccess);
    //   activeShortlistService();
    //   return;
    // }
    //
    //
    // Client temp = Client.fromJson(JwtDecoder.decode(token));
    //
    // if(temp.role == "CLIENT") {
    //   await updateToken(token);
    //   activeShortlistService();
    // } else {
    //   user.value.userType = UserType.guest;
    // }

    activeShortlistService();
    user.value.userType = UserType.guest;

    Get.offNamed(Routes.employeeRegisterSuccess, arguments: email);
  }

  Future<void> afterSuccessLogin(String token) async {
    await updateToken(token);

    _updateFCMToken();

    if (user.value.userType == null) {
    } else {
      activeShortlistService();
      Get.offAndToNamed(user.value.userType!.homeRoute);
    }
  }

  Future<void> updateToken(String token) async {
    // update token on local
    await StorageHelper.setToken(token);

    // update user model for globally
    _updateUserModel();
  }

  void setCommons(Commons commons) {
    this.commons?.value = commons;
    this.commons?.refresh();

    allActivePositions.value = commons.positions ?? [];
    allActivePositions.refresh();

    skills.value = commons.skills ?? [];
    skills.refresh();
  }

  /// call when
  /// login success - done
  /// register success
  /// after splash - done
  void activeShortlistService() {
    Get.put(ShortlistController());

    if (user.value.isClient) {
      Get.find<ShortlistController>().fetchShortListEmployees();
    }
  }

  Future<void> enterAsGuestMode() async {
    await StorageHelper.setToken("");
    activeShortlistService();
    Get.toNamed(Routes.mhEmployees);
  }

  Future<void> onLogoutClick() async {
    CustomLoader.show(Get.context!);

/*    Get.find<SocketController>().socket?.disconnected;
    Get.find<SocketController>().socket?.dispose();*/

    if (Get.isRegistered<ShortlistController>()) {
      Get.find<ShortlistController>().removeAllSelected();
    }

    await _updateFCMToken(isLogin: false);

    CustomLoader.hide(Get.context!);

    StorageHelper.removeToken;

    user.value = User(userType: UserType.guest);
    user.refresh();

    Get.offAllNamed(Routes.loginRegisterHints);
  }

  bool hasPermission() {
    if (user.value.isGuest) {
      Get.toNamed(Routes.login);
      return false;
    }

    return true;
  }

  Future<void> _updateFCMToken({bool isLogin = true}) async {
    if (Get.isRegistered<ApiHelper>()) {
      await Get.find<ApiHelper>().updateFcmToken(isLogin: isLogin);
    }
  }
}
