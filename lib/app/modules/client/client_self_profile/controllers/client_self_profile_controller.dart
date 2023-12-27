import 'package:dartz/dartz.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:mh/app/models/employee_full_details.dart';
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
