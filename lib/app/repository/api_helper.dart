import 'package:mh/app/models/add_social_media_request_model.dart';
import 'package:mh/app/models/alter_user_response_model.dart';
import 'package:mh/app/models/comment_response_model.dart';
import 'package:mh/app/models/hourly_rate_model.dart';
import 'package:mh/app/models/job_post_details_response_model.dart';
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
import 'package:mh/app/modules/client/client_dashboard/models/client_update_status_model.dart';
import 'package:mh/app/modules/client/client_edit_profile/model/client_profile_update.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_bank_info_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/position_info_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/update_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_suggested_employees/models/short_list_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/login.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/login_response.dart';
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
import '../common/utils/exports.dart';
import '../common/utils/type_def.dart';
import '../models/all_admins.dart';
import '../models/check_in_out_histories.dart';
import '../models/client_edit_profile.dart';
import '../models/commons.dart';
import '../models/dropdown_item.dart';
import '../models/employee_full_details.dart';
import '../models/employees_by_id.dart';
import '../models/followers_response_model.dart';
import '../models/lat_long_to_address.dart';
import '../models/launching_message_response_model.dart';
import '../models/requested_employees.dart' as requested_employees;
import '../models/saved_post_model.dart';
import '../models/skills_model.dart';
import '../models/sources.dart';
import '../models/user_block_unblock_response_model.dart';
import '../models/user_profile.dart';
import '../models/user_profile_completion_details.dart';
import '../modules/admin/admin_todays_employees/models/admin_todays_employee_response_model.dart';
import '../modules/client/client_access_control/models/alter_user.dart';
import '../modules/client/client_dashboard/models/confirm_employee_task.dart';
import '../modules/client/client_dashboard/models/current_hired_employees.dart';
import '../modules/client/client_dashboard/models/today_checkOutIn_details_model.dart';
import '../modules/client/client_edit_profile/model/client_bank_update_model.dart';
import '../modules/client/client_edit_profile/model/client_business_update_model.dart';
import '../modules/client/client_payment_and_invoice/model/client_subscription_invoice_details_response_model.dart';
import '../modules/client/client_payment_and_invoice/model/client_subscription_list_response_model.dart';
import '../modules/client/client_shortlisted/models/shortlisted_employees.dart' as short_list_employees;
import '../modules/client/client_subscription_plan/models/client_subscription_plan_details.dart';
import '../modules/client/client_subscription_plan/models/client_subscription_plan_model.dart';
import '../modules/client/client_subscription_plan/models/upgrade_plan_response_model.dart';
import '../modules/client/client_terms_condition_for_hire/models/terms_condition_for_hire.dart';
import '../modules/client/location/models/map_search_model.dart';
import '../modules/client/location/models/saved_search_model.dart';
import '../modules/common_modules/auth/login/model/new_login_response_model.dart';
import '../modules/common_modules/auth/register/models/client_register_response_model.dart';
import '../modules/common_modules/search/models/user_suggestions_model.dart';
import '../modules/employee/employee_edit_profile/models/employee_profile_additional_model.dart';
import '../modules/employee/employee_edit_profile/models/employee_profile_update_model.dart';
import '../modules/employee/employee_home/models/today_check_in_out_details.dart';

abstract class ApiHelper {
  EitherModel<Commons> commons();
  EitherModel<List<DropdownItem>> positions();

  EitherModel<NewLoginResponseModel> login(
    LoginRequestModel login,
  );
  EitherModel<AlterUserResponseModel> createAlternateUser(
    dynamic mapData
  );
  EitherModel<List<AlterUser>> getAlterUsers();

  EitherModel<NewLoginResponseModel> clientRegister(
    ClientSignUpRequestModel clientRegistration,
  );

  EitherModel<NewLoginResponseModel> employeeRegister(
    EmployeeSignUpRequestModel employeeRegistration,
  );

  EitherModel<Response> updateFcmToken({bool isLogin = true});

  // EitherModel<UserInfo> clientDetails(
  //   String id,
  // );

  EitherModel<UserProfileModel> userProfile(
    String id,
  );

  EitherModel<ClientEditProfileModel> clientDetails(
    String id,
  );

  EitherModel<Employees> getAllEmployees();

