import 'package:mh/app/models/hourly_rate_model.dart';
import 'package:mh/app/models/nationality_model.dart';
import 'package:mh/app/modules/admin/admin_dashboard/models/update_refund_model.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/models/todays_employees_model.dart';
import 'package:mh/app/modules/auth/register/models/employee_extra_field_model.dart';
import 'package:mh/app/modules/calender/models/calender_model.dart';
import 'package:mh/app/modules/calender/models/update_unavailable_date_request_model.dart';
import 'package:mh/app/modules/chat_it/models/chat_it_model.dart';
import 'package:mh/app/modules/client/card_add/models/session_id_response_model.dart';
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
import 'package:mh/app/modules/employee/employee_self_profile/models/bio_request_model.dart';
import 'package:mh/app/modules/employee_booked_history_details/models/rejected_date_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/live_chat/models/message_request_model.dart';
import 'package:mh/app/modules/live_chat/models/message_response_model.dart';
import 'package:mh/app/modules/live_chat/models/send_message_request_model.dart';
import 'package:mh/app/modules/live_chat/models/unread_message_response_model.dart';
import 'package:mh/app/modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/notifications/models/notification_update_request_model.dart';
import 'package:mh/app/modules/notifications/models/notification_update_response_model.dart';
import 'package:mh/app/modules/otp/models/otp_check_request_model.dart';
import 'package:mh/app/modules/reset_password/models/reset_password_request_model.dart';
import 'package:mh/app/modules/settings/models/change_password_request_model.dart';
import 'package:mh/app/modules/stripe_payment/models/stripe_request_model.dart';
import 'package:mh/app/modules/stripe_payment/models/stripe_response_model.dart';

import '../common/utils/exports.dart';
import '../common/utils/type_def.dart';
import '../models/all_admins.dart';
import '../models/check_in_out_histories.dart';
import '../models/commons.dart';
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
import '../modules/client/client_self_profile/model/client_profile_update.dart';
import '../modules/client/client_shortlisted/models/shortlisted_employees.dart' as short_list_employees;
import '../modules/client/client_terms_condition_for_hire/models/terms_condition_for_hire.dart';
import '../modules/employee/employee_home/models/today_check_in_out_details.dart';

abstract class ApiHelper {
  EitherModel<Commons> commons();

  EitherModel<LoginResponse> login(
    Login login,
  );

  EitherModel<ClientRegistrationResponse> clientRegister(
    ClientRegistration clientRegistration,
  );

  EitherModel<ClientRegistrationResponse> employeeRegister(
    EmployeeRegistration employeeRegistration,
  );

  EitherModel<Response> updateFcmToken({bool isLogin = true});

