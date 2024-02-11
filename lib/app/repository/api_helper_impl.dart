import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/translations/translations_service.dart';
import 'package:mh/app/models/hourly_rate_model.dart';
import 'package:mh/app/models/nationality_model.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/models/todays_employees_model.dart';
import 'package:mh/app/modules/auth/register/models/employee_extra_field_model.dart';
import 'package:mh/app/modules/calender/models/calender_model.dart';
import 'package:mh/app/modules/calender/models/update_unavailable_date_request_model.dart';
import 'package:mh/app/modules/client/client_dashboard/models/client_update_status_model.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_bank_info_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/position_info_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/update_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_suggested_employees/models/short_list_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/email_input/models/forget_password_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_in_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_out_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_hired_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_location_update_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/booking_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/single_booking_details_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/todays_work_schedule_model.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/models/interested_request_model.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_history_model.dart';
import 'package:mh/app/modules/employee_booked_history_details/models/rejected_date_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/live_chat/models/message_request_model.dart';
import 'package:mh/app/modules/live_chat/models/message_response_model.dart';
import 'package:mh/app/modules/live_chat/models/send_message_request_model.dart';
import 'package:mh/app/modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/notifications/models/notification_update_request_model.dart';
import 'package:mh/app/modules/notifications/models/notification_update_response_model.dart';
import 'package:mh/app/modules/otp/models/otp_check_request_model.dart';
import 'package:mh/app/modules/reset_password/models/reset_password_request_model.dart';
import 'package:mh/app/modules/settings/models/change_password_request_model.dart';
import 'package:mh/app/modules/stripe_payment/models/stripe_request_model.dart';
import 'package:mh/app/modules/stripe_payment/models/stripe_response_model.dart';
import 'package:mh/app/repository/server_urls.dart';

import '../common/controller/app_error_controller.dart';
import '../common/local_storage/storage_helper.dart';
import '../common/utils/exports.dart';
import '../common/utils/type_def.dart';
import '../enums/error_from.dart';
import '../models/all_admins.dart';
import '../models/check_in_out_histories.dart';
import '../models/commons.dart';
import '../models/custom_error.dart';
import '../models/employee_full_details.dart';
import '../models/employees_by_id.dart';
import '../models/lat_long_to_address.dart';
import '../models/requested_employees.dart' as requested_employees;
import '../models/sources.dart';
import '../models/user_info.dart';
import '../modules/auth/login/model/login.dart';
import '../modules/auth/login/model/login_response.dart';
import '../modules/auth/register/models/client_register.dart';
import '../modules/auth/register/models/client_register_response.dart';
import '../modules/auth/register/models/employee_registration.dart';
import '../modules/client/client_dashboard/models/current_hired_employees.dart';
import '../modules/client/client_payment_and_invoice/model/client_invoice_model.dart';
import '../modules/client/client_self_profile/model/client_profile_update.dart';
import '../modules/client/client_shortlisted/models/shortlisted_employees.dart' as short_list_employees;
import '../modules/client/client_terms_condition_for_hire/models/terms_condition_for_hire.dart';
import '../modules/employee/employee_home/models/today_check_in_out_details.dart';
import 'api_error_handel.dart';
import 'api_helper.dart';

class ApiHelperImpl extends GetConnect implements ApiHelper {
  @override
  void onInit() {
    httpClient.baseUrl = ServerUrls.serverLiveUrlUser;
    httpClient.timeout = const Duration(seconds: 120);

    httpClient.addRequestModifier<dynamic>((Request request) {
      Logcat.msg(request.url.toString());
      if (StorageHelper.hasToken) {
        Logcat.msg("Token Attached");
        request.headers['Authorization'] = "Bearer ${StorageHelper.getToken}";
      }
      return request;
    });
  }