  EitherModel<MapSearchResponseModel> mapSearch({
    required String address,
    required String lat,
    required String lang,
    required String totalCount,
    required String minRate,
    required String maxRate,
    required String positionId,
    required String radius,
  });

  EitherModel<List<SavedSearchModel>> getSavedSearch();

  EitherModel<CommonResponseModel> deleteMapSearch({required String searchId});

  EitherModel<CommonResponseModel> deleteAllMapSearch({required String userId});

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
  EitherModel<List<SkillModel>> getAllSkills();

  EitherModel<TermsConditionForHire> getTermsConditionForHire();

  EitherModel<short_list_employees.ShortlistedEmployees>
      fetchShortlistEmployees();

  EitherModel<Sources> fetchSources();

  EitherModel<Response> addToShortlist(
      {required AddToShortListRequestModel addToShortListRequestModel});

  EitherModel<Response> updateShortlistItem(
      {required UpdateShortListRequestModel updateShortListRequestModel});

  EitherModel<Response> deleteFromShortlist(String shortlistId);

  EitherModel<Response> hireConfirm(Map<String, dynamic> data);

  EitherModel<LatLngToAddress> latLngToAddress(double lat, double lng);

  EitherModel<Response> addressToLatLng(String query);

  void submitAppError(Map<String, String> data);

  EitherModel<TodayCheckInOutDetails> dailyCheckInCheckoutDetails(
      String employeeId);
  EitherModel<UserProfileCompletionDetails> userProfileCompletionDetails(
      String userId);
  EitherModel<TodayCheckInOutDetailsForClient> getTodayEmployeeList(
      {required DateTime startDate, required DateTime endDate});

  EitherModel<CommonResponseModel> checkIn(
      {required EmployeeCheckInRequestModel employeeCheckInRequestModel});

  EitherModel<Response> confirmEmployeeTask(
      {required ConfirmEmployeeTaskModel confirmEmployeeTaskModel});
  EitherModel<Response> checkout(
      {required EmployeeCheckOutRequestModel employeeCheckOutRequestModel});

  EitherModel<Response> updateCheckInOutByClient(
      {required ClientUpdateStatusModel clientUpdateStatusModel});
  EitherModel<Response> updateClientBankDetails(
      {required ClientBankDetailsModel clientBankDetailsModel});
  EitherModel<Response> updateEmployeeBankDetails(
      {required ClientBankDetailsModel clientBankDetailsModel});
  EitherModel<Response> updateEmployeeAdditionalDetails(
      {required EmployeeProfileAdditionalModel employeeProfileAdditionalModel});

  EitherModel<Response> deleteAccount(Map<String, dynamic> data);
  EitherModel<Response> deleteAccountPermanently(String userId);
  EitherModel<Response> deleteAccountSoftly(Map<String, dynamic> data);
  EitherModel<HiredEmployeesByDate> getHiredEmployeesByDate({String? date});
  EitherModel<ClientSubscriptionListResponseModel> getSubscriptionInvoices();
  EitherModel<ClientSubscriptionInvoiceDetailsResponseModel>
      getSubscriptionInvoicesDetails({required String id});

  EitherModel<TodayCheckInOutDetails> getTodayCheckInOutDetails(
      String employeeId);
  EitherModel<Response> updateEmployeePaymentByClient(
      Map<String, dynamic> data);
  EitherModel<CheckInCheckOutHistory> getCheckInOutHistory({
    String? filterDate,
    String? requestType,
    String? clientId,
    String? employeeId,
  });

  EitherModel<CheckInCheckOutHistory> getEmployeeCheckInOutHistory(
      {String? startDate, String? endDate, int? page, int? limit});

  EitherModel<Response> clientRequestForEmployee(Map<String, dynamic> data);

  EitherModel<requested_employees.RequestedEmployees> getRequestedEmployees(
      {String? clientId});

  EitherModel<Response> addEmployeeAsSuggest(Map<String, dynamic> data);

  EitherModel<EmployeeFullDetails> employeeFullDetails(String id);

  EitherModel<FollowersResponseModel> employeeFollowersDetails(String id);

  EitherModel<Response> followUnfollow(Map<String, dynamic> data);

  EitherModel<Response> toggleNotification(Map<String, dynamic> data);

