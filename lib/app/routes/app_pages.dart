import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';
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
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/login_register_hints/bindings/login_register_hints_binding.dart';
import '../modules/auth/login_register_hints/views/login_register_hints_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/calender/bindings/calender_binding.dart';
import '../modules/calender/views/calender_view.dart';
import '../modules/chat/client_employee_chat/bindings/client_employee_chat_binding.dart';
import '../modules/chat/client_employee_chat/views/client_employee_chat_view.dart';
import '../modules/chat/support_chat/bindings/support_chat_binding.dart';
import '../modules/chat/support_chat/views/support_chat_view.dart';
import '../modules/client/client_dashboard/bindings/client_dashboard_binding.dart';
import '../modules/client/client_dashboard/views/client_dashboard_view.dart';
import '../modules/client/client_home/bindings/client_home_binding.dart';
import '../modules/client/client_home/views/client_home_view.dart';
import '../modules/client/client_my_employee/bindings/client_my_employee_binding.dart';
import '../modules/client/client_my_employee/views/client_my_employee_view.dart';
import '../modules/client/client_payment_and_invoice/bindings/client_payment_and_invoice_binding.dart';
import '../modules/client/client_payment_and_invoice/views/client_payment_and_invoice_view.dart';
import '../modules/client/client_request_for_employee/bindings/client_request_for_employee_binding.dart';
import '../modules/client/client_request_for_employee/views/client_request_for_employee_view.dart';
import '../modules/client/client_self_profile/bindings/client_self_profile_binding.dart';
import '../modules/client/client_self_profile/views/client_self_profile_view.dart';
import '../modules/client/client_shortlisted/bindings/client_shortlisted_binding.dart';
import '../modules/client/client_shortlisted/views/client_shortlisted_view.dart';
import '../modules/client/client_suggested_employees/bindings/client_suggested_employees_binding.dart';
import '../modules/client/client_suggested_employees/views/client_suggested_employees_view.dart';
import '../modules/client/client_terms_condition_for_hire/bindings/client_terms_condition_for_hire_binding.dart';
import '../modules/client/client_terms_condition_for_hire/views/client_terms_condition_for_hire_view.dart';
import '../modules/client/employee_details/bindings/employee_details_binding.dart';
import '../modules/client/employee_details/views/employee_details_view.dart';
import '../modules/client/hire_status/bindings/hire_status_binding.dart';
import '../modules/client/hire_status/views/hire_status_view.dart';
import '../modules/client/invoice_pdf/bindings/invoice_pdf_binding.dart';
import '../modules/client/invoice_pdf/views/invoice_pdf_view.dart';
import '../modules/client/mh_employees/bindings/mh_employees_binding.dart';
import '../modules/client/mh_employees/views/mh_employees_view.dart';
import '../modules/client/mh_employees_by_id/bindings/mh_employees_by_id_binding.dart';
import '../modules/client/mh_employees_by_id/views/mh_employees_by_id_view.dart';
import '../modules/contact_us/bindings/contact_us_binding.dart';
import '../modules/contact_us/views/contact_us_view.dart';
import '../modules/email_input/bindings/email_input_binding.dart';
import '../modules/email_input/views/email_input_view.dart';
import '../modules/employee/employee_dashboard/bindings/employee_dashboard_binding.dart';
import '../modules/employee/employee_dashboard/views/employee_dashboard_view.dart';
import '../modules/employee/employee_home/bindings/employee_home_binding.dart';
import '../modules/employee/employee_home/views/employee_home_view.dart';
import '../modules/employee/employee_payment_history/bindings/employee_payment_history_binding.dart';
import '../modules/employee/employee_payment_history/views/employee_payment_history_view.dart';
import '../modules/employee/employee_register_success/bindings/employee_register_success_binding.dart';
import '../modules/employee/employee_register_success/views/employee_register_success_view.dart';
import '../modules/employee/employee_self_profile/bindings/employee_self_profile_binding.dart';
import '../modules/employee/employee_self_profile/views/employee_self_profile_view.dart';
import '../modules/employee_booked_history/bindings/employee_booked_history_binding.dart';
import '../modules/employee_booked_history/views/employee_booked_history_view.dart';
import '../modules/employee_booked_history_details/bindings/employee_booked_history_details_binding.dart';
import '../modules/employee_booked_history_details/views/employee_booked_history_details_view.dart';
import '../modules/employee_hired_history/bindings/employee_hired_history_binding.dart';
import '../modules/employee_hired_history/views/employee_hired_history_view.dart';
import '../modules/map/restaurant_location/bindings/restaurant_location_binding.dart';
import '../modules/map/restaurant_location/views/restaurant_location_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/otp/bindings/otp_binding.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/reset_password/bindings/reset_password_binding.dart';
import '../modules/reset_password/views/reset_password_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/stripe_payment/bindings/stripe_payment_binding.dart';
import '../modules/stripe_payment/views/stripe_payment_view.dart';
import '../modules/terms_and_condition/bindings/terms_and_condition_binding.dart';
import '../modules/terms_and_condition/views/terms_and_condition_view.dart';

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
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.adminHome,
      page: () => const AdminHomeView(),
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
      name: _Paths.clientHome,
      page: () => const ClientHomeView(),
      binding: ClientHomeBinding(),
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
      name: _Paths.clientSelfProfile,
      page: () => const ClientSelfProfileView(),
      binding: ClientSelfProfileBinding(),
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
      name: _Paths.employeeSelfProfile,
      page: () => const EmployeeSelfProfileView(),
      binding: EmployeeSelfProfileBinding(),
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
      name: _Paths.restaurantLocation,
      page: () => const RestaurantLocationView(),
      binding: RestaurantLocationBinding(),
    ),
    GetPage(
      name: _Paths.clientEmployeeChat,
      page: () => const ClientEmployeeChatView(),
      binding: ClientEmployeeChatBinding(),
    ),
    GetPage(
      name: _Paths.supportChat,
      page: () => const SupportChatView(),
      binding: SupportChatBinding(),
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
      name: _Paths.stripePayment,
      page: () => const StripePaymentView(),
      binding: StripePaymentBinding(),
    ),
    GetPage(
      name: _Paths.employeePaymentHistory,
      page: () => const EmployeePaymentHistoryView(),
      binding: EmployeePaymentHistoryBinding(),
    ),
    GetPage(
      name: _Paths.calender,
      page: () => const CalenderView(),
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
  ];
}
