import 'package:get/get.dart';
import 'package:mh/app/modules/admin/admin_root/bindings/admin_root_binding.dart';
import 'package:mh/app/modules/admin/chat_it/bindings/chat_it_binding.dart';
import 'package:mh/app/modules/admin/chat_it/views/chat_it_view.dart';
import 'package:mh/app/modules/client/client_edit_profile/bindings/client_edit_profile_binding.dart';
import 'package:mh/app/modules/client/client_edit_profile/views/client_edit_profile_view.dart';
import 'package:mh/app/modules/client/client_home_premium/bindings/client_home_premium_binding.dart';
import 'package:mh/app/modules/client/client_home_premium/views/client_home_premium_view.dart';
import 'package:mh/app/modules/client/client_premium_root/bindings/client_premium_root_binding.dart';
import 'package:mh/app/modules/client/client_premium_root/views/client_premium_root_view.dart';
import 'package:mh/app/modules/client/client_profile/bindings/client_profile_binding.dart';
import 'package:mh/app/modules/client/client_profile/views/client_profile_view.dart';
import 'package:mh/app/modules/client/client_search/views/client_search_view.dart';
import 'package:mh/app/modules/client/client_subscription_plan/bindings/client_subscription_plan_binding.dart';
import 'package:mh/app/modules/client/restaurant_location/bindings/restaurant_location_binding.dart';
import 'package:mh/app/modules/client/restaurant_location/views/restaurant_location_view.dart';
import 'package:mh/app/modules/common_modules/auth/login/bindings/login_binding.dart';
import 'package:mh/app/modules/common_modules/auth/login/views/login_view.dart';
import 'package:mh/app/modules/common_modules/auth/login_register_hints/bindings/login_register_hints_binding.dart';
import 'package:mh/app/modules/common_modules/auth/login_register_hints/views/login_register_hints_view.dart';
import 'package:mh/app/modules/common_modules/auth/register/bindings/register_binding.dart';
import 'package:mh/app/modules/common_modules/auth/register/views/register_view.dart';
import 'package:mh/app/modules/common_modules/blocking/bindings/blocking_binding.dart';
import 'package:mh/app/modules/common_modules/blocking/views/blocking_view.dart';
import 'package:mh/app/modules/common_modules/calender/bindings/calender_binding.dart';
import 'package:mh/app/modules/common_modules/contact_us/bindings/contact_us_binding.dart';
import 'package:mh/app/modules/common_modules/contact_us/views/contact_us_view.dart';
import 'package:mh/app/modules/common_modules/create_post/bindings/create_post_binding.dart';
import 'package:mh/app/modules/common_modules/dialogflow/views/dialog_flow_view.dart';
import 'package:mh/app/modules/common_modules/email_input/bindings/email_input_binding.dart';
import 'package:mh/app/modules/common_modules/email_input/views/email_input_view.dart';
import 'package:mh/app/modules/common_modules/individual_social_feeds/bindings/individual_social_feeds_binding.dart';
import 'package:mh/app/modules/common_modules/individual_social_feeds/views/individual_social_feeds_view.dart';
import 'package:mh/app/modules/common_modules/job_post_details/bindings/job_request_details_binding.dart';
import 'package:mh/app/modules/common_modules/job_post_details/views/job_post_details_view.dart';
import 'package:mh/app/modules/common_modules/live_chat/bindings/live_chat_binding.dart';
import 'package:mh/app/modules/common_modules/live_chat/views/live_chat_view.dart';
import 'package:mh/app/modules/common_modules/my_social_feed/bindings/my_social_feed_binding.dart';
import 'package:mh/app/modules/common_modules/my_social_feed/views/my_social_feed_view.dart';
import 'package:mh/app/modules/common_modules/notifications/bindings/notifications_binding.dart';
import 'package:mh/app/modules/common_modules/notifications/views/notifications_view.dart';
import 'package:mh/app/modules/common_modules/otp/bindings/otp_binding.dart';
import 'package:mh/app/modules/common_modules/otp/views/otp_view.dart';
import 'package:mh/app/modules/common_modules/policy/bindings/policy_binding.dart';
import 'package:mh/app/modules/common_modules/policy/views/policy_view.dart';
import 'package:mh/app/modules/common_modules/reset_password/bindings/reset_password_binding.dart';
import 'package:mh/app/modules/common_modules/reset_password/views/reset_password_view.dart';
import 'package:mh/app/modules/common_modules/settings/bindings/settings_binding.dart';
import 'package:mh/app/modules/common_modules/settings/views/settings_view.dart';
import 'package:mh/app/modules/common_modules/social_post_details/bindings/social_post_details_binding.dart';
import 'package:mh/app/modules/common_modules/social_post_details/views/social_post_details_view.dart';
import 'package:mh/app/modules/common_modules/splash/bindings/splash_binding.dart';
import 'package:mh/app/modules/common_modules/splash/views/splash_view.dart';
import 'package:mh/app/modules/common_modules/terms_and_condition/bindings/terms_and_condition_binding.dart';
import 'package:mh/app/modules/common_modules/terms_and_condition/views/terms_and_condition_view.dart';
import 'package:mh/app/modules/employee/employee_booked_history/bindings/employee_booked_history_binding.dart';
import 'package:mh/app/modules/employee/employee_booked_history/views/employee_booked_history_view.dart';
import 'package:mh/app/modules/employee/employee_booked_history_details/bindings/employee_booked_history_details_binding.dart';
import 'package:mh/app/modules/employee/employee_booked_history_details/views/employee_booked_history_details_view.dart';
import 'package:mh/app/modules/employee/employee_edit_profile/bindings/employee_edit_profile_binding.dart';
import 'package:mh/app/modules/employee/employee_hired_history/bindings/employee_hired_history_binding.dart';
import 'package:mh/app/modules/employee/employee_hired_history/views/employee_hired_history_view.dart';
import 'package:mh/app/modules/employee/employee_plagit_plus/bindings/employee_plagit_plus_binding.dart';
import 'package:mh/app/modules/employee/employee_plagit_plus/views/employee_plagit_plus_view.dart';
import 'package:mh/app/modules/employee/employee_profile/bindings/employee_profile_binding.dart';
import 'package:mh/app/modules/employee/employee_profile/views/employee_profile_view.dart';
import 'package:mh/app/modules/employee/employee_root/bindings/employee_root_binding.dart';
import 'package:mh/app/modules/employee/employee_root/views/employee_root_view.dart';
import '../middleware/auth_middleware.dart';
import '../modules/admin/add_chat_user/bindings/add_chat_user_binding.dart';
import '../modules/admin/add_chat_user/views/add_chat_user_view.dart';
import '../modules/admin/admin_all_clients/bindings/admin_all_clients_binding.dart';
import '../modules/admin/admin_all_clients/views/admin_all_clients_view.dart';
import '../modules/admin/admin_all_employees/bindings/admin_all_employees_binding.dart';
import '../modules/admin/admin_all_employees/views/admin_all_employees_view.dart';
import '../modules/admin/admin_client_request/bindings/admin_client_request_binding.dart';
import '../modules/admin/admin_client_request/views/admin_client_request_view.dart';
import '../modules/admin/admin_client_request_position_employees/bindings/admin_client_request_position_employees_binding.dart';
import '../modules/admin/admin_client_request_position_employees/views/admin_client_request_position_employees_view.dart';
import '../modules/admin/admin_client_request_positions/bindings/admin_client_request_positions_binding.dart';
import '../modules/admin/admin_client_request_positions/views/admin_client_request_positions_view.dart';
import '../modules/admin/admin_dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin/admin_dashboard/views/admin_dashboard_view.dart';
import '../modules/admin/admin_home/bindings/admin_home_binding.dart';
import '../modules/admin/admin_home/views/admin_home_view.dart';
import '../modules/admin/admin_root/views/admin_root_view.dart';
import '../modules/admin/admin_search/bindings/admin_search_binding.dart';
import '../modules/admin/admin_todays_employees/bindings/admin_todays_employees_binding.dart';
import '../modules/admin/admin_todays_employees/views/admin_todays_employees_view.dart';
import '../modules/client/card_add/bindings/card_add_binding.dart';
import '../modules/client/card_add/views/card_add_view.dart';
import '../modules/client/client_access_control/bindings/client_access_control_binding.dart';
import '../modules/client/client_access_control/views/client_access_control_view.dart';
import '../modules/client/client_dashboard/bindings/client_dashboard_binding.dart';
import '../modules/client/client_dashboard/views/client_dashboard_view.dart';
import '../modules/client/client_my_employee/bindings/client_my_employee_binding.dart';
import '../modules/client/client_my_employee/views/client_my_employee_view.dart';
import '../modules/client/client_payment_and_invoice/bindings/client_payment_and_invoice_binding.dart';
import '../modules/client/client_payment_and_invoice/views/client_payment_and_invoice_view.dart';
import '../modules/client/client_request_for_employee/bindings/client_request_for_employee_binding.dart';
import '../modules/client/client_request_for_employee/views/client_request_for_employee_view.dart';
import '../modules/client/client_saved_post/bindings/client_saved_post_binding.dart';
import '../modules/client/client_saved_post/views/client_saved_post_view.dart';
import '../modules/client/client_shortlisted/bindings/client_shortlisted_binding.dart';
import '../modules/client/client_shortlisted/views/client_shortlisted_view.dart';
import '../modules/client/client_subscription_plan/views/client_subscription_plan_view.dart';
import '../modules/client/client_suggested_employees/bindings/client_suggested_employees_binding.dart';
import '../modules/client/client_suggested_employees/views/client_suggested_employees_view.dart';
import '../modules/client/client_terms_condition_for_hire/bindings/client_terms_condition_for_hire_binding.dart';
import '../modules/client/client_terms_condition_for_hire/views/client_terms_condition_for_hire_view.dart';
import '../modules/client/create_job_post/bindings/create_job_post_binding.dart';
import '../modules/client/create_job_post/views/create_job_post_view.dart';
import '../modules/client/employee_details/bindings/employee_details_binding.dart';
import '../modules/client/employee_details/views/employee_details_view.dart';
import '../modules/client/hire_status/bindings/hire_status_binding.dart';
import '../modules/client/hire_status/views/hire_status_view.dart';
import '../modules/client/invoice_pdf/bindings/invoice_pdf_binding.dart';
import '../modules/client/invoice_pdf/views/invoice_pdf_view.dart';
import '../modules/client/live_location/bindings/live_location_binding.dart';
import '../modules/client/live_location/views/live_location_view.dart';
import '../modules/client/location/bindings/location_binding.dart';
import '../modules/client/location/views/location_view.dart';
import '../modules/client/mh_employees/bindings/mh_employees_binding.dart';
import '../modules/client/mh_employees/views/mh_employees_view.dart';
import '../modules/client/mh_employees_by_id/bindings/mh_employees_by_id_binding.dart';
import '../modules/client/mh_employees_by_id/views/mh_employees_by_id_view.dart';
import '../modules/common_modules/about-us/binding/about-us-binding.dart';
import '../modules/common_modules/about-us/view/about-us-view.dart';
import '../modules/common_modules/calender/views/calender_view.dart';
import '../modules/common_modules/common_job_posts/bindings/common_job_posts_bindings.dart';
import '../modules/common_modules/common_job_posts/view/common_job_posts_view.dart';
import '../modules/common_modules/create_post/views/create_post.dart';
import '../modules/common_modules/create_post/views/update_post_view.dart';
import '../modules/common_modules/dialogflow/bindings/dialog_flow_binding.dart';
import '../modules/common_modules/language/bindings/language_binding.dart';
import '../modules/common_modules/language/views/language_view.dart';
import '../modules/common_modules/search/bindings/common_search_binding.dart';
import '../modules/common_modules/search/views/common_search_view.dart';
import '../modules/common_modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/common_modules/user_profile/views/user_profile_view.dart';
import '../modules/employee/employee_dashboard/bindings/employee_dashboard_binding.dart';
import '../modules/employee/employee_dashboard/views/employee_dashboard_view.dart';
import '../modules/employee/employee_edit_profile/views/employee_edit_profile_view.dart';
import '../modules/employee/employee_home/bindings/employee_home_binding.dart';
import '../modules/employee/employee_home/views/employee_home_view.dart';
import '../modules/employee/employee_payment_history/bindings/employee_payment_history_binding.dart';
import '../modules/employee/employee_payment_history/views/employee_payment_history_view.dart';
import '../modules/employee/employee_register_success/bindings/employee_register_success_binding.dart';
import '../modules/employee/employee_register_success/views/employee_register_success_view.dart';
import '../modules/employee/employee_search/views/employee_search_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const splash = Routes.splash;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.loginRegisterHints,
      page: () => const LoginRegisterHintsView(),
      binding: LoginRegisterHintsBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.adminHome,
      page: () => AdminHomeView(),
      binding: AdminHomeBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.adminAllClients,
      page: () => const AdminAllClientsView(),
      binding: AdminAllClientsBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.adminAllEmployees,
      page: () => const AdminAllEmployeesView(),
      binding: AdminAllEmployeesBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.adminClientRequest,
      page: () => const AdminClientRequestView(),
      binding: AdminClientRequestBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.adminClientRequestPositions,
      page: () => const AdminClientRequestPositionsView(),
      binding: AdminClientRequestPositionsBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.adminClientRequestPositionEmployees,
      page: () => const AdminClientRequestPositionEmployeesView(),
      binding: AdminClientRequestPositionEmployeesBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.employeeHome,
      page: () => const EmployeeHomeView(),
      binding: EmployeeHomeBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.employeeDashboard,
      page: () => const EmployeeDashboardView(),
      binding: EmployeeDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientMyEmployee,
      page: () => const ClientMyEmployeeView(),
      binding: ClientMyEmployeeBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientDashboard,
      page: () => const ClientDashboardView(),
      binding: ClientDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientPaymentAndInvoice,
      page: () => const ClientPaymentAndInvoiceView(),
      binding: ClientPaymentAndInvoiceBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientShortlisted,
      page: () => const ClientShortlistedView(),
      binding: ClientShortlistedBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientTermsConditionForHire,
      page: () => const ClientTermsConditionForHireView(),
      binding: ClientTermsConditionForHireBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientEditProfile,
      page: () => ClientEditProfileView(),
      binding: ClientEditProfileBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientAccessControl,
      page: () => ClientAccessControlView(),
      binding: ClientAccessControlBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientRequestForEmployee,
      page: () => const ClientRequestForEmployeeView(),
      binding: ClientRequestForEmployeeBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.clientSuggestedEmployees,
      page: () => const ClientSuggestedEmployeesView(),
      binding: ClientSuggestedEmployeesBinding(),
    ),
    GetPage(
      name: _Paths.hireStatus,
      page: () => const HireStatusView(),
      binding: HireStatusBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.mhEmployees,
      page: () => const MhEmployeesView(),
      binding: MhEmployeesBinding(),
    ),
    GetPage(
      name: _Paths.mhEmployeesById,
      page: () => const MhEmployeesByIdView(),
      binding: MhEmployeesByIdBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.employeeDetails,
      page: () => const EmployeeDetailsView(),
      binding: EmployeeDetailsBinding(),
    ),
    GetPage(
      name: _Paths.employeeRegisterSuccess,
      page: () => const EmployeeRegisterSuccessView(),
      binding: EmployeeRegisterSuccessBinding(),
    ),
    GetPage(
      name: _Paths.employeeEditProfile,
      page: () => EmployeeEditProfileView(),
      binding: EmployeeEditProfileBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.termsAndCondition,
      page: () => const TermsAndConditionView(),
      binding: TermsAndConditionBinding(),
    ),
    GetPage(
      name: _Paths.contactUs,
      page: () => const ContactUsView(),
      binding: ContactUsBinding(),
    ),
    GetPage(
      name: _Paths.blocking,
      page: () => const BlockingView(),
      binding: BlockingBinding(),
    ),
    GetPage(
      name: _Paths.restaurantLocation,
      page: () => const RestaurantLocationView(),
      binding: RestaurantLocationBinding(),
    ),
    GetPage(
      name: _Paths.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.invoicePdf,
      page: () => const InvoicePdfView(),
      binding: InvoicePdfBinding(),
    ),
    GetPage(
      name: _Paths.employeePaymentHistory,
      page: () => const EmployeePaymentHistoryView(),
      binding: EmployeePaymentHistoryBinding(),
    ),
    GetPage(
      name: _Paths.calender,
      page: () => const CalendarView(),
      binding: CalenderBinding(),
    ),
    GetPage(
      name: _Paths.employeeBookedHistory,
      page: () => const EmployeeBookedHistoryView(),
      binding: EmployeeBookedHistoryBinding(),
    ),
    GetPage(
      name: _Paths.employeeHiredHistory,
      page: () => const EmployeeHiredHistoryView(),
      binding: EmployeeHiredHistoryBinding(),
    ),
    GetPage(
      name: _Paths.employeeBookedHistoryDetails,
      page: () => const EmployeeBookedHistoryDetailsView(),
      binding: EmployeeBookedHistoryDetailsBinding(),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.emailInput,
      page: () => const EmailInputView(),
      binding: EmailInputBinding(),
    ),
    GetPage(
      name: _Paths.otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.resetPassword,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.adminTodaysEmployees,
      page: () => const AdminTodaysEmployeesView(),
      binding: AdminTodaysEmployeesBinding(),
    ),
    GetPage(
      name: _Paths.liveLocation,
      page: () => const LiveLocationView(),
      binding: LiveLocationBinding(),
    ),
    GetPage(
      name: _Paths.createJobPost,
      page: () => const CreateJobPostView(),
      binding: CreateJobPostBinding(),
    ),
    GetPage(
      name: _Paths.jobPostDetails,
      page: () => const JobPostDetailsView(),
      binding: JobPostDetailsBinding(),
    ),
    GetPage(
      name: _Paths.cardAdd,
      page: () => const CardAddView(),
      binding: CardAddBinding(),
    ),
    GetPage(
      name: _Paths.liveChat,
      page: () => const LiveChatView(),
      binding: LiveChatBinding(),
    ),
    GetPage(
      name: _Paths.chatIt,
      page: () => const ChatItView(),
      binding: ChatItBinding(),
    ),
    GetPage(
      name: _Paths.addChatUser,
      page: () => const AddChatUserView(),
      binding: AddChatUserBinding(),
    ),
    GetPage(
      name: _Paths.policy,
      page: () => const PolicyView(),
      binding: PolicyBinding(),
    ),
    GetPage(
      name: _Paths.employeeRoot,
      page: () => const EmployeeRootView(),
      binding: EmployeeRootBinding(),
    ),
    GetPage(
      name: _Paths.employeeProfile,
      page: () => EmployeeProfileView(),
      binding: EmployeeProfileBinding(),
    ),
    GetPage(
      name: _Paths.employeePlagitPlus,
      page: () => const EmployeePlagitPlusView(),
      binding: EmployeePlagitPlusBinding(),
    ),
    GetPage(
      name: _Paths.createPost,
      page: () => const NewCreatePostView(),
      binding: CreatePostBinding(),
    ),
    GetPage(
      name: _Paths.updatePost,
      page: () => const UpdatePostView(),
      binding: CreatePostBinding(),
    ),
    GetPage(
      name: _Paths.clientHomePremium,
      page: () => ClientHomePremiumView(),
      binding: ClientHomePremiumBinding(),
    ),
    GetPage(
      name: _Paths.clientPremiumRoot,
      page: () => const ClientPremiumRootView(),
      binding: ClientPremiumRootBinding(),
    ),
    GetPage(
      name: _Paths.clientSearch,
      page: () => const ClientSearchView(),
      binding: ClientPremiumRootBinding(),
    ),
    GetPage(
      name: _Paths.clientProfile,
      page: () => ClientProfileView(),
      binding: ClientProfileBinding(),
    ),
    GetPage(
      name: _Paths.adminRoot,
      page: () => const AdminRootView(),
      binding: AdminRootBinding(),
    ),
    GetPage(
      name: _Paths.mySocialFeeds,
      page: () => const MySocialFeedView(),
      binding: MySocialFeedBinding(),
    ),
    GetPage(
      name: _Paths.individualSocialFeeds,
      page: () => const IndividualSocialFeedsView(),
      binding: IndividualSocialFeedsBinding(),
    ),
    GetPage(
      name: _Paths.socialPostDetails,
      page: () => const SocialPostDetailsView(),
      binding: SocialPostDetailsBinding(),
    ),
    GetPage(
      name: _Paths.aboutUs,
      page: () => const AboutUsDetailsView(),
      binding: AboutUsBinding(),
    ),
    GetPage(
      name: '/employee-search',
      page: () => EmployeeSearchView(),
      binding: AdminSearchBinding(),
    ),
    GetPage(
      name: _Paths.commonJobPosts,
      page: () => CommonJobPostsView(
        userType: 'client',
      ),
      binding: CommonJobPostsBinding(),
    ),
    GetPage(
      name: _Paths.commonSearch,
      page: () => CommonSearchView(),
      binding: CommonSearchBinding(),
    ),
    GetPage(
      name: _Paths.clientSavedPost,
      page: () => ClientSavedPostView(),
      binding: ClientSavedPostBinding(),
    ),
    GetPage(
      name: _Paths.chatBot,
      page: () => DialogFlowView(),
      binding: DialogFlowBinding(),
    ),
    GetPage(
      name: Routes.location,
      page: () => LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: _Paths.clientSubscriptionPlans,
      page: () => ClientSubscriptionPlanView(),
      binding: ClientSubscriptionPlanBinding(),
    ),
    GetPage(
      name: _Paths.language,
      page: () => LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: _Paths.userProfile,
      page: () => UserProfileView(),
      binding: UserProfileBinding(),
    ),
  ];
}