  EitherModel<LoginResponse> updateClientProfile(
      ClientProfileUpdate clientProfileUpdate);
  EitherModel<ClientRegistrationResponse> updateClientProfile2(
      ClientProfileUpdate clientProfileUpdate);
  EitherModel<ClientRegistrationResponse> updateClientBusiness(
      ClientBusinessUpdate clientBusinessUpdate);
  EitherModel<Response> deleteCertificate(
      {required String userId, required String certificateId});

  EitherModel<Response> updatePaymentStatus(Map<String, dynamic> data);

  EitherModel<NotificationResponseModel> getNotifications({required int page});
  EitherModel<CommonResponseModel> deleteNotification(
      {required String notificationId});

  EitherModel<NotificationUpdateResponseModel> updateNotification(
      {required NotificationUpdateRequestModel notificationUpdateRequestModel});

  EitherModel<BookingHistoryModel> getBookingHistory();

  EitherModel<BookingHistoryModel> cancelClientRequestFromAdmin(
      {required String requestId});

  EitherModel<BookingHistoryModel> cancelEmployeeSuggestionFromAdmin(
      {required String employeeId, required String requestId});

  EitherModel<ReviewDialogModel> showReviewDialog();

  EitherModel<CommonResponseModel> giveReview(
      {required ReviewRequestModel reviewRequestModel});

  EitherModel<CommonResponseModel> addToShortlistNew(
      {required ShortListRequestModel shortListRequestModel});

  EitherModel<CalenderModel> getCalenderData({required String employeeId});

  EitherModel<TodayWorkScheduleModel> getTodayWorkSchedule(String time);

  EitherModel<EmployeeHiredHistoryModel> getHiredHistory();

  EitherModel<SingleBookingDetailsModel> getBookingDetails(
      {required String notificationId});

  EitherModel<Response> updateRequestDate(
      {required RejectedDateRequestModel rejectedDateRequestModel});

  EitherModel<CommonResponseModel> updateUnavailableDate(
      {required UpdateUnavailableDateRequestModel
          updateUnavailableDateRequestModel});

  //EitherModel<ExtraFieldModel> getEmployeeExtraField({required String countryName});
  EitherModel<NationalityModel> getNationalities();
  EitherModel<HourlyRateModel> getHourlyRate();
  EitherModel<CommonResponseModel> changePassword(
      {required ChangePasswordRequestModel changePasswordRequestModel});
  EitherModel<ForgetPasswordResponseModel> inputEmail({required String email});
  EitherModel<CommonResponseModel> otpCheck(
      {required OtpCheckRequestModel otpCheckRequestModel});
  EitherModel<CommonResponseModel> resetPassword(
      {required ResetPasswordRequestModel resetPasswordRequestModel});
  EitherModel<List<UserSuggestionModel>> fetchUserSuggestions({
    required String searchKey,
  });
  EitherModel<List<Job>> searchJobPosts({required String searchKey, int? page});
  EitherModel<SocialFeedResponseModel> searchSocialFeeds({
    required String searchKey,
    int limit = 20,
    int page = 1,
  });

  EitherModel<PositionInfoModel> getPositionInfo({required String positionId});
  EitherModel<TodaysEmployeesModel> getTodaysEmployees(
      {required String startDate,
      required String endDate,
      String? employeeName,
      String? restaurantName,
      String? hiredBy});

  EitherModel<AdminTodaysEmployeeResponseModel> getTodaysEmployeesFromAdmin(
      {required String startDate, required String endDate, String? hiredBy});

  EitherModel<ClientMyEmployeesModel> getClientMyEmployees(
      {bool? allEmployees,
      String? startDate,
      String? endDate,
      required String hiredBy,
      String? employeeId});
  EitherModel<CommonResponseModel> matchEmployee({required String employeeId});
  EitherModel<CommonResponseModel> getSkipDate();
  EitherModel<CommonResponseModel> updateSkipDate();
  EitherModel<ClientBankInfoModel> getBankInfo();
  EitherModel<CommonResponseModel> createJobPost(
      {required CreateJobPostRequestModel createJobPostRequestModel});
  EitherModel<CommonResponseModel> editJobPost(
      {required CreateJobPostRequestModel createJobPostRequestModel});
  EitherModel<JobPostRequestModel> getJobPosts(
      {required String userType,
      required int page,
      String? status,
      bool? isMyJobPost,
      int? limit,
      String? jobPostForUserId});
  EitherModel<CommonResponseModel> deleteJobPost({required String jobId});
  EitherModel<Response> interested(
      {required InterestedRequestModel interestedRequestModel});
  EitherModel<Response> updateLocation(
      {required EmployeeLocationUpdateRequestModel
          employeeLocationUpdateRequestModel});