  EitherModel<UserInfo> clientDetails(
    String id,
  );

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
      String? maxHourlyRate});

  EitherModel<Employees> getAllUsersFromAdmin(
      {String? positionId,
      String? rating,
       int? pageNumber,
      String? employeeExperience,
      String? minTotalHour,
      String? maxTotalHour,
      bool? isReferred,
      String? requestType,
      bool? active});

  EitherModel<AllAdmins> getAllAdmins();

  EitherModel<TermsConditionForHire> getTermsConditionForHire();

  EitherModel<short_list_employees.ShortlistedEmployees> fetchShortlistEmployees();

  EitherModel<Sources> fetchSources();

  EitherModel<Response> addToShortlist({required AddToShortListRequestModel addToShortListRequestModel});

  EitherModel<Response> updateShortlistItem({required UpdateShortListRequestModel updateShortListRequestModel});

  EitherModel<Response> deleteFromShortlist(String shortlistId);

  EitherModel<Response> hireConfirm(Map<String, dynamic> data);

  EitherModel<LatLngToAddress> latLngToAddress(double lat, double lng);

  EitherModel<Response> addressToLatLng(String query);

  void submitAppError(Map<String, String> data);

  EitherModel<TodayCheckInOutDetails> dailyCheckInCheckoutDetails(String employeeId);

  EitherModel<CommonResponseModel> checkIn({required EmployeeCheckInRequestModel employeeCheckInRequestModel});

  EitherModel<Response> checkout({required EmployeeCheckOutRequestModel employeeCheckOutRequestModel});

  EitherModel<Response> updateCheckInOutByClient({required ClientUpdateStatusModel clientUpdateStatusModel});

  EitherModel<Response> deleteAccount(Map<String, dynamic> data);

  EitherModel<HiredEmployeesByDate> getHiredEmployeesByDate({String? date});

  EitherModel<TodayCheckInOutDetails> getTodayCheckInOutDetails(String employeeId);

  EitherModel<CheckInCheckOutHistory> getCheckInOutHistory({
    String? filterDate,
    String? requestType,
    String? clientId,
    String? employeeId,
  });

  EitherModel<CheckInCheckOutHistory> getEmployeeCheckInOutHistory(
      {String? startDate, String? endDate, int? page, int? limit});

  EitherModel<Response> clientRequestForEmployee(Map<String, dynamic> data);

  EitherModel<requested_employees.RequestedEmployees> getRequestedEmployees({String? clientId});

  EitherModel<Response> addEmployeeAsSuggest(Map<String, dynamic> data);

  EitherModel<EmployeeFullDetails> employeeFullDetails(String id);

  EitherModel<ClientRegistrationResponse> updateClientProfile(ClientProfileUpdate clientProfileUpdate);

  EitherModel<Response> updatePaymentStatus(Map<String, dynamic> data);

  EitherModel<NotificationResponseModel> getNotifications();

  EitherModel<NotificationUpdateResponseModel> updateNotification(
      {required NotificationUpdateRequestModel notificationUpdateRequestModel});

  EitherModel<BookingHistoryModel> getBookingHistory();

  EitherModel<BookingHistoryModel> cancelClientRequestFromAdmin({required String requestId});

  EitherModel<BookingHistoryModel> cancelEmployeeSuggestionFromAdmin(
      {required String employeeId, required String requestId});

  EitherModel<StripeResponseModel> stripePayment({required StripeRequestModel stripeRequestModel});

  EitherModel<ReviewDialogModel> showReviewDialog();

  EitherModel<CommonResponseModel> giveReview({required ReviewRequestModel reviewRequestModel});

  EitherModel<CommonResponseModel> addToShortlistNew({required ShortListRequestModel shortListRequestModel});

  EitherModel<CalenderModel> getCalenderData({required String employeeId});

  EitherModel<TodayWorkScheduleModel> getTodayWorkSchedule();

  EitherModel<EmployeeHiredHistoryModel> getHiredHistory();

  EitherModel<SingleBookingDetailsModel> getBookingDetails({required String notificationId});

  EitherModel<Response> updateRequestDate({required RejectedDateRequestModel rejectedDateRequestModel});

  EitherModel<CommonResponseModel> updateUnavailableDate(
      {required UpdateUnavailableDateRequestModel updateUnavailableDateRequestModel});

  EitherModel<ExtraFieldModel> getEmployeeExtraField({required String countryName});
  EitherModel<NationalityModel> getNationalities();
  EitherModel<HourlyRateModel> getHourlyRate();
  EitherModel<CommonResponseModel> changePassword({required ChangePasswordRequestModel changePasswordRequestModel});
  EitherModel<ForgetPasswordResponseModel> inputEmail({required String email});
  EitherModel<CommonResponseModel> otpCheck({required OtpCheckRequestModel otpCheckRequestModel});
  EitherModel<CommonResponseModel> resetPassword({required ResetPasswordRequestModel resetPasswordRequestModel});
  EitherModel<PositionInfoModel> getPositionInfo({required String positionId});
  EitherModel<TodaysEmployeesModel> getTodaysEmployees(
      {required String startDate, required String endDate, String? employeeName, String? restaurantName});
  EitherModel<ClientMyEmployeesModel> getClientMyEmployees(
      {String? startDate, String? endDate, required String hiredBy, String? employeeId});
  EitherModel<CommonResponseModel> matchEmployee({required String employeeId});
  EitherModel<CommonResponseModel> getSkipDate();
  EitherModel<CommonResponseModel> updateSkipDate();
  EitherModel<ClientBankInfoModel> getBankInfo();
  EitherModel<CommonResponseModel> createJobPost({required CreateJobPostRequestModel createJobPostRequestModel});
  EitherModel<CommonResponseModel> editJobPost({required CreateJobPostRequestModel createJobPostRequestModel});
  EitherModel<JobPostRequestModel> getJobRequests({String? userType, String? clientId, String? status});
  EitherModel<CommonResponseModel> deleteJobPost({required String jobId});
  EitherModel<Response> interested({required InterestedRequestModel interestedRequestModel});
  EitherModel<Response> updateLocation(
      {required EmployeeLocationUpdateRequestModel employeeLocationUpdateRequestModel});

  EitherModel<Response> userValidation({required String email});
  EitherModel<Response> removeCard();
  EitherModel<SessionIdResponseModel> getSessionId({required String email, required String fromWhere});
  EitherModel<CommonResponseModel> updateRefund({required UpdateRefundModel updateRefundModel});
  EitherModel<ConversationResponseModel> createConversation(
      {required ConversationCreateRequestModel conversationCreateRequestModel});
  EitherModel<MessageResponseModel> getMessages({required MessageRequestModel messageRequestModel});
  EitherModel<Response> sendMessage({required SendMessageRequestModel sendMessageRequestModel});
  EitherModel<UnreadMessageResponseModel> getUnreadMessage({required String conversationId});
  EitherModel<Response> updateEmployeeBio({required BioRequestModel bioRequestModel});
  EitherModel<ChatItModel> getConversations();
}
