import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/translations/translations_service.dart';
import 'package:mh/app/models/add_social_media_request_model.dart';
import 'package:mh/app/models/alter_user_response_model.dart';
import 'package:mh/app/models/comment_response_model.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/models/hourly_rate_model.dart';
import 'package:mh/app/models/job_post_details_response_model.dart';
import 'package:mh/app/models/launching_message_response_model.dart';
import 'package:mh/app/models/nationality_model.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_comment_request_model.dart';
import 'package:mh/app/models/social_feed_info_response_model.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/models/unread_message_response_model.dart';
import 'package:mh/app/modules/admin/admin_dashboard/models/update_refund_model.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/models/todays_employees_model.dart';
import 'package:mh/app/modules/admin/chat_it/models/chat_it_model.dart';
import 'package:mh/app/modules/client/card_add/models/session_id_response_model.dart';
import 'package:mh/app/modules/client/client_access_control/models/alter_user.dart';
import 'package:mh/app/modules/client/client_dashboard/models/client_update_status_model.dart';
import 'package:mh/app/modules/client/client_edit_profile/model/client_profile_update.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_bank_info_model.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_subscription_invoice_details_response_model.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_subscription_list_response_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/position_info_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/update_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_subscription_plan/models/upgrade_plan_response_model.dart';
import 'package:mh/app/modules/client/client_suggested_employees/models/short_list_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/login.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/login_response.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/new_login_response_model.dart';
import 'package:mh/app/modules/common_modules/auth/models/logout_response_model.dart';
import 'package:mh/app/modules/common_modules/auth/models/refresh_token_response_model.dart';
import 'package:mh/app/modules/common_modules/auth/register/models/client_sign_up_request_model.dart';
import 'package:mh/app/modules/common_modules/auth/register/models/employee_sign_up_model.dart';
import 'package:mh/app/modules/common_modules/calender/models/calender_model.dart';
import 'package:mh/app/modules/common_modules/calender/models/update_unavailable_date_request_model.dart';
import 'package:mh/app/modules/common_modules/email_input/models/forget_password_response_model.dart';
import 'package:mh/app/modules/common_modules/job_post_details/models/interested_request_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/message_request_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/message_response_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/send_message_request_model.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_update_request_model.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_update_response_model.dart';
import 'package:mh/app/modules/common_modules/otp/models/otp_check_request_model.dart';
import 'package:mh/app/modules/common_modules/reset_password/models/reset_password_request_model.dart';
import 'package:mh/app/modules/common_modules/settings/models/change_password_request_model.dart';
import 'package:mh/app/modules/employee/employee_booked_history_details/models/rejected_date_request_model.dart';
import 'package:mh/app/modules/employee/employee_edit_profile/models/bio_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_in_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_out_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_hired_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_location_update_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/booking_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/single_booking_details_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_add_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_plan_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/todays_work_schedule_model.dart';
import 'package:mh/app/repository/server_urls.dart';
import '../common/controller/app_error_controller.dart';
import '../common/local_storage/storage_helper.dart';
import '../common/utils/exports.dart';
import '../common/utils/type_def.dart';
import '../enums/error_from.dart';
import '../models/all_admins.dart';
import '../models/check_in_out_histories.dart';
import '../models/client_edit_profile.dart';
import '../models/commons.dart';
import '../models/custom_error.dart';
import '../models/employee_full_details.dart';
import '../models/employees_by_id.dart';
import '../models/followers_response_model.dart';
import '../models/lat_long_to_address.dart';
import '../models/requested_employees.dart' as requested_employees;
import '../models/saved_post_model.dart';
import '../models/skills_model.dart';
import '../models/social_post_view_increase_response_model.dart';
import '../models/sources.dart';
import '../models/user_block_unblock_response_model.dart';
import '../models/user_profile.dart';
import '../models/user_profile_completion_details.dart';
import '../modules/admin/admin_todays_employees/models/admin_todays_employee_response_model.dart';
import '../modules/client/client_dashboard/models/confirm_employee_task.dart';
import '../modules/client/client_dashboard/models/current_hired_employees.dart';
import '../modules/client/client_dashboard/models/today_checkOutIn_details_model.dart';
import '../modules/client/client_edit_profile/model/client_bank_update_model.dart';
import '../modules/client/client_edit_profile/model/client_business_update_model.dart';
import '../modules/client/client_shortlisted/models/shortlisted_employees.dart' as short_list_employees;
import '../modules/client/client_subscription_plan/models/client_subscription_plan_details.dart';
import '../modules/client/client_subscription_plan/models/client_subscription_plan_model.dart';
import '../modules/client/client_terms_condition_for_hire/models/terms_condition_for_hire.dart';
import '../modules/client/location/models/map_search_model.dart';
import '../modules/client/location/models/saved_search_model.dart';
import '../modules/common_modules/auth/register/models/client_register_response_model.dart';
import '../modules/common_modules/search/models/user_suggestions_model.dart';
import '../modules/employee/employee_edit_profile/models/employee_profile_additional_model.dart';
import '../modules/employee/employee_edit_profile/models/employee_profile_update_model.dart';
import '../modules/employee/employee_home/models/today_check_in_out_details.dart';
import 'api_error_handel.dart';
import 'api_helper.dart';