  /// basically we need to convert [Response] to model
  /// that's why [Response] must contains a body of Map type
  /// if [Response] is null that means their is NO INTERNET CONNECTION
  ///
  /// [Response] will be null or
  /// [Response] data or type will not match with model field
  /// so we must verify [Response] data is correct format
  ///
  /// way to check correct data t
  ///  1. check null for no internet
  ///  2. check status code is valid or not
  ///  3. finally convert response to model
  Either<CustomError, T> _convert<T>(
    Response? response,
    Function(Map<String, dynamic>) base, {
    bool onlyErrorCheck = false,
  }) {
    try {
      if ((response?.statusText ?? "").contains("SocketException")) {
        AppErrorController.submitAutomaticError(
          errorName: "From: api_helper_imp.dart > _convert",
          description: """
              response: $response
              statusCode: ${response?.statusCode}
              responseStatusText: ${response?.statusText}
            """,
        );

        return left(CustomError(
          errorCode: response?.statusCode ?? 500,
          errorFrom: ErrorFrom.noInternet,
          msg: "No internet connection",
        ));
      } else if (response == null || response.statusCode == null) {
        AppErrorController.submitAutomaticError(
          errorName: "From: api_helper_imp.dart > _convert",
          description: """
              response: $response
              statusCode: ${response?.statusCode}
              responseStatusText: ${response?.statusText}
            """,
        );

        return left(CustomError(
          errorCode: response?.statusCode ?? 500,
          errorFrom: ErrorFrom.server,
          msg: "Server Error",
        ));
      }

      Either<CustomError, Response> hasError = ApiErrorHandle.checkError(response);

      if (hasError.isLeft()) {
        AppErrorController.submitAutomaticError(
          errorName: "From: api_helper_imp.dart > _convert > custom error",
          description: """
              errorCode: ${hasError.asLeft.errorCode}
              errorName: ${hasError.asLeft.errorFrom.name}
              errorMsg: ${hasError.asLeft.msg}
            """,
        );

        return left(hasError.asLeft);
      }

      if (onlyErrorCheck) return right(response as T);

      return right(base(response.body) as T);
    } catch (e, s) {
      Logcat.msg(e.toString());
      Logcat.stack(s);

      AppErrorController.submitAutomaticError(
        errorName: "From: api_helper_imp.dart > _convert > type conversion",
        description: """
              errorCode: 1000
              error: ${e.toString()}
              stack: ${s.toString()}
            """,
      );

      return left(
        CustomError(
          errorCode: 1000,
          errorFrom: ErrorFrom.typeConversion,
          msg: e.toString(),
        ),
      );
    }
  }