  EitherModel<Response> userValidation({required String email});
  EitherModel<Response> removeCard();
  EitherModel<SessionIdResponseModel> getSessionId(
      {required String email, required String fromWhere});
  EitherModel<CommonResponseModel> updateRefund(
      {required UpdateRefundModel updateRefundModel});
  EitherModel<ConversationResponseModel> createConversation(
      {required ConversationCreateRequestModel conversationCreateRequestModel});
  EitherModel<ConversationResponseModel> createConversationWithCandidate(
      {required ConversationCreateRequestModel conversationCreateRequestModel});
  EitherModel<MessageResponseModel> getMessages(
      {required MessageRequestModel messageRequestModel});
  EitherModel<Response> sendMessage(
      {required SendMessageRequestModel sendMessageRequestModel});
  EitherModel<Response> updateEmployeeBio(
      {required BioRequestModel bioRequestModel});
  EitherModel<Response> updateEmployeeProfile(
      {required EmployeeProfileRequestModel employeeProfileRequestModel});
  EitherModel<UnreadMessageResponseModel> getUnreadMessages();
  EitherModel<ChatItModel> getConversations({int? pageNumber, int? limit, bool unread});
  EitherModel<CommonResponseModel> deleteConversation(
      {required String conversationId});
  EitherModel<CommonResponseModel> checkSubscription();
  EitherModel<SubscriptionPlanResponseModel> getSubscriptionPlans();
  EitherModel<CommonResponseModel> addNewSubscription(
      {required SubscriptionAddRequestModel subscriptionAddRequestModel});

  //Social Feed
  EitherModel<SocialFeedResponseModel> getSocialFeeds(
      {required SocialFeedRequestModel socialFeedRequestModel});
  EitherModel<CommonResponseModel> reactPost({required String postId});
  EitherModel<UserBlockUnblockResponseModel> blockUnblockUser(
      {required String userId, required String action});
  EitherModel<CommentResponseModel> addComment(
      {required SocialCommentRequestModel socialCommentRequestModel});
  EitherModel<CommonResponseModel> addReport(
      {required SocialPostReportRequestModel socialPostReportRequestModel});
  EitherModel<CommonResponseModel> inactiveSocialPost(
      {required String postId, required bool active});
  EitherModel<CommonResponseModel> deleteSocialPost({required String postId});
  EitherModel<CommonResponseModel> deleteComment({
    required String postId,
    required String commentId,
  });
  EitherModel<CommonResponseModel> addSocialPost(
      {required AddSocialMediaRequestModel addSocialMediaRequestModel});
  EitherModel<CommonResponseModel> updateSocialPost(
      {required AddSocialMediaRequestModel addSocialMediaRequestModel,
      required String postId});
  EitherModel<CommonResponseModel> updateComment({
    required String postId,
    required String commentId,
    required String newText,
  });
  EitherModel<CommonResponseModel> repostSocialPost(
      {required RepostRequestModel repostRequestModel});
  EitherModel<SocialFeedInfoResponseModel> getSocialPostDetails(
      {required String socialPostId});
  EitherModel<void> increasePostView({required String socialPostId});
  EitherModel<JobPostDetailsResponseModel> getJobPostDetails(
      {required String jobPostId});
  EitherModel<CommonResponseModel> readAllNotification();
  EitherModel<List<SavedPostModel>> getSavedPost();
  EitherModel<ClientSubscriptionPlanModel> getClientSubscriptionPlanList();
  EitherModel<ClientSubscriptionPlanDetails> getClientSubscriptionDetails(
      {required String userId});
  EitherModel<UpgradePlanResponseModel> upgradePlan({required payLoad});
  EitherModel<LaunchingMessageResponseModel> getLaunchingMessage();
  EitherModel<RefreshTokenResponseModel> getRefreshToken({required String currentRefreshToken});
  EitherModel<LogoutResponseModel> logout({required String currentRefreshToken});
}