class ApiHelperImpl extends GetConnect implements ApiHelper {
  @override
  void onInit() {
    httpClient.baseUrl = ServerUrls.serverLiveUrlUser;
    httpClient.timeout = const Duration(seconds: 300);

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
          msg: "Network Issue",
        ));
      }

      Either<CustomError, Response> hasError =
          ApiErrorHandle.checkError(response);

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
    Response response = await get("commons");

    if (response.statusCode == null) response = await get("commons");
    if (response.statusCode == null) response = await get("commons");
    if (response.statusCode == null) response = await get("commons");

    return _convert<Commons>(
      response,
      Commons.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<List<DropdownItem>> positions() async {
    Response response = await get("positions?skipLimit=YES");

    if (response.statusCode == null) response = await get("positions?skipLimit=YES");
    if (response.statusCode == null) response = await get("positions?skipLimit=YES");
    if (response.statusCode == null) response = await get("positions?skipLimit=YES");

    return _convert<List<DropdownItem>>(
      response,
          (json) {
        var positionList = json['positions'] as List<dynamic>;
        return positionList
            .map((item) => DropdownItem.fromJson(item))
            .toList();
      },
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<NewLoginResponseModel> login(
    LoginRequestModel login,
  ) async {
    Response response = await post("users/login", jsonEncode(login.toJson));

    if (response.statusCode == null) {
      response = await post("users/login", jsonEncode(login.toJson));
    }
    if (response.statusCode == null) {
      response = await post("users/login", jsonEncode(login.toJson));
    }
    if (response.statusCode == null) {
      response = await post("users/login", jsonEncode(login.toJson));
    }

    return _convert<NewLoginResponseModel>(
      response,
      NewLoginResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (NewLoginResponseModel r) => right(r));
  }

  @override
  EitherModel<NewLoginResponseModel> clientRegister(
    ClientSignUpRequestModel clientRegistration,
  ) async {
    var response =
        await post("users/client-register", clientRegistration.toRawJson());
    if (response.statusCode == null) {
      await post("users/client-register", clientRegistration.toRawJson());
    }
    if (response.statusCode == null) {
      await post("users/client-register", clientRegistration.toRawJson());
    }
    if (response.statusCode == null) {
      await post("users/client-register", clientRegistration.toRawJson());
    }

    return _convert<NewLoginResponseModel>(
      response,
      NewLoginResponseModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<AlterUserResponseModel> createAlternateUser(
    dynamic mapData,
  ) async {
    var response = await post("users/alternate-create", jsonEncode(mapData));
    return _convert<AlterUserResponseModel>(
      response,
      AlterUserResponseModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<List<AlterUser>> getAlterUsers() async {
    var response = await get("users/alternate-user");
    return _convert<List<AlterUser>>(
      response,
          (json) {
        var mapedList = json['alternateUsers'] as List<dynamic>;
        return mapedList
            .map((item) => AlterUser.fromJson(item))
            .toList();
      },
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<NewLoginResponseModel> employeeRegister(
      EmployeeSignUpRequestModel employeeRegistration) async {
    var response =
        await post("users/employee-register", employeeRegistration.toRawJson());
    if (response.statusCode == null) {
      response = await post(
          "users/employee-register", employeeRegistration.toRawJson());
    }
    if (response.statusCode == null) {
      response = await post(
          "users/employee-register", employeeRegistration.toRawJson());
    }
    if (response.statusCode == null) {
      response = await post(
          "users/employee-register", employeeRegistration.toRawJson());
    }

    return _convert<NewLoginResponseModel>(
      response,
      NewLoginResponseModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updateFcmToken({bool isLogin = true}) async {
    String? token;
    String? deviceIdentifier;
    if (isLogin) {
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (_) {}
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

    var response =
        await put("users/push-notification-update", jsonEncode(data));
    if (response.statusCode == null) {
      response = await put("users/push-notification-update", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("users/push-notification-update", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("users/push-notification-update", jsonEncode(data));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<UserProfileModel> userProfile(
    String id,
  ) async {
    String url = "users/$id";
    var response = await get(url);
    if (response.statusCode == null) response = await get("users/$id");
    if (response.statusCode == null) response = await get("users/$id");
    if (response.statusCode == null) response = await get("users/$id");

    return _convert<UserProfileModel>(
      response,
      UserProfileModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ClientEditProfileModel> clientDetails(
    String id,
  ) async {
    String url = "users/$id";
    var response = await get(url);
    if (response.statusCode == null) response = await get("users/$id");
    if (response.statusCode == null) response = await get("users/$id");
    if (response.statusCode == null) response = await get("users/$id");

    return _convert<ClientEditProfileModel>(
      response,
      ClientEditProfileModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Employees> getAllEmployees() async {
    String url = "users/cached?skipLimit=YES";
    // "users?active=YES&profileCompleted=YES&requestType=EMPLOYEE&skipLimit=YES";
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
  EitherModel<MapSearchResponseModel> mapSearch({
    required String address,
    required String lat,
    required String lang,
    required String totalCount,
    required String minRate,
    required String maxRate,
    required String positionId,
    required String radius,
  }) async {
    String url = "map-search/create";
    String requestBody = jsonEncode({
      "address": address,
      "lat": lat,
      "lng": lang,
      "totalCount": totalCount,
      "minHourlyRate": minRate,
      "maxHourlyRate": maxRate,
      "position": positionId,
      "radius": radius,
    });
    Response response = await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<MapSearchResponseModel>(
      response,
      MapSearchResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (MapSearchResponseModel r) => right(r));
  }

  @override
  EitherModel<List<SavedSearchModel>> getSavedSearch() async {
    String url = "map-search";
    var response = await get(url);

    if (response.statusCode == null) {
      response = await get(url);
    }
    return _convert<List<SavedSearchModel>>(
      response,
      (json) {
        // Ensure you are accessing the correct key if the list is nested
        var skillsList = json['mapSearchs'] as List<dynamic>;
        return skillsList
            .map((item) => SavedSearchModel.fromJson(item))
            .toList();
      },
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> deleteMapSearch(
      {required String searchId}) async {
    String url = "map-search/$searchId";
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
  EitherModel<CommonResponseModel> deleteAllMapSearch(
      {required String userId}) async {
    String url = "map-search/delete-all/$userId";
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
    if ((employeeExperience ?? "").isNotEmpty) {
      url += "&employeeExperience=$employeeExperience";
    }
    if ((minTotalHour ?? "").isNotEmpty) url += "&minTotalHour=$minTotalHour";
    if ((maxTotalHour ?? "").isNotEmpty) url += "&maxTotalHour=$maxTotalHour";
    if (isReferred ?? false) url += "&isReferPerson=${isReferred!.toApiFormat}";
    if ((dressSize ?? "").isNotEmpty) url += "&dressSize=$dressSize";
    if ((minHeight ?? "").isNotEmpty) url += "&minHeight=$minHeight";
    if ((maxHeight ?? "").isNotEmpty) url += "&maxHeight=$maxHeight";
    if ((minHourlyRate ?? "").isNotEmpty) {
      url += "&minHourlyRate=$minHourlyRate";
    }
    if ((maxHourlyRate ?? "").isNotEmpty) {
      url += "&maxHourlyRate=$maxHourlyRate";
    }
    if ((nationality ?? "").isNotEmpty) url += "&nationality=$nationality";
    Response response = await get(url);
    log(" emp lists: ${response.body}");
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
      int? pageNumber,
      String? employeeExperience,
      String? minTotalHour,
      String? maxTotalHour,
      bool? isReferred,
      String? requestType,
      bool? active}) async {
    String url = pageNumber != null
        ? "users?page=$pageNumber&limit=10&requestType=$requestType"
        : "users?skipLimit=YES&requestType=$requestType";

    if ((positionId ?? "").isNotEmpty) url += "&positionId=$positionId";
    if ((rating ?? "").isNotEmpty) url += "&rating=$rating";
    if ((employeeExperience ?? "").isNotEmpty) {
      url += "&employeeExperience=$employeeExperience";
    }
    if ((minTotalHour ?? "").isNotEmpty) url += "&minTotalHour=$minTotalHour";
    if ((maxTotalHour ?? "").isNotEmpty) url += "&maxTotalHour=$maxTotalHour";
    if (isReferred ?? false) url += "&isReferPerson=${isReferred!.toApiFormat}";
    if (active ?? false) url += "&active=${active!.toApiFormat}";

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
  EitherModel<List<SkillModel>> getAllSkills() async {
    String url = "skills";
    var response = await get(url);

    if (response.statusCode == null) {
      response = await get(url);
    }
    return _convert<List<SkillModel>>(
      response,
      (json) {
        // Ensure you are accessing the correct key if the list is nested
        var skillsList = json['skills'] as List<dynamic>;
        return skillsList.map((item) => SkillModel.fromJson(item)).toList();
      },
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<TermsConditionForHire> getTermsConditionForHire() async {
    String url =
        "terms-conditions?country=${TranslationsService.languageList.singleWhere((element) => element.languageCode == StorageHelper.getLanguage).countryName}&active=YES";
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
  EitherModel<short_list_employees.ShortlistedEmployees>
      fetchShortlistEmployees() async {
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
  EitherModel<Response> addToShortlist(
      {required AddToShortListRequestModel addToShortListRequestModel}) async {
    Response response = await post(
        "short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await post(
          "short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post(
          "short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post(
          "short-list/create", jsonEncode(addToShortListRequestModel.toJson()));
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
    if (response.statusCode == null) {
      response = await get("sources/list-for-dropdown");
    }
    if (response.statusCode == null) {
      response = await get("sources/list-for-dropdown");
    }
    if (response.statusCode == null) {
      response = await get("sources/list-for-dropdown");
    }

    return _convert<Sources>(
      response,
      Sources.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updateShortlistItem(
      {required UpdateShortListRequestModel
          updateShortListRequestModel}) async {
    Response response = await put(
        "short-list/update", jsonEncode(updateShortListRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("short-list/update",
          jsonEncode(updateShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("short-list/update",
          jsonEncode(updateShortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("short-list/update",
          jsonEncode(updateShortListRequestModel.toJson()));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> deleteCertificate({
    required String userId,
    required String certificateId,
  }) async {
    // Prepare the payload
    Map<String, String> payload = {
      "id": userId,
      "certificateId": certificateId,
    };

    // Send the PUT request to the 'users/certificate/remove' endpoint
    Response response = await put(
      "users/certificate/remove",
      jsonEncode(payload),
    );

    // Retry logic if the response statusCode is null
    for (int i = 0; i < 3 && response.statusCode == null; i++) {
      response = await put(
        "users/certificate/remove",
        jsonEncode(payload),
      );
    }

    // Convert response and return EitherModel
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> deleteFromShortlist(String shortlistId) async {
    var response = await delete("short-list/delete/$shortlistId");
    if (response.statusCode == null) {
      response = await delete("short-list/delete/$shortlistId");
    }
    if (response.statusCode == null) {
      response = await delete("short-list/delete/$shortlistId");
    }
    if (response.statusCode == null) {
      response = await delete("short-list/delete/$shortlistId");
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> hireConfirm(Map<String, dynamic> data) async {
    var response = await post("hired-histories/create", jsonEncode(data));
    if (response.statusCode == null) {
      response = await post("hired-histories/create", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await post("hired-histories/create", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await post("hired-histories/create", jsonEncode(data));
    }

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
    if (response.statusCode == null) {
      response = await get("search?q=$query&format=jsonv2");
    }
    if (response.statusCode == null) {
      response = await get("search?q=$query&format=jsonv2");
    }
    if (response.statusCode == null) {
      response = await get("search?q=$query&format=jsonv2");
    }
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
    if (response.statusCode == null) {
      response = await get("reverse?lat=$lat&lon=$lng&format=jsonv2");
    }
    if (response.statusCode == null) {
      response = await get("reverse?lat=$lat&lon=$lng&format=jsonv2");
    }
    if (response.statusCode == null) {
      response = await get("reverse?lat=$lat&lon=$lng&format=jsonv2");
    }
    httpClient.baseUrl = ServerUrls.serverLiveUrlUser;

    return _convert<LatLngToAddress>(
      response,
      LatLngToAddress.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  Future<void> submitAppError(Map<String, String> data) async {
    if (!kDebugMode) {
      var response = await post("app-errors/create", jsonEncode(data));
      if (response.statusCode == null) {
        response = await post("app-errors/create", jsonEncode(data));
      }
    }
  }

  @override
  EitherModel<TodayCheckInOutDetails> dailyCheckInCheckoutDetails(
      String employeeId) async {
    var response = await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) {
      response = await get("current-hired-employees/details/$employeeId");
    }
    if (response.statusCode == null) {
      response = await get("current-hired-employees/details/$employeeId");
    }
    if (response.statusCode == null) {
      response = await get("current-hired-employees/details/$employeeId");
    }

    return _convert<TodayCheckInOutDetails>(
      response,
      TodayCheckInOutDetails.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<UserProfileCompletionDetails> userProfileCompletionDetails(
      String userId) async {
    var response = await get("users/profile-completion/$userId");
    //log(" user pro con ${response.body}");

    // Retry if the response is null or unsuccessful
    for (int i = 0;
        i < 3 && (response.statusCode == null || response.statusCode != 200);
        i++) {
      response = await get("users/profile-completion/$userId");
    }

    // Use `fromApiResponse` to extract and parse `details`
    return _convert<UserProfileCompletionDetails>(
      response,
      UserProfileCompletionDetails.fromApiResponse,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> checkIn(
      {required EmployeeCheckInRequestModel
          employeeCheckInRequestModel}) async {
    Response response = await post("current-hired-employees/create",
        jsonEncode(employeeCheckInRequestModel.toJson()));

    if (response.statusCode == null) {
      response = await post("current-hired-employees/create",
          jsonEncode(employeeCheckInRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("current-hired-employees/create",
          jsonEncode(employeeCheckInRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post("current-hired-employees/create",
          jsonEncode(employeeCheckInRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<List<UserSuggestionModel>> fetchUserSuggestions({
    required String searchKey,
  }) async {
    const String endpoint = "users/suggestions?searchKey=";
    final String url = "$endpoint$searchKey";

    Response response = await get(url);

    // Retry logic
    for (int i = 0; i < 3 && response.statusCode == null; i++) {
      response = await get(url);
    }

    // if (response.statusCode == null) {
    //   return [];
    // }

    // if (response.statusCode != 200) {
    //   return left(ErrorModel(
    //     message: response.body['message'] ?? 'Error fetching suggestions',
    //   ));
    // }

    // Convert response safely
    return _convert<List<UserSuggestionModel>>(
      response,
      (body) {
        final data = body['suggestions'] as List;
        return data.map((json) => UserSuggestionModel.fromJson(json)).toList();
      },
    ).fold(
      (l) => left(l),
      (r) => right(r),
    );
  }

  @override
  Future<Either<CustomError, List<Job>>> searchJobPosts({
    required String searchKey,
    int? page,
  }) async {
    final String endpoint = "job/search?searchKey=$searchKey";

    Response response = await get(endpoint);

    // Retry logic
    for (int i = 0; i < 3 && response.statusCode == null; i++) {
      response = await get(endpoint);
    }
// log("job body: ${response.body}");
// log("job res: ${response.statusCode}");
    try {
      if (response.statusCode == 200 && response.body['jobs'] != null) {
        final jobData = response.body['jobs'] as List;
        final jobs = jobData.map((json) => Job.fromJson(json)).toList();

        return right(jobs);
      } else {
        return left(CustomError(
          errorCode: response.statusCode ?? 500,
          errorFrom: ErrorFrom.api,
          msg: response.body['message'] ?? 'Error fetching job posts',
        ));
      }
    } catch (e) {
      return left(CustomError(
        errorCode: 500,
        errorFrom: ErrorFrom.api,
        msg: 'An unexpected error occurred: $e',
      ));
    }
  }

  @override
  EitherModel<Response> checkout(
      {required EmployeeCheckOutRequestModel
          employeeCheckOutRequestModel}) async {
    Response response = await put("current-hired-employees/update",
        jsonEncode(employeeCheckOutRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("current-hired-employees/update",
          jsonEncode(employeeCheckOutRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("current-hired-employees/update",
          jsonEncode(employeeCheckOutRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("current-hired-employees/update",
          jsonEncode(employeeCheckOutRequestModel.toJson()));
    }
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> confirmEmployeeTask({
    required ConfirmEmployeeTaskModel confirmEmployeeTaskModel,
  }) async {
    String endpoint = "check-in-check-out-histories/review-employee";
    String payload = jsonEncode(confirmEmployeeTaskModel.toJson());

    // Make the PUT request with retry logic
    Response response = await put(endpoint, payload);
    if (response.statusCode == null) {
      response = await put(endpoint, payload);
    }
    if (response.statusCode == null) {
      response = await put(endpoint, payload);
    }
    if (response.statusCode == null) {
      response = await put(endpoint, payload);
    }

    // Convert the response and return
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updateCheckInOutByClient(
      {required ClientUpdateStatusModel clientUpdateStatusModel}) async {
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
  Future<Either<CustomError, Response>> updateClientBankDetails({
    required ClientBankDetailsModel clientBankDetailsModel,
  }) async {
    String url = "users/app/client-update/bank"; // API endpoint
    String requestBody =
        jsonEncode(clientBankDetailsModel.toJson()); // Convert payload to JSON

    // Make the PUT request
    Response response = await put(url, requestBody);

    // Retry logic in case of null status code
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);

    // Handle and convert response
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError error) => left(error),
        (Response successResponse) => right(successResponse));
  }

  @override
  Future<Either<CustomError, Response>> updateEmployeeBankDetails({
    required ClientBankDetailsModel clientBankDetailsModel,
  }) async {
    String url = "users/app/employee-update/bank"; // API endpoint
    String requestBody =
        jsonEncode(clientBankDetailsModel.toJson()); // Convert payload to JSON

    // Make the PUT request
    Response response = await put(url, requestBody);

    // Retry logic in case of null status code
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);

    // Handle and convert response
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError error) => left(error),
        (Response successResponse) => right(successResponse));
  }

  @override
  Future<Either<CustomError, Response>> updateEmployeeAdditionalDetails({
    required EmployeeProfileAdditionalModel employeeProfileAdditionalModel,
  }) async {
    String url = "users/app/employee-update/additional"; // API endpoint
    String requestBody = jsonEncode(
        employeeProfileAdditionalModel.toJson()); // Convert payload to JSON

    // Make the PUT request
    Response response = await put(url, requestBody);

    // Retry logic in case of null status code
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);
    if (response.statusCode == null) response = await put(url, requestBody);

    // Handle and convert response
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError error) => left(error),
        (Response successResponse) => right(successResponse));
  }

  @override
  EitherModel<Response> deleteAccount(Map<String, dynamic> data) async {
    Response response = await put("users/update-status", jsonEncode(data));
    if (response.statusCode == null) {
      response = await put("users/update-status", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("users/update-status", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("users/update-status", jsonEncode(data));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> deleteAccountPermanently(String userId) async {
    Response response = await delete("users/delete/$userId");
    if (response.statusCode == null) {
      response = await delete("users/delete/$userId");
    }
    if (response.statusCode == null) {
      response = await delete("users/delete/$userId");
    }
    if (response.statusCode == null) {
      response = await delete("users/delete/$userId");
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> deleteAccountSoftly(Map<String, dynamic> data) async {
    Response response = await put("users/remove", data);
    if (response.statusCode == null) {
      response = await put("users/remove", data);
    }
    if (response.statusCode == null) {
      response = await put("users/remove", data);
    }
    if (response.statusCode == null) {
      response = await put("users/remove", data);
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updateEmployeePaymentByClient(
      Map<String, dynamic> data) async {
    Response response =
        await put("check-in-check-out-histories/update-employee-payment", data);
    if (response.statusCode == null) {
      response = await put(
          "check-in-check-out-histories/update-employee-payment", data);
    }
    if (response.statusCode == null) {
      response = await put(
          "check-in-check-out-histories/update-employee-payment", data);
    }
    if (response.statusCode == null) {
      response = await put(
          "check-in-check-out-histories/update-employee-payment", data);
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<HiredEmployeesByDate> getHiredEmployeesByDate(
      {String? date}) async {
    String url = "hired-histories/employee-list-for-client";

    if (date != null) {
      url += "?filterDate=$date&utc=${DateTime.now().timeZoneOffset.inHours}";
    }

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
  EitherModel<TodayCheckInOutDetails> getTodayCheckInOutDetails(
      String employeeId) async {
    Response response =
        await get("current-hired-employees/details/$employeeId");
    if (response.statusCode == null) {
      response = await get("current-hired-employees/details/$employeeId");
    }
    if (response.statusCode == null) {
      response = await get("current-hired-employees/details/$employeeId");
    }
    if (response.statusCode == null) {
      response = await get("current-hired-employees/details/$employeeId");
    }
    return _convert<TodayCheckInOutDetails>(
      response,
      TodayCheckInOutDetails.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  // Modified function to fetch today's employee list
  @override
  EitherModel<TodayCheckInOutDetailsForClient> getTodayEmployeeList(
      {required DateTime startDate, required DateTime endDate}) async {
    final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    // Format the dates to match the API requirements
    final String formattedStartDate = dateFormat.format(startDate);
    final String formattedEndDate = dateFormat.format(endDate);

    // Define the endpoint with query parameters
    String url =
        "check-in-check-out-histories/today-employee?startDate=$formattedStartDate&endDate=$formattedEndDate";
//log("api url: $url");
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

    return _convert<TodayCheckInOutDetailsForClient>(
      response,
      TodayCheckInOutDetailsForClient.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CheckInCheckOutHistory> getCheckInOutHistory({
    String? filterDate,
    String? requestType,
    String? clientId,
    String? employeeId,
  }) async {
    String url =
        "check-in-check-out-histories?utc=${DateTime.now().timeZoneOffset.inHours}";
    // String url =
    //     "check-in-check-out-histories?";

    if ((filterDate ?? "").isNotEmpty) url += "&filterDate=$filterDate";
    if ((requestType ?? "").isNotEmpty) url += "&requestType=$requestType";
    if ((clientId ?? "").isNotEmpty) url += "&clientId=$clientId";
    if ((employeeId ?? "").isNotEmpty) url += "&employeeId=$employeeId&skipLimit=YES";

    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    log("paymnet res: ${response.body}");
    return _convert<CheckInCheckOutHistory>(
      response,
      CheckInCheckOutHistory.fromJson,
    ).fold((CustomError l) => left(l), (CheckInCheckOutHistory r) => right(r));
  }

  @override
  EitherModel<CheckInCheckOutHistory> getEmployeeCheckInOutHistory(
      {String? startDate, String? endDate, int? page, int? limit}) async {
    String url =
        "check-in-check-out-histories?employeeId=${Get.find<AppController>().user.value.employee?.id}";
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
  EitherModel<Response> clientRequestForEmployee(
      Map<String, dynamic> data) async {
    var response = await post("request-employees/create", jsonEncode(data));
    if (response.statusCode == null) {
      response = await put("request-employees/create", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("request-employees/create", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("request-employees/create", jsonEncode(data));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<requested_employees.RequestedEmployees> getRequestedEmployees(
      {String? clientId}) async {
    String url = "request-employees?";

    // if ((clientId ?? "").isNotEmpty) url += "clientId=$clientId";
    // if ((clientId ?? "").isNotEmpty)
    url += "clientId=$clientId";

    Response response = await get(url);
    //  log("request url: ${url}");
    // log("request: ${response.body}");
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
    log("update response: ${response.body}");
    if (response.statusCode == null) {
      response = await put("request-employees/update", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("request-employees/update", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("request-employees/update", jsonEncode(data));
    }
    log("update response:  2 ${response.body}");
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
    //log("user resposne: ${response.body}");
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    return _convert<EmployeeFullDetails>(
      response,
      EmployeeFullDetails.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<FollowersResponseModel> employeeFollowersDetails(
      String id) async {
    String url = "social-feed/followers/$id";

    Response response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    if (response.statusCode == null) response = await get(url);
    return _convert<FollowersResponseModel>(
      response,
      FollowersResponseModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> followUnfollow(Map<String, dynamic> data) async {
    String url = "social-feed/follow-unfollow";

    var response = await post(url, jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> toggleNotification(Map<String, dynamic> data) async {
    String url = "social-feed/toggle-notification";

    var response = await post(url, jsonEncode(data));

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ClientRegistrationResponse> updateClientProfile2(
      ClientProfileUpdate clientProfileUpdate) async {
    Response response = await put("users/app/client-update/profile/",
        jsonEncode(clientProfileUpdate.toJson));
    if (response.statusCode == null) {
      response = await put("users/app/client-update/profile/",
          jsonEncode(clientProfileUpdate.toJson));
    }
    if (response.statusCode == null) {
      response = await put("users/app/client-update/profile/",
          jsonEncode(clientProfileUpdate.toJson));
    }
    if (response.statusCode == null) {
      response = await put("users/app/client-update/profile/",
          jsonEncode(clientProfileUpdate.toJson));
    }

    return _convert<ClientRegistrationResponse>(
      response,
      ClientRegistrationResponse.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ClientRegistrationResponse> updateClientBusiness(
      ClientBusinessUpdate clientBusinessUpdate) async {
    Response response = await put("users/app/client-update/business",
        jsonEncode(clientBusinessUpdate.toJson()));
    if (response.statusCode == null) {
      response = await put("users/app/client-update/business",
          jsonEncode(clientBusinessUpdate.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/app/client-update/business",
          jsonEncode(clientBusinessUpdate.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/app/client-update/business",
          jsonEncode(clientBusinessUpdate.toJson()));
    }

    return _convert<ClientRegistrationResponse>(
      response,
      ClientRegistrationResponse.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<LoginResponse> updateClientProfile(
      ClientProfileUpdate clientProfileUpdate) async {
    Response response = await put(
        "users/update-client", jsonEncode(clientProfileUpdate.toJson));
    if (response.statusCode == null) {
      response = await put(
          "users/update-client", jsonEncode(clientProfileUpdate.toJson));
    }
    if (response.statusCode == null) {
      response = await put(
          "users/update-client", jsonEncode(clientProfileUpdate.toJson));
    }
    if (response.statusCode == null) {
      response = await put(
          "users/update-client", jsonEncode(clientProfileUpdate.toJson));
    }

    return _convert<LoginResponse>(
      response,
      LoginResponse.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<Response> updatePaymentStatus(Map<String, dynamic> data) async {
    Response response = await put("invoices/update-status", jsonEncode(data));
    if (response.statusCode == null) {
      response = await put("invoices/update-status", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("invoices/update-status", jsonEncode(data));
    }
    if (response.statusCode == null) {
      response = await put("invoices/update-status", jsonEncode(data));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<NotificationResponseModel> getNotifications(
      {required int page}) async {
    String url = "notifications/list?page=$page";

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
    ).fold(
        (CustomError l) => left(l), (NotificationResponseModel r) => right(r));
  }

  @override
  EitherModel<NotificationUpdateResponseModel> updateNotification(
      {required NotificationUpdateRequestModel
          notificationUpdateRequestModel}) async {
    Response response = await put("notifications/update-status",
        jsonEncode(notificationUpdateRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("notifications/update-status",
          jsonEncode(notificationUpdateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-status",
          jsonEncode(notificationUpdateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-status",
          jsonEncode(notificationUpdateRequestModel.toJson()));
    }

    return _convert<NotificationUpdateResponseModel>(
      response,
      NotificationUpdateResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (NotificationUpdateResponseModel r) => right(r));
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
  EitherModel<BookingHistoryModel> cancelClientRequestFromAdmin(
      {required String requestId}) async {
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

    Response response =
        await patch(url, jsonEncode({"employeeId": employeeId}));
    if (response.statusCode == null) {
      response = await patch(url, jsonEncode({"employeeId": employeeId}));
    }
    if (response.statusCode == null) {
      response = await patch(url, jsonEncode({"employeeId": employeeId}));
    }
    if (response.statusCode == null) {
      response = await patch(url, jsonEncode({"employeeId": employeeId}));
    }

    return _convert<BookingHistoryModel>(
      response,
      BookingHistoryModel.fromJson,
    ).fold((CustomError l) => left(l), (BookingHistoryModel r) => right(r));
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
  EitherModel<CommonResponseModel> giveReview(
      {required ReviewRequestModel reviewRequestModel}) async {
    String url = "review/create";

    var response = await post(url, jsonEncode(reviewRequestModel.toJson()));
    if (response.statusCode == null) {
      await post(url, jsonEncode(reviewRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      await post(url, jsonEncode(reviewRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      await post(url, jsonEncode(reviewRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> addToShortlistNew(
      {required ShortListRequestModel shortListRequestModel}) async {
    String url = "request-employees/short-list-create";

    var response = await post(url, jsonEncode(shortListRequestModel.toJson()));
    if (response.statusCode == null) {
      await post(url, jsonEncode(shortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      await post(url, jsonEncode(shortListRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      await post(url, jsonEncode(shortListRequestModel.toJson()));
    }
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CalenderModel> getCalenderData(
      {required String employeeId}) async {
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
      {required UpdateUnavailableDateRequestModel
          updateUnavailableDateRequestModel}) async {
    String url = "users/update-unavailable-date";

    Response response =
        await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));
    if (response.statusCode == null) {
      await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      await put(url, jsonEncode(updateUnavailableDateRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<TodayWorkScheduleModel> getTodayWorkSchedule(String time) async {
    String url =
        "check-in-check-out-histories/today-work-place?currentDate=$time";

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
    ).fold(
        (CustomError l) => left(l), (EmployeeHiredHistoryModel r) => right(r));
  }

  @override
  EitherModel<SingleBookingDetailsModel> getBookingDetails(
      {required String notificationId}) async {
    String url = "notifications/$notificationId";

    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<SingleBookingDetailsModel>(
      response,
      SingleBookingDetailsModel.fromJson,
    ).fold(
        (CustomError l) => left(l), (SingleBookingDetailsModel r) => right(r));
  }

  @override
  EitherModel<Response> updateRequestDate(
      {required RejectedDateRequestModel rejectedDateRequestModel}) async {
    Response response = await put("notifications/update-request-date",
        jsonEncode(rejectedDateRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("notifications/update-request-date",
          jsonEncode(rejectedDateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-request-date",
          jsonEncode(rejectedDateRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("notifications/update-request-date",
          jsonEncode(rejectedDateRequestModel.toJson()));
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((l) => left(l), (r) => right(r));
  }

/*  @override
  EitherModel<ExtraFieldModel> getEmployeeExtraField(
      {required String countryName}) async {
    Response response =
        await post("document/get-fields", jsonEncode({"country": countryName}));
    if (response.statusCode == null) {
      response = await post(
          "document/get-fields", jsonEncode({"country": countryName}));
    }
    if (response.statusCode == null) {
      response = await post(
          "document/get-fields", jsonEncode({"country": countryName}));
    }
    if (response.statusCode == null) {
      response = await post(
          "document/get-fields", jsonEncode({"country": countryName}));
    }

    return _convert<ExtraFieldModel>(
      response,
      ExtraFieldModel.fromJson,
    ).fold((CustomError l) => left(l), (ExtraFieldModel r) => right(r));
  }*/

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
    Response response = await put("users/update-password",
        jsonEncode(changePasswordRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("users/update-password",
          jsonEncode(changePasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/update-password",
          jsonEncode(changePasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/update-password",
          jsonEncode(changePasswordRequestModel.toJson()));
    }
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<ForgetPasswordResponseModel> inputEmail(
      {required String email}) async {
    Response response =
        await put("users/forgot-password", jsonEncode({"email": email}));
    if (response.statusCode == null) {
      response =
          await put("users/forgot-password", jsonEncode({"email": email}));
    }
    if (response.statusCode == null) {
      response =
          await put("users/forgot-password", jsonEncode({"email": email}));
    }
    if (response.statusCode == null) {
      response =
          await put("users/forgot-password", jsonEncode({"email": email}));
    }

    return _convert<ForgetPasswordResponseModel>(
      response,
      ForgetPasswordResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> otpCheck(
      {required OtpCheckRequestModel otpCheckRequestModel}) async {
    Response response = await post(
        "users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await post(
          "users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post(
          "users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await post(
          "users/otp-check", jsonEncode(otpCheckRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> resetPassword(
      {required ResetPasswordRequestModel resetPasswordRequestModel}) async {
    Response response = await put(
        "users/reset-password", jsonEncode(resetPasswordRequestModel.toJson()));
    if (response.statusCode == null) {
      response = await put("users/reset-password",
          jsonEncode(resetPasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/reset-password",
          jsonEncode(resetPasswordRequestModel.toJson()));
    }
    if (response.statusCode == null) {
      response = await put("users/reset-password",
          jsonEncode(resetPasswordRequestModel.toJson()));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<PositionInfoModel> getPositionInfo(
      {required String positionId}) async {
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
      {required String startDate,
      required String endDate,
      String? employeeName,
      String? restaurantName,
      String? hiredBy}) async {
    String url = "book-history?startDate=$startDate&endDate=$endDate";
    if ((employeeName ?? "").isNotEmpty && employeeName != 'All Employees') {
      url += "&employeeName=$employeeName";
    }
    if ((restaurantName ?? "").isNotEmpty &&
        restaurantName != 'All Restaurants') {
      url += "&restaurantName=$restaurantName";
    }
    if ((hiredBy ?? "").isNotEmpty && hiredBy != '') {
      url += "&hiredBy=$hiredBy";
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
  EitherModel<AdminTodaysEmployeeResponseModel> getTodaysEmployeesFromAdmin(
      {required String startDate,
      required String endDate,
      String? hiredBy}) async {
    String url =
        "book-history/client-employee?startDate=$startDate&endDate=$endDate";
    if ((hiredBy ?? "").isNotEmpty && hiredBy != '') {
      url += "&hiredBy=$hiredBy";
    }

    Response response = await get(url);
    debugPrint(response.statusCode.toString());
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<AdminTodaysEmployeeResponseModel>(
      response,
      AdminTodaysEmployeeResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (AdminTodaysEmployeeResponseModel r) => right(r));
  }

  @override
  EitherModel<ClientMyEmployeesModel> getClientMyEmployees(
      {String? startDate,
      String? endDate,
      bool? allEmployees,
      required String hiredBy,
      String? employeeId}) async {
    String url = "book-history/client-employee?hiredBy=$hiredBy";

    if (allEmployees ?? false) {
      DateTime now = DateTime.now();
      url +=
          "&startDate=${DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1))}&endDate=${DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1)))}";
    } else {
      if ((startDate ?? "").isNotEmpty) url += "&startDate=$startDate";
      if ((endDate ?? "").isNotEmpty) url += "&endDate=$endDate";
      if ((employeeId ?? "").isNotEmpty) url += "&employeeId=$employeeId";
    }

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
  EitherModel<CommonResponseModel> matchEmployee(
      {required String employeeId}) async {
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
    String requestBody =
        jsonEncode({"date": DateTime.now().toString().split(" ").first});
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
    String url =
        "users/bank-info/${Get.find<AppController>().user.value.client?.id}";

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
  EitherModel<CommonResponseModel> createJobPost(
      {required CreateJobPostRequestModel createJobPostRequestModel}) async {
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
  EitherModel<JobPostRequestModel> getJobPosts(
      {required String userType,
      required int page,
      String? status,
      bool? isMyJobPost = false,
      int? limit = 20, // Default to 20, but can be customized
      String? jobPostForUserId}) async {
    String url = "job";

    if (userType == "client") {
      if ((status ?? "").isNotEmpty) {
        if (isMyJobPost == true) {
          url +=
              "?userType=$userType&clientId=${Get.find<AppController>().user.value.client?.id}&limit=$limit&page=$page";
        } else {
          // url += "?status=PUBLISHED&limit=$limit&page=$page";
          url += "?status=$status&limit=$limit&page=$page";
        }
      } else {
        if (isMyJobPost == true) {
          url +=
              "?clientId=${Get.find<AppController>().user.value.client?.id}&limit=$limit&page=$page";
        } else {
          url += "?status=PUBLISHED&limit=$limit&page=$page";
          // url += "?limit=$limit&page=$page";
        }
      }
    } else if (userType == "employee") {
      if ((status ?? "").isNotEmpty) {
        // url +=
        //     "?status=PUBLISHED&clientId=${Get.find<AppController>().user.value.employee?.id}&limit=$limit&page=$page";
        // url +=
        //     "?status=PUBLISHED&limit=$limit&page=$page";
        url += "?status=$status&limit=$limit&page=$page";
      } else {
        // url += "?status=PUBLISHED&limit=$limit&page=$page";
        url += "?limit=$limit&page=$page";
      }
    } else if (userType == "admin") {
      url += "?page=$page&limit=$limit";
    } else {
      url +=
          "?status=$status&clientId=$jobPostForUserId&page=$page&limit=$limit";
    }

    Response response = await get(url);
    // log("Response job count: ${response.body['total']}");
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<JobPostRequestModel>(
      response,
      JobPostRequestModel.fromJson,
    ).fold((CustomError l) => left(l), (JobPostRequestModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> deleteJobPost(
      {required String jobId}) async {
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
  EitherModel<Response> interested(
      {required InterestedRequestModel interestedRequestModel}) async {
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
  EitherModel<CommonResponseModel> editJobPost(
      {required CreateJobPostRequestModel createJobPostRequestModel}) async {
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
      {required EmployeeLocationUpdateRequestModel
          employeeLocationUpdateRequestModel}) async {
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
  EitherModel<Response> userValidation({required String email}) async {
    String url = "users/validated";
    String requestBody = jsonEncode({"email": email});
    Response response = await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<SessionIdResponseModel> getSessionId(
      {required String email, required String fromWhere}) async {
    String url = "users/get-session";
    String requestBody = jsonEncode(
        {"email": email, "returnUrl": "https://plagit.com?name=$fromWhere"});
    Response response = await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<SessionIdResponseModel>(
      response,
      SessionIdResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (SessionIdResponseModel r) => right(r));
  }

  @override
  EitherModel<Response> removeCard() async {
    String url = "users/remove-token";
    String requestBody =
        jsonEncode({"id": Get.find<AppController>().user.value.userId});
    Response response = await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> updateRefund(
      {required UpdateRefundModel updateRefundModel}) async {
    String url = "check-in-check-out-histories/update-refund";
    Response response = await put(url, updateRefundModel.toRawJson());
    if (response.statusCode == null) {
      await put(url, updateRefundModel.toRawJson());
    }
    if (response.statusCode == null) {
      await put(url, updateRefundModel.toRawJson());
    }
    if (response.statusCode == null) {
      await put(url, updateRefundModel.toRawJson());
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<ConversationResponseModel> createConversation(
      {required ConversationCreateRequestModel
          conversationCreateRequestModel}) async {
    String url = "conversations/create";
    String requestBody = conversationCreateRequestModel.toRawJson();
    Response response = await post(url, requestBody);
    log("res for cov: ${response.body}");
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<ConversationResponseModel>(
      response,
      ConversationResponseModel.fromJson,
    ).fold(
        (CustomError l) => left(l), (ConversationResponseModel r) => right(r));
  }

  @override
  EitherModel<ConversationResponseModel> createConversationWithCandidate(
      {required ConversationCreateRequestModel
          conversationCreateRequestModel}) async {
    String url = "conversations/create";
    var requestBody = conversationCreateRequestModel.toAnotherJson();
    Response response = await post(url, requestBody);
    log("res for cov 2: ${response.body}");
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);
    if (response.statusCode == null) await post(url, requestBody);

    return _convert<ConversationResponseModel>(
      response,
      ConversationResponseModel.fromJson,
    ).fold(
        (CustomError l) => left(l), (ConversationResponseModel r) => right(r));
  }

  @override
  EitherModel<MessageResponseModel> getMessages(
      {required MessageRequestModel messageRequestModel}) async {
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
  EitherModel<Response> sendMessage(
      {required SendMessageRequestModel sendMessageRequestModel}) async {
    Response response =
        await post("messages/create", sendMessageRequestModel.toRawJson());
    if (response.statusCode == null) {
      response =
          await put("messages/create", sendMessageRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      response =
          await put("messages/create", sendMessageRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      response =
          await put("messages/create", sendMessageRequestModel.toRawJson());
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<ChatItModel> getConversations(
      {int? pageNumber, int? limit, bool unread=false}) async {
    String url = "conversations?";
    if (pageNumber == null && limit == null) {
      url += 'skipLimit=YES';
    } else {
      if (pageNumber != null) {
        url += 'page=$pageNumber';
      } else {
        url += 'page=1';
      }
      if (limit != null) {
        url += '&limit=$limit';
      } else {
        url += '&limit=1';
      }
      if(unread){
        url += '&unread=YES';
      }
    }
    Response response = await get(url);
    //log("conv list: ${response.body}");
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    return _convert<ChatItModel>(
      response,
      ChatItModel.fromJson,
    ).fold((CustomError l) => left(l), (ChatItModel r) => right(r));
    // }
  }

  @override
  EitherModel<Response> updateEmployeeProfile({
    required EmployeeProfileRequestModel employeeProfileRequestModel,
  }) async {
    String endpoint = "users/app/employee-update/profile";
    String payload = employeeProfileRequestModel.toRawJson();

    // Send the PUT request with retry logic
    Response response = await put(endpoint, payload);
    if (response.statusCode == null) {
      response = await put(endpoint, payload);
    }
    if (response.statusCode == null) {
      response = await put(endpoint, payload);
    }
    if (response.statusCode == null) {
      response = await put(endpoint, payload);
    }

    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<Response> updateEmployeeBio(
      {required BioRequestModel bioRequestModel}) async {
    Response response =
        await put("users/update-employee-bio", bioRequestModel.toRawJson());
    if (response.statusCode == null) {
      response =
          await put("users/update-employee-bio", bioRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      response =
          await put("users/update-employee-bio", bioRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      response =
          await put("users/update-employee-bio", bioRequestModel.toRawJson());
    }
    return _convert<Response>(
      response,
      (Map<String, dynamic> data) {},
      onlyErrorCheck: true,
    ).fold((CustomError l) => left(l), (Response r) => right(r));
  }

  @override
  EitherModel<UnreadMessageResponseModel> getUnreadMessages() async {
    String url = "conversations/unread/?&skipLimit=YES";
    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<UnreadMessageResponseModel>(
      response,
      UnreadMessageResponseModel.fromJson,
    ).fold(
        (CustomError l) => left(l), (UnreadMessageResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> deleteConversation(
      {required String conversationId}) async {
    Response response = await delete("conversations/$conversationId");
    if (response.statusCode == null) {
      response = await delete("conversations/$conversationId");
    }
    if (response.statusCode == null) {
      response = await delete("conversations/$conversationId");
    }
    if (response.statusCode == null) {
      response = await delete("conversations/$conversationId");
    }
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> checkSubscription() async {
    Response response = await get("subscription/check-subscription");
    if (response.statusCode == null) {
      response = await get("subscription/check-subscription");
    }
    if (response.statusCode == null) {
      response = await get("subscription/check-subscription");
    }
    if (response.statusCode == null) {
      response = await get("subscription/check-subscription");
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<ClientSubscriptionListResponseModel>
      getSubscriptionInvoices() async {
    Response response = await get("subscription");
    if (response.statusCode == null) {
      response = await get("subscription");
    }
    if (response.statusCode == null) {
      response = await get("subscription");
    }
    if (response.statusCode == null) {
      response = await get("subscription");
    }

    return _convert<ClientSubscriptionListResponseModel>(
      response,
      ClientSubscriptionListResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (ClientSubscriptionListResponseModel r) => right(r));
  }

  @override
  EitherModel<ClientSubscriptionInvoiceDetailsResponseModel>
      getSubscriptionInvoicesDetails({required String id}) async {
    Response response = await get("subscription/payment-history/$id");
    if (response.statusCode == null) {
      response = await get("subscription/payment-history/$id");
    }
    if (response.statusCode == null) {
      response = await get("subscription/payment-history/$id");
    }
    if (response.statusCode == null) {
      response = await get("subscription/payment-history/$id");
    }

    return _convert<ClientSubscriptionInvoiceDetailsResponseModel>(
      response,
      ClientSubscriptionInvoiceDetailsResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (ClientSubscriptionInvoiceDetailsResponseModel r) => right(r));
  }

  @override
  EitherModel<ClientSubscriptionPlanModel>
      getClientSubscriptionPlanList() async {
    Response response = await get("subscription-plan");
    return _convert<ClientSubscriptionPlanModel>(
      response,
      ClientSubscriptionPlanModel.fromJson,
    ).fold((CustomError l) => left(l),
        (ClientSubscriptionPlanModel r) => right(r));
  }

  @override
  EitherModel<ClientSubscriptionPlanDetails> getClientSubscriptionDetails(
      {required String userId}) async {
    String url = "users/$userId";
    var response = await get(url);

    return _convert<ClientSubscriptionPlanDetails>(
      response,
      ClientSubscriptionPlanDetails.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<LaunchingMessageResponseModel> getLaunchingMessage() async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Response response = await get(
        "users/launching-msg?type=APP&today=$today&maintainceDay=2025-03-03");
    return _convert<LaunchingMessageResponseModel>(
      response,
      LaunchingMessageResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (LaunchingMessageResponseModel r) => right(r));
  }

  @override
  EitherModel<SubscriptionPlanResponseModel> getSubscriptionPlans() async {
    Response response = await get("subscription-plan");
    if (response.statusCode == null) response = await get("subscription-plan");
    if (response.statusCode == null) response = await get("subscription-plan");
    if (response.statusCode == null) response = await get("subscription-plan");
    return _convert<SubscriptionPlanResponseModel>(
      response,
      SubscriptionPlanResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (SubscriptionPlanResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> addNewSubscription(
      {required SubscriptionAddRequestModel
          subscriptionAddRequestModel}) async {
    Response response = await post(
        "subscription/create", subscriptionAddRequestModel.toRawJson());
    if (response.statusCode == null) {
      response = await post(
          "subscription/create", subscriptionAddRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      response = await post(
          "subscription/create", subscriptionAddRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      response = await post(
          "subscription/create", subscriptionAddRequestModel.toRawJson());
    }
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<UpgradePlanResponseModel> upgradePlan({required payLoad}) async {
    Response response = await post("subscription/create", payLoad);
    return _convert<UpgradePlanResponseModel>(
      response,
      UpgradePlanResponseModel.fromJson,
    ).fold(
        (CustomError l) => left(l), (UpgradePlanResponseModel r) => right(r));
  }

  @override
  EitherModel<Employees> getPositionWiseEmployees(
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
    String url = "users?active=YES";

    if ((positionId ?? "").isNotEmpty) url += "&positionId=$positionId";
    if ((employeeExperience ?? "").isNotEmpty) {
      url += "&employeeExperience=$employeeExperience";
    }
    if ((minTotalHour ?? "").isNotEmpty) url += "&minTotalHour=$minTotalHour";
    if ((maxTotalHour ?? "").isNotEmpty) url += "&maxTotalHour=$maxTotalHour";
    if (isReferred ?? false) url += "&isReferPerson=${isReferred!.toApiFormat}";
    if ((dressSize ?? "").isNotEmpty) url += "&dressSize=$dressSize";
    if ((minHeight ?? "").isNotEmpty) url += "&minHeight=$minHeight";
    if ((maxHeight ?? "").isNotEmpty) url += "&maxHeight=$maxHeight";
    if ((minHourlyRate ?? "").isNotEmpty) {
      url += "&minHourlyRate=$minHourlyRate";
    }
    if ((maxHourlyRate ?? "").isNotEmpty) {
      url += "&maxHourlyRate=$maxHourlyRate";
    }
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
  EitherModel<SocialFeedResponseModel> getSocialFeeds(
      {required SocialFeedRequestModel socialFeedRequestModel}) async {
    String url = "social-feed";

    if (socialFeedRequestModel.socialFeedType == SocialFeedType.public) {
      url +=
          "?active=true&limit=${socialFeedRequestModel.limit}&page=${socialFeedRequestModel.page}";
    } else {
      url +=
          "?user=${socialFeedRequestModel.userId}&limit=${socialFeedRequestModel.limit}&page=${socialFeedRequestModel.page}";
    }
    if (kDebugMode) {
      print(url);
    }
    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<SocialFeedResponseModel>(
      response,
      SocialFeedResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (SocialFeedResponseModel r) => right(r));
  }

  @override
  EitherModel<SocialPostViewIncreaseResponseModel> increasePostView(
      {required String socialPostId}) async {
    String url = "social-feed/view/$socialPostId";
    Response response = await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);
    if (response.statusCode == null) await get(url);

    return _convert<SocialPostViewIncreaseResponseModel>(
      response,
      SocialPostViewIncreaseResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (SocialPostViewIncreaseResponseModel r) => right(r));
  }

  @override
  EitherModel<UserBlockUnblockResponseModel> blockUnblockUser({
    required String userId,
    required String action,
  }) async {
    String url = "users/block-unblock";
    String requestBody = jsonEncode({
      "id": userId,
      "action": action //BLOCK, UNBLOCK
    });

    Response response = await put(url, requestBody);

    return _convert<UserBlockUnblockResponseModel>(
      response,
      UserBlockUnblockResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (UserBlockUnblockResponseModel r) => right(r));
  }

  @override
  Future<Either<CustomError, SocialFeedResponseModel>> searchSocialFeeds({
    required String searchKey,
    int limit = 20,
    int page = 1,
  }) async {
    final String url =
        "social-feed/search?searchKey=$searchKey&limit=$limit&page=$page";

    Response? response;
    int retries = 3;

    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        response = await get(url);

        // If response is valid, break the loop
        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          break;
        }
      } catch (e) {
        // Log the error or handle it as needed
        if (kDebugMode) {
          print("Attempt $attempt failed: $e");
        }
      }

      // Delay before retrying
      if (attempt < retries - 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // If no valid response after retries, return an error
    if (response == null || response.statusCode == null) {
      return left(CustomError(
        errorCode: 500,
        errorFrom: ErrorFrom.api,
        msg: "Failed to fetch social feeds after multiple attempts",
      ));
    }
    log("social search response ${response.body}");
    return _convert<SocialFeedResponseModel>(
      response,
      SocialFeedResponseModel.fromJson,
    ).fold(
      (CustomError error) => left(error),
      (SocialFeedResponseModel feedResponse) => right(feedResponse),
    );
  }

  @override
  EitherModel<CommonResponseModel> reactPost({required String postId}) async {
    String url = "social-feed/like-unlike";
    String requestBody = jsonEncode({"postId": postId});
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
  EitherModel<CommentResponseModel> addComment(
      {required SocialCommentRequestModel socialCommentRequestModel}) async {
    String url = "social-feed/create-comment";
    Response response = await post(url, socialCommentRequestModel.toRawJson());
    if (response.statusCode == null) {
      await post(url, socialCommentRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, socialCommentRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, socialCommentRequestModel.toRawJson());
    }

    return _convert<CommentResponseModel>(
      response,
      CommentResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommentResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> addReport(
      {required SocialPostReportRequestModel
          socialPostReportRequestModel}) async {
    String url = "social-feed/report";
    Response response =
        await post(url, socialPostReportRequestModel.toRawJson());
    if (response.statusCode == null) {
      await post(url, socialPostReportRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, socialPostReportRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, socialPostReportRequestModel.toRawJson());
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> deleteSocialPost(
      {required String postId}) async {
    String url = "social-feed/$postId";
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
  EitherModel<CommonResponseModel> inactiveSocialPost(
      {required String postId, required bool active}) async {
    String url = "social-feed/update/$postId";
    String body = jsonEncode({"active": active});
    Response response = await put(url, body);
    if (response.statusCode == null) await put(url, body);
    if (response.statusCode == null) await put(url, body);
    if (response.statusCode == null) await put(url, body);

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    String url = "social-feed/delete-comment";
    var payload = {
      "postId": postId,
      "id": commentId,
    };

    Response response = await put(url, jsonEncode(payload));
    if (response.statusCode == null) await put(url, jsonEncode(payload));
    if (response.statusCode == null) await put(url, jsonEncode(payload));
    if (response.statusCode == null) await put(url, jsonEncode(payload));

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> updateComment({
    required String postId,
    required String commentId,
    required String newText,
  }) async {
    String url = "social-feed/update-comment";
    var payload = jsonEncode({
      "text": newText,
      "postId": postId,
      "id": commentId,
    });

    Response response = await put(url, payload);
    if (response.statusCode == null) await put(url, payload);
    if (response.statusCode == null) await put(url, payload);
    if (response.statusCode == null) await put(url, payload);

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> addSocialPost(
      {required AddSocialMediaRequestModel addSocialMediaRequestModel}) async {
    String url = "social-feed/create";
    Response response = await post(url, addSocialMediaRequestModel.toRawJson());
    if (response.statusCode == null) {
      await post(url, addSocialMediaRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, addSocialMediaRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, addSocialMediaRequestModel.toRawJson());
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> updateSocialPost(
      {required AddSocialMediaRequestModel addSocialMediaRequestModel,
      required String postId}) async {
    String url = "social-feed/update/$postId";
    Response response = await put(url, addSocialMediaRequestModel.toRawJson());
    if (response.statusCode == null) {
      await put(url, addSocialMediaRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await put(url, addSocialMediaRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await put(url, addSocialMediaRequestModel.toRawJson());
    }
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> repostSocialPost(
      {required RepostRequestModel repostRequestModel}) async {
    String url = "social-feed/repost";
    Response response = await post(url, repostRequestModel.toRawJson());
    if (response.statusCode == null) {
      await post(url, repostRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, repostRequestModel.toRawJson());
    }
    if (response.statusCode == null) {
      await post(url, repostRequestModel.toRawJson());
    }
    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<SocialFeedInfoResponseModel> getSocialPostDetails(
      {required String socialPostId}) async {
    Response response = await get("social-feed/$socialPostId");
    if (response.statusCode == null) {
      response = await get("social-feed/$socialPostId");
    }
    if (response.statusCode == null) {
      response = await get("social-feed/$socialPostId");
    }
    if (response.statusCode == null) {
      response = await get("social-feed/$socialPostId");
    }
    return _convert<SocialFeedInfoResponseModel>(
      response,
      SocialFeedInfoResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (SocialFeedInfoResponseModel r) => right(r));
  }

  @override
  EitherModel<JobPostDetailsResponseModel> getJobPostDetails(
      {required String jobPostId}) async {
    Response response = await get("job/$jobPostId");
    if (response.statusCode == null) {
      response = await get("job/$jobPostId");
    }
    if (response.statusCode == null) {
      response = await get("job/$jobPostId");
    }
    if (response.statusCode == null) {
      response = await get("job/$jobPostId");
    }

    return _convert<JobPostDetailsResponseModel>(
      response,
      JobPostDetailsResponseModel.fromJson,
    ).fold((CustomError l) => left(l),
        (JobPostDetailsResponseModel r) => right(r));
  }

  @override
  EitherModel<CommonResponseModel> deleteNotification(
      {required String notificationId}) async {
    String url = "notifications/$notificationId";
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
  EitherModel<CommonResponseModel> readAllNotification() async {
    String url = "notifications/update-status-all";
    Response response = await put(url, jsonEncode({"readStatus": true}));
    if (response.statusCode == null) {
      await put(url, jsonEncode({"readStatus": true}));
    }
    if (response.statusCode == null) {
      await put(url, jsonEncode({"readStatus": true}));
    }
    if (response.statusCode == null) {
      await put(url, jsonEncode({"readStatus": true}));
    }

    return _convert<CommonResponseModel>(
      response,
      CommonResponseModel.fromJson,
    ).fold((CustomError l) => left(l), (CommonResponseModel r) => right(r));
  }

  @override
  EitherModel<List<SavedPostModel>> getSavedPost() async {
    String url = "social-feed-save";
    var response = await get(url);

    if (response.statusCode == null) {
      response = await get(url);
    }
    return _convert<List<SavedPostModel>>(
      response,
      (json) {
        // Ensure you are accessing the correct key if the list is nested
        var skillsList = json['socialFeeds']['posts'] as List<dynamic>;
        return skillsList.map((item) => SavedPostModel.fromJson(item)).toList();
      },
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<RefreshTokenResponseModel> getRefreshToken(
      {required String currentRefreshToken}) async {
    String url = "users/refresh-token";
    var map= {
      "refreshToken": currentRefreshToken
    };
    Response response = await post(url, map);
    if (kDebugMode) {
      print(response.statusCode.toString());
      print(response.bodyString.toString());
    }
    return _convert<RefreshTokenResponseModel>(
      response,
      RefreshTokenResponseModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }

  @override
  EitherModel<LogoutResponseModel> logout(
      {required String currentRefreshToken}) async {
    String url = "users/logout";
    var map= {
      "refreshToken": currentRefreshToken
    };
    Response response = await post(url, map);
    if (kDebugMode) {
      print(response.statusCode.toString());
      print(response.bodyString.toString());
    }
    return _convert<LogoutResponseModel>(
      response,
      LogoutResponseModel.fromJson,
    ).fold((l) => left(l), (r) => right(r));
  }
}