  @override
  EitherModel<Commons> commons() async {
    var response = await get("commons");

    if (response.statusCode == null) response = await get("commons");
    if (response.statusCode == null) response = await get("commons");
    if (response.statusCode == null) response = await get("commons");

    return _convert<Commons>(
      response,
      Commons.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<LoginResponse> login(
    Login login,
  ) async {
    Response response = await post("users/login", jsonEncode(login.toJson));

    if (response.statusCode == null) response = await post("users/login", jsonEncode(login.toJson));
    if (response.statusCode == null) response = await post("users/login", jsonEncode(login.toJson));
    if (response.statusCode == null) response = await post("users/login", jsonEncode(login.toJson));

    return _convert<LoginResponse>(
      response,
      LoginResponse.fromJson,
    ).fold((CustomError l) => left(l), (LoginResponse r) => right(r));
  }

  @override
  EitherModel<ClientRegistrationResponse> clientRegister(
    ClientRegistration clientRegistration,
  ) async {
    var response = await post("users/client-register", jsonEncode(clientRegistration.toJson));
    if (response.statusCode == null) await post("users/client-register", jsonEncode(clientRegistration.toJson));
    if (response.statusCode == null) await post("users/client-register", jsonEncode(clientRegistration.toJson));
    if (response.statusCode == null) await post("users/client-register", jsonEncode(clientRegistration.toJson));

    return _convert<ClientRegistrationResponse>(
      response,
      ClientRegistrationResponse.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ClientRegistrationResponse> employeeRegister(EmployeeRegistration employeeRegistration) async {
    var response = await post("users/employee-register", jsonEncode(employeeRegistration.toJson));
    if (response.statusCode == null) {
      response = await post("users/employee-register", jsonEncode(employeeRegistration.toJson));
    }
    if (response.statusCode == null) {
      response = await post("users/employee-register", jsonEncode(employeeRegistration.toJson));
    }
    if (response.statusCode == null) {
      response = await post("users/employee-register", jsonEncode(employeeRegistration.toJson));
    }

    return _convert<ClientRegistrationResponse>(
      response,
      ClientRegistrationResponse.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updateFcmToken({bool isLogin = true}) async {
    String? token;
    String? deviceIdentifier;

    if (isLogin) {
      await FirebaseMessaging.instance.getToken().then((fcmToken) async {
        token = fcmToken;
      });
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo build = await deviceInfo.androidInfo;
      deviceIdentifier = build.id; //UUID for Android
    } else if (Platform.isIOS) {
      IosDeviceInfo data = await deviceInfo.iosInfo;
      deviceIdentifier = data.identifierForVendor; //UUID for iOS
    }

    if (!isLogin || !StorageHelper.hasToken) {
      token = null;
    }

    Map<String, dynamic> data = {
      "uuid": deviceIdentifier ?? "",
      "fcmToken": token ?? "",
      "platform": Platform.isAndroid ? "android" : "ios"
    };

    var response = await put("users/push-notification-update", jsonEncode(data));
    if (response.statusCode == null) response = await put("users/push-notification-update", jsonEncode(data));
    if (response.statusCode == null) response = await put("users/push-notification-update", jsonEncode(data));
    if (response.statusCode == null) response = await put("users/push-notification-update", jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<UserInfo> clientDetails(
    String id,
  ) async {
    String url = "users/$id";
    var response = await get(url);
    if (response.statusCode == null) response = await get("users/$id");
    if (response.statusCode == null) response = await get("users/$id");
    if (response.statusCode == null) response = await get("users/$id");

    return _convert<UserInfo>(
      response,
      UserInfo.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Employees> getEmployees(
      {String? positionId,
      String? employeeExperience,
      String? minTotalHour,
      String? maxTotalHour,
      bool? isReferred,
      String? dressSize,
      String? nationality,
      String? minHeight,
      String? maxHeight,
      String? minHourlyRate,
      String? maxHourlyRate}) async {
    String url = "users/list?";

    if ((positionId ?? "").isNotEmpty) url += "positionId=$positionId";
    if ((employeeExperience ?? "").isNotEmpty) url += "&employeeExperience=$employeeExperience";
    if ((minTotalHour ?? "").isNotEmpty) url += "&minTotalHour=$minTotalHour";
    if ((maxTotalHour ?? "").isNotEmpty) url += "&maxTotalHour=$maxTotalHour";
    if (isReferred ?? false) url += "&isReferPerson=${isReferred!.toApiFormat}";
    if ((dressSize ?? "").isNotEmpty) url += "&dressSize=$dressSize";
    if ((minHeight ?? "").isNotEmpty) url += "&minHeight=$minHeight";
    if ((maxHeight ?? "").isNotEmpty) url += "&maxHeight=$maxHeight";
    if ((minHourlyRate ?? "").isNotEmpty) url += "&minHourlyRate=$minHourlyRate";
    if ((maxHourlyRate ?? "").isNotEmpty) url += "&maxHourlyRate=$maxHourlyRate";
    if ((nationality ?? "").isNotEmpty) url += "&nationality=$nationality";
    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);

    return _convert<Employees>(
      response,
      Employees.fromJson,
    ).fold((CustomError l) => left(l), (Employees r) => right(r));
  }

  @override
  EitherModel<Employees> getAllUsersFromAdmin(
      {String? positionId,
      String? rating,
      String? employeeExperience,
      String? minTotalHour,
      String? maxTotalHour,
      bool? isReferred,
      String? requestType,
      bool? active}) async {
    String url = "users?skipLimit=YES&requestType=$requestType";

    if ((positionId ?? "").isNotEmpty) url += "&positionId=$positionId";
    if ((rating ?? "").isNotEmpty) url += "&rating=$rating";
    if ((employeeExperience ?? "").isNotEmpty) url += "&employeeExperience=$employeeExperience";
    if ((minTotalHour ?? "").isNotEmpty) url += "&minTotalHour=$minTotalHour";
    if ((maxTotalHour ?? "").isNotEmpty) url += "&maxTotalHour=$maxTotalHour";
    if (isReferred ?? false) url += "&isReferPerson=${isReferred!.toApiFormat}";
    if (active ?? false) url += "&active=${active!.toApiFormat}";

    var response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);

    return _convert<Employees>(
      response,
      Employees.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<AllAdmins> getAllAdmins() async {
    String url = "users/mh-employee-list?requestType=ADMIN&skipLimit=YES";
    var response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);

    return _convert<AllAdmins>(
      response,
      AllAdmins.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<TermsConditionForHire> getTermsConditionForHire() async {
    String url =
        "terms-conditions?country=${TranslationsService.languageList.singleWhere((element) => element.languageCode == StorageHelper.getLanguage).countryName}";
    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    return _convert<TermsConditionForHire>(
      response,
      TermsConditionForHire.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<short_list_employees.ShortlistedEmployees> fetchShortlistEmployees() async {
    Response response = await get("short-list");
    if (response.statusCode == null) response = await get("short-list");
    if (response.statusCode == null) response = await get("short-list");
    if (response.statusCode == null) response = await get("short-list");

    return _convert<short_list_employees.ShortlistedEmployees>(
      response,
      short_list_employees.ShortlistedEmployees.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> addToShortlist({required AddToShortListRequestModel addToShortListRequestModel}) async {
    Response response = await post("short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await post("short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<Sources> fetchSources() async {
    var response = await get("sources/list-for-dropdown");
    if (response.statusCode == null) response = await get("sources/list-for-dropdown");
    if (response.statusCode == null) response = await get("sources/list-for-dropdown");
    if (response.statusCode == null) response = await get("sources/list-for-dropdown");

    return _convert<Sources>(
      response,
      Sources.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updateShortlistItem({required UpdateShortListRequestModel updateShortListRequestModel}) async {
    Response response = await put("short-list/update", jsonEncode(updateShortListRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("short-list/update", jsonEncode(updateShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("short-list/update", jsonEncode(updateShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("short-list/update", jsonEncode(updateShortListRequestModel.toJson()));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> deleteFromShortlist(String shortlistId) async {
    var response = await delete("short-list/delete/$shortlistId");
    if (response.statusCode == null) response = await delete("short-list/delete/$shortlistId");
    if (response.statusCode == null) response = await delete("short-list/delete/$shortlistId");
    if (response.statusCode == null) response = await delete("short-list/delete/$shortlistId");

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> hireConfirm(Map<String, dynamic> data) async {
    var response = await post("hired-histories/create", jsonEncode(data));
    if (response.statusCode == null) response = await post("hired-histories/create", jsonEncode(data));
    if (response.statusCode == null) response = await post("hired-histories/create", jsonEncode(data));
    if (response.statusCode == null) response = await post("hired-histories/create", jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> addressToLatLng(String query) async {
    httpClient.baseUrl = "https://nominatim.openstreetmap.org/";
    var response = await get("search?q=$query&format=jsonv2");
    if (response.statusCode == null) response = await get("search?q=$query&format=jsonv2");
    if (response.statusCode == null) response = await get("search?q=$query&format=jsonv2");
    if (response.statusCode == null) response = await get("search?q=$query&format=jsonv2");
    httpClient.baseUrl = ServerUrls.serverLiveUrlUser;

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<LatLngToAddress> latLngToAddress(double lat, double lng) async {
    httpClient.baseUrl = "https://nominatim.openstreetmap.org/";
    var response = await get("reverse?lat=$lat&lon=$lng&format=jsonv2");
    if (response.statusCode == null) response = await get("reverse?lat=$lat&lon=$lng&format=jsonv2");
    if (response.statusCode == null) response = await get("reverse?lat=$lat&lon=$lng&format=jsonv2");
    if (response.statusCode == null) response = await get("reverse?lat=$lat&lon=$lng&format=jsonv2");
    httpClient.baseUrl = ServerUrls.serverLiveUrlUser;

    return _convert<LatLngToAddress>(
      response,
      LatLngToAddress.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  Future<void> submitAppError(Map<String, String> data) async {
    var response = await post("app-errors/create", jsonEncode(data));
    if (response.statusCode == null) response = await post("app-errors/create", jsonEncode(data));
  }

  @override
  EitherModel<TodayCheckInOutDetails> dailyCheckInCheckoutDetails(String employeeId) async {
    var response = await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) response = await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) response = await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) response = await get("current-hired-employees/details/$employeeId");

    return _convert<TodayCheckInOutDetails>(
      response,
      TodayCheckInOutDetails.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> checkIn({required EmployeeCheckInRequestModel employeeCheckInRequestModel}) async {
    Response response = await post("current-hired-employees/create", jsonEncode(employeeCheckInRequestModel.toJson()));

    if (response.statusCode == null) {
      response = await post("current-hired-employees/create", jsonEncode(employeeCheckInRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("current-hired-employees/create", jsonEncode(employeeCheckInRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("current-hired-employees/create", jsonEncode(employeeCheckInRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<Response> checkout({required EmployeeCheckOutRequestModel employeeCheckOutRequestModel}) async {
    Response response = await put("current-hired-employees/update", jsonEncode(employeeCheckOutRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("current-hired-employees/update", jsonEncode(employeeCheckOutRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("current-hired-employees/update", jsonEncode(employeeCheckOutRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("current-hired-employees/update", jsonEncode(employeeCheckOutRequestModel.toJson()));
    }
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updateCheckInOutByClient({required ClientUpdateStatusModel clientUpdateStatusModel}) async {
    String url = "current-hired-employees/update-status";
    String requestBody = jsonEncode(clientUpdateStatusModel.toJson());
    Response response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<Response> deleteAccount(Map<String, dynamic> data) async {
    Response response = await put("users/update-status", jsonEncode(data));
    if (response.statusCode == null) response = await put("users/update-status", jsonEncode(data));
    if (response.statusCode == null) response = await put("users/update-status", jsonEncode(data));
    if (response.statusCode == null) response = await put("users/update-status", jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<HiredEmployeesByDate> getHiredEmployeesByDate({String? date}) async {
    String url = "hired-histories/employee-list-for-client";

    if (date != null) url += "?filterDate=$date&utc=${DateTime.now().timeZoneOffset.inHours}";

    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);

    return _convert<HiredEmployeesByDate>(
      response,
      HiredEmployeesByDate.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<TodayCheckInOutDetails> getTodayCheckInOutDetails(String employeeId) async {
    Response response = await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) response = await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) response = await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) response = await get("current-hired-employees/details/$employeeId");
    return _convert<TodayCheckInOutDetails>(
      response,
      TodayCheckInOutDetails.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CheckInCheckOutHistory> getCheckInOutHistory({
    String? filterDate,
    String? requestType,
    String? clientId,
    String? employeeId,
  }) async {
    String url = "check-in-check-out-histories?utc=${DateTime.now().timeZoneOffset.inHours}";

    if ((filterDate ?? "").isNotEmpty) url += "&filterDate=$filterDate";
    if ((requestType ?? "").isNotEmpty) url += "&requestType=$requestType";
    if ((clientId ?? "").isNotEmpty) url += "&clientId=$clientId";
    if ((employeeId ?? "").isNotEmpty) url += "&employeeId=$employeeId";

    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    return _convert<CheckInCheckOutHistory>(
      response,
      CheckInCheckOutHistory.fromJson,
    ).fold((CustomError l) => left(l), (CheckInCheckOutHistory r) => right(r));
  }

  @override
  EitherModel<CheckInCheckOutHistory> getEmployeeCheckInOutHistory(
      {String? startDate, String? endDate, int? page, int? limit}) async {
    String url = "check-in-check-out-histories?employeeId=${Get.find<AppController>().user.value.employee?.id}";
    if ((startDate ?? "").isNotEmpty) url += "&startDate=$startDate";
    if ((endDate ?? "").isNotEmpty) url += "&endDate=$endDate";
    if (page != null) url += "&page=$page";
    if (limit != null) url += "&limit=$limit";
    Response response = await get(url);

    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);

    return _convert<CheckInCheckOutHistory>(
      response,
      CheckInCheckOutHistory.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> clientRequestForEmployee(Map<String, dynamic> data) async {
    var response = await post("request-employees/create", jsonEncode(data));
    if (response.statusCode == null) response = await put("request-employees/create", jsonEncode(data));
    if (response.statusCode == null) response = await put("request-employees/create", jsonEncode(data));
    if (response.statusCode == null) response = await put("request-employees/create", jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<requested_employees.RequestedEmployees> getRequestedEmployees({String? clientId}) async {
    String url = "request-employees?";

    if ((clientId ?? "").isNotEmpty) url += "clientId=$clientId";

    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);

    return _convert<requested_employees.RequestedEmployees>(
      response,
      requested_employees.RequestedEmployees.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> addEmployeeAsSuggest(Map<String, dynamic> data) async {
    Response response = await put("request-employees/update", jsonEncode(data));
    if (response.statusCode == null) response = await put("request-employees/update", jsonEncode(data));
    if (response.statusCode == null) response = await put("request-employees/update", jsonEncode(data));
    if (response.statusCode == null) response = await put("request-employees/update", jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<EmployeeFullDetails> employeeFullDetails(String id) async {
    String url = "users/$id";

    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);

    return _convert<EmployeeFullDetails>(
      response,
      EmployeeFullDetails.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ClientRegistrationResponse> updateClientProfile(ClientProfileUpdate clientProfileUpdate) async {
    Response response = await put("users/update-client", jsonEncode(clientProfileUpdate.toJson));
    if (response.statusCode == null) {
      response = await put("users/update-client", jsonEncode(clientProfileUpdate.toJson));
    }
    if (response.statusCode == null) {
      response = await put("users/update-client", jsonEncode(clientProfileUpdate.toJson));
    }
    if (response.statusCode == null) {
      response = await put("users/update-client", jsonEncode(clientProfileUpdate.toJson));
    }

    return _convert<ClientRegistrationResponse>(
      response,
      ClientRegistrationResponse.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ClientInvoiceModel> getClientInvoice(String clientId) async {
    String url = "invoices?clientId=$clientId";

    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    return _convert<ClientInvoiceModel>(
      response,
      ClientInvoiceModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updatePaymentStatus(Map<String, dynamic> data) async {
    Response response = await put("invoices/update-status", jsonEncode(data));
    if (response.statusCode == null) response = await put("invoices/update-status", jsonEncode(data));
    if (response.statusCode == null) response = await put("invoices/update-status", jsonEncode(data));
    if (response.statusCode == null) response = await put("invoices/update-status", jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<NotificationResponseModel> getNotifications() async {
    String url = "notifications/list";

    Response response = await get(url);
    if (response.statusCode == null) {
      response = await get(url);
    }
    if (response.statusCode == null) {
      response = await get(url);
    }
    if (response.statusCode == null) {
      response = await get(url);
    }
    return _convert<NotificationResponseModel>(
      response,
      NotificationResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (NotificationResponseModel r) => right(r));
  }

  @override
  EitherModel<NotificationUpdateResponseModel> updateNotification(
      {required NotificationUpdateRequestModel notificationUpdateRequestModel}) async {
    Response response = await put("notifications/update-status", jsonEncode(notificationUpdateRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("notifications/update-status", jsonEncode(notificationUpdateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-status", jsonEncode(notificationUpdateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-status", jsonEncode(notificationUpdateRequestModel.toJson()));
    }
    return _convert<NotificationUpdateResponseModel>(
      response,
      NotificationUpdateResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (NotificationUpdateResponseModel r) => right(r));
  }

  @override
  EitherModel<BookingHistoryModel> getBookingHistory() async {
    String url = "notifications/details";

    Response response = await get(url);
    if (response.statusCode == null) {
      response = await get(url);
    }
    if (response.statusCode == null) {
      response = await get(url);
    }
    if (response.statusCode == null) {
      response = await get(url);
    }
    return _convert<BookingHistoryModel>(
      response,
      BookingHistoryModel.fromJson,
    ).fold((CustomError l) => left(l), (BookingHistoryModel r) => right(r));
  }

  @override
  EitherModel<BookingHistoryModel> cancelClientRequestFromAdmin({required String requestId}) async {
    String url = "request-employees/remove/$requestId";

    Response response = await delete(url);
    if (response.statusCode == null) response = await delete(url);
    if (response.statusCode == null) response = await delete(url);
    if (response.statusCode == null) response = await delete(url);

    return _convert<BookingHistoryModel>(
      response,
      BookingHistoryModel.fromJson,
    ).fold((CustomError l) => left(l), (BookingHistoryModel r) => right(r));
  }

  @override
  EitherModel<BookingHistoryModel> cancelEmployeeSuggestionFromAdmin(
      {required String employeeId, required String requestId}) async {
    String url = "request-employees/cancel-suggest/$requestId";

    Response response = await patch(url, jsonEncode({"employeeId": employeeId}));
    if (response.statusCode == null) response = await patch(url, jsonEncode({"employeeId": employeeId}));
    if (response.statusCode == null) response = await patch(url, jsonEncode({"employeeId": employeeId}));
    if (response.statusCode == null) response = await patch(url, jsonEncode({"employeeId": employeeId}));

    return _convert<BookingHistoryModel>(
      response,
      BookingHistoryModel.fromJson,
    ).fold((CustomError l) => left(l), (BookingHistoryModel r) => right(r));
  }

  @override
  EitherModel<StripeResponseModel> stripePayment({required StripeRequestModel stripeRequestModel}) async {
    String url = "payment/create-session";

    Response response = await post(url, jsonEncode(stripeRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(stripeRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(stripeRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(stripeRequestModel.toJson()));

    return _convert<StripeResponseModel>(
      response,
      StripeResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (StripeResponseModel r) => right(r));
  }

  @override
  EitherModel<EmployeePaymentHistory> employeePaymentHistory({required String employeeId}) async {
    String url = "employee-invoices?employeeId=$employeeId";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<EmployeePaymentHistory>(
      response,
      EmployeePaymentHistory.fromJson,
    ).fold((CustomError l) => left(l), (EmployeePaymentHistory r) => right(r));
  }

  @override
  EitherModel<ReviewDialogModel> showReviewDialog() async {
    String url = "review/view-eligible";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<ReviewDialogModel>(
      response,
      ReviewDialogModel.fromJson,
    ).fold((CustomError l) => left(l), (ReviewDialogModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> giveReview({required ReviewRequestModel reviewRequestModel}) async {
    String url = "review/create";

    var response = await post(url, jsonEncode(reviewRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(reviewRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(reviewRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(reviewRequestModel.toJson()));

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> addToShortlistNew({required ShortListRequestModel shortListRequestModel}) async {
    String url = "request-employees/short-list-create";

    var response = await post(url, jsonEncode(shortListRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(shortListRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(shortListRequestModel.toJson()));
    if (response.statusCode == null) await post(url, jsonEncode(shortListRequestModel.toJson()));
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CalenderModel> getCalenderData({required String employeeId}) async {
    String url = "users/working-history/$employeeId";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<CalenderModel>(
      response,
      CalenderModel.fromJson,
    ).fold((CustomError l) => left(l), (CalenderModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> updateUnavailableDate(
      {required UpdateUnavailableDateRequestModel updateUnavailableDateRequestModel}) async {
    String url = "users/update-unavailable-date";

    Response response = await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));
    if (response.statusCode == null) await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));
    if (response.statusCode == null) await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));
    if (response.statusCode == null) await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<TodayWorkScheduleModel> getTodayWorkSchedule() async {
    String url =
        "check-in-check-out-histories/today-work-place?currentDate=${DateTime.now().toString().substring(0, 10)}";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<TodayWorkScheduleModel>(
      response,
      TodayWorkScheduleModel.fromJson,
    ).fold((CustomError l) => left(l), (TodayWorkScheduleModel r) => right(r));
  }

  @override
  EitherModel<EmployeeHiredHistoryModel> getHiredHistory() async {
    String url = "users/hired-history";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<EmployeeHiredHistoryModel>(
      response,
      EmployeeHiredHistoryModel.fromJson,
    ).fold((CustomError l) => left(l), (EmployeeHiredHistoryModel r) => right(r));
  }

  @override
  EitherModel<SingleBookingDetailsModel> getBookingDetails({required String notificationId}) async {
    String url = "notifications/$notificationId";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<SingleBookingDetailsModel>(
      response,
      SingleBookingDetailsModel.fromJson,
    ).fold((CustomError l) => left(l), (SingleBookingDetailsModel r) => right(r));
  }

  @override
  EitherModel<Response> updateRequestDate({required RejectedDateRequestModel rejectedDateRequestModel}) async {
    Response response = await put("notifications/update-request-date", jsonEncode(rejectedDateRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("notifications/update-request-date", jsonEncode(rejectedDateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-request-date", jsonEncode(rejectedDateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-request-date", jsonEncode(rejectedDateRequestModel.toJson()));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ExtraFieldModel> getEmployeeExtraField({required String countryName}) async {
    Response response = await post("document/get-fields", jsonEncode({"country": countryName}));
    if (response.statusCode == null) response = await post("document/get-fields", jsonEncode({"country": countryName}));
    if (response.statusCode == null) response = await post("document/get-fields", jsonEncode({"country": countryName}));
    if (response.statusCode == null) response = await post("document/get-fields", jsonEncode({"country": countryName}));

    return _convert<ExtraFieldModel>(
      response,
      ExtraFieldModel.fromJson,
    ).fold((CustomError l) => left(l), (ExtraFieldModel r) => right(r));
  }

  @override
  EitherModel<NationalityModel> getNationalities() async {
    String url = "commons/nationality";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<NationalityModel>(
      response,
      NationalityModel.fromJson,
    ).fold((CustomError l) => left(l), (NationalityModel r) => right(r));
  }

  @override
  EitherModel<HourlyRateModel> getHourlyRate() async {
    String url = "users/hourly-rate-info";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<HourlyRateModel>(
      response,
      HourlyRateModel.fromJson,
    ).fold((CustomError l) => left(l), (HourlyRateModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> changePassword(
      {required ChangePasswordRequestModel changePasswordRequestModel}) async {
    Response response = await put("users/update-password", jsonEncode(changePasswordRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("users/update-password", jsonEncode(changePasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/update-password", jsonEncode(changePasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/update-password", jsonEncode(changePasswordRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ForgetPasswordResponseModel> inputEmail({required String email}) async {
    Response response = await put("users/forgot-password", jsonEncode({"email": email}));
    if (response.statusCode == null) {
      response = await put("users/forgot-password", jsonEncode({"email": email}));
    }
    if (response.statusCode == null) {
      response = await put("users/forgot-password", jsonEncode({"email": email}));
    }
    if (response.statusCode == null) {
      response = await put("users/forgot-password", jsonEncode({"email": email}));
    }

    return _convert<ForgetPasswordResponseModel>(
      response,
      ForgetPasswordResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> otpCheck({required OtpCheckRequestModel otpCheckRequestModel}) async {
    Response response = await post("users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await post("users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> resetPassword({required ResetPasswordRequestModel resetPasswordRequestModel}) async {
    Response response = await put("users/reset-password", jsonEncode(resetPasswordRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("users/reset-password", jsonEncode(resetPasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/reset-password", jsonEncode(resetPasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/reset-password", jsonEncode(resetPasswordRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<PositionInfoModel> getPositionInfo({required String positionId}) async {
    String url = "positions/$positionId";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<PositionInfoModel>(
      response,
      PositionInfoModel.fromJson,
    ).fold((CustomError l) => left(l), (PositionInfoModel r) => right(r));
  }

  @override
  EitherModel<TodaysEmployeesModel> getTodaysEmployees(
      {required String startDate, required String endDate, String? employeeName, String? restaurantName}) async {
    String url = "book-history?startDate=$startDate&endDate=$endDate&hiredStatus=ALLOW";
    if ((employeeName ?? "").isNotEmpty && employeeName != 'All Employees') url += "&employeeName=$employeeName";
    if ((restaurantName ?? "").isNotEmpty && restaurantName != 'All Restaurants') {
      url += "&restaurantName=$restaurantName";
    }

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<TodaysEmployeesModel>(
      response,
      TodaysEmployeesModel.fromJson,
    ).fold((CustomError l) => left(l), (TodaysEmployeesModel r) => right(r));
  }

  @override
  EitherModel<ClientMyEmployeesModel> getClientMyEmployees(
      {String? startDate, String? endDate, required String hiredBy, String? employeeId}) async {
    String url = "book-history/client-employee?hiredBy=$hiredBy";
    if ((startDate ?? "").isNotEmpty) url += "&startDate=$startDate";
    if ((endDate ?? "").isNotEmpty) url += "&endDate=$endDate";
    if ((employeeId ?? "").isNotEmpty) url += "&employeeId=$employeeId";
    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<ClientMyEmployeesModel>(
      response,
      ClientMyEmployeesModel.fromJson,
    ).fold((CustomError l) => left(l), (ClientMyEmployeesModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> matchEmployee({required String employeeId}) async {
    String url =
        "book-history/match-with-employee?employeeId=$employeeId&currentDate=${DateTime.now().toString().split(' ').first}";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> getSkipDate() async {
    String url = "users/skip-date";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> updateSkipDate() async {
    String url = "users/skip-date";
    String requestBody = jsonEncode({"date": DateTime.now().toString().split(" ").first});
    Response response = await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<ClientBankInfoModel> getBankInfo() async {
    String url = "users/bank-info/${Get.find<AppController>().user.value.client?.id}";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<ClientBankInfoModel>(
      response,
      ClientBankInfoModel.fromJson,
    ).fold((CustomError l) => left(l), (ClientBankInfoModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> createJobPost({required CreateJobPostRequestModel createJobPostRequestModel}) async {
    String url = "job/create";
    String requestBody = createJobPostRequestModel.toRawJson(type: "create");
    Response response = await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<JobPostRequestModel> getJobRequests({String? userType, String? clientId, String? status}) async {
    String url = "job";
    if ((userType ?? "").isNotEmpty && (clientId ?? "").isNotEmpty) url += "?userType=$userType&clientId=$clientId";
    if ((status ?? "").isNotEmpty) url += "?status=$status";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<JobPostRequestModel>(
      response,
      JobPostRequestModel.fromJson,
    ).fold((CustomError l) => left(l), (JobPostRequestModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> deleteJobPost({required String jobId}) async {
    String url = "job/$jobId";

    Response response = await delete(url);
    if (response.statusCode == null) await delete(url);
    if (response.statusCode == null) await delete(url);
    if (response.statusCode == null) await delete(url);

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<Response> interested({required InterestedRequestModel interestedRequestModel}) async {
    String url = "job/add-interest";
    String requestBody = interestedRequestModel.toRawJson();
    Response response = await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> editJobPost({required CreateJobPostRequestModel createJobPostRequestModel}) async {
    String url = "job/update";
    String requestBody = createJobPostRequestModel.toRawJson(type: "update");
    Response response = await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<Response> updateLocation(
      {required EmployeeLocationUpdateRequestModel employeeLocationUpdateRequestModel}) async {
    String url = "users/update-location";
    String requestBody = employeeLocationUpdateRequestModel.toRawJson();
    Response response = await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);
    if (response.statusCode == null) await put(url, requestBody);

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<ConversationResponseModel> createConversation(
      {required ConversationCreateRequestModel conversationCreateRequestModel}) async {
    String url = "conversations/create";
    String requestBody = conversationCreateRequestModel.toRawJson();
    Response response = await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<ConversationResponseModel>(
      response,
      ConversationResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (ConversationResponseModel r) => right(r));
  }

  @override
  EitherModel<MessageResponseModel> getMessages({required MessageRequestModel messageRequestModel}) async {
    String url =
        "messages?conversationId=${messageRequestModel.conversationId}&limit=${messageRequestModel.limit}&page=${messageRequestModel.page}";
    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<MessageResponseModel>(
      response,
      MessageResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (MessageResponseModel r) => right(r));
  }

  @override
  EitherModel<Response> sendMessage({required SendMessageRequestModel sendMessageRequestModel}) async {
    Response response = await post("messages/create", sendMessageRequestModel.toRawJson());
    if (response.statusCode == null) response = await put("messages/create", sendMessageRequestModel.toRawJson());
    if (response.statusCode == null) response = await put("messages/create", sendMessageRequestModel.toRawJson());
    if (response.statusCode == null) response = await put("messages/create", sendMessageRequestModel.toRawJson());

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }
}
