import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/employee/employee_self_profile/models/bio_request_model.dart';
import 'package:mh/app/modules/employee/employee_self_profile/widgets/bio_widget.dart';
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
  TextEditingController tecBio = TextEditingController();
  RxString bioErrorText = ''.obs;
  TextEditingController tecDob = TextEditingController();

  RxString selectedCountry = "United Kingdom".obs;

  Rx<EmployeeFullDetails> employee = EmployeeFullDetails().obs;
  RxBool loading = false.obs;
  RxString rating = ''.obs;

  final GlobalKey<FormState> formKeyBio = GlobalKey<FormState>();

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
      tecBio.text = employee.value.details?.bio ?? "";
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

  void onBioTapped() => Get.bottomSheet(const BioWidget());
  void onUpdateTapped() {
    Get.back();
    CustomLoader.show(context!);
    BioRequestModel bioRequestModel = BioRequestModel(id: appController.user.value.userId, bio: tecBio.text);
    _apiHelper.updateEmployeeBio(bioRequestModel: bioRequestModel).then((responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError l) {
        Logcat.msg(l.msg);
      }, (r) {
        if ([200, 201].contains(r.statusCode)) {
          Utils.showSnackBar(message: "Bio has been updated successfully", isTrue: true);
        }
      });
    });
  }
}
