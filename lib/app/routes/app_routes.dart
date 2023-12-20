part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const splash = _Paths.splash;

  static const loginRegisterHints = _Paths.loginRegisterHints;
  static const login = _Paths.login;
  static const register = _Paths.register;

  static const adminHome = _Paths.adminHome;
  static const adminAllClients = _Paths.adminAllClients;
  static const adminAllEmployees = _Paths.adminAllEmployees;
  static const adminDashboard = _Paths.adminDashboard;
  static const adminClientRequest = _Paths.adminClientRequest;
  static const adminClientRequestPositions = _Paths.adminClientRequestPositions;
  static const adminClientRequestPositionEmployees =
      _Paths.adminClientRequestPositionEmployees;

  static const employeeHome = _Paths.employeeHome;
  static const employeeDashboard = _Paths.employeeDashboard;

  static const clientHome = _Paths.clientHome;
  static const clientMyEmployee = _Paths.clientMyEmployee;
  static const clientDashboard = _Paths.clientDashboard;
  static const clientPaymentAndInvoice = _Paths.clientPaymentAndInvoice;
  static const clientShortlisted = _Paths.clientShortlisted;
  static const clientRequestForEmployee = _Paths.clientRequestForEmployee;
  static const clientSuggestedEmployees = _Paths.clientSuggestedEmployees;

  static const mhEmployees = _Paths.mhEmployees;
  static const employeeDetails = _Paths.employeeDetails;
  static const employeeRegisterSuccess = _Paths.employeeRegisterSuccess;
  static const termsAndCondition = _Paths.termsAndCondition;
  static const mhEmployeesById = _Paths.mhEmployeesById;
  static const clientTermsConditionForHire = _Paths.clientTermsConditionForHire;
  static const payment = _Paths.paymentForHire;
  static const hireStatus = _Paths.hireStatus;
  static const contactUs = _Paths.contactUs;

  static const restaurantLocation = _Paths.restaurantLocation;
  static const employeeSelfProfile = _Paths.employeeSelfProfile;
  static const clientSelfProfile = _Paths.clientSelfProfile;
  static const clientEmployeeChat = _Paths.clientEmployeeChat;
  static const supportChat = _Paths.supportChat;
  static const notifications = _Paths.notifications;
  static const invoicePdf = _Paths.invoicePdf;
  static const stripePayment = _Paths.stripePayment;
  static const employeePaymentHistory = _Paths.employeePaymentHistory;
  static const calender = _Paths.calender;
  static const employeeBookedHistory = _Paths.employeeBookedHistory;
  static const employeeHiredHistory = _Paths.employeeHiredHistory;
  static const employeeBookedHistoryDetails =
      _Paths.employeeBookedHistoryDetails;
  static const settings = _Paths.settings;
  static const emailInput = _Paths.emailInput;
  static const otp = _Paths.otp;
  static const resetPassword = _Paths.resetPassword;
  static const adminTodaysEmployees = _Paths.adminTodaysEmployees;
  static const liveLocation = _Paths.liveLocation;
  static const createJobPost = _Paths.createJobPost;
  static const jobRequests = _Paths.jobRequests;
}

abstract class _Paths {
  _Paths._();

  static const splash = '/splash';

  static const loginRegisterHints = '/login-register-hints';
  static const login = '/login';
  static const register = '/register';

  static const adminHome = '/admin-home';
  static const adminAllClients = '/admin-all-clients';
  static const adminAllEmployees = '/admin-all-employees';
  static const adminDashboard = '/admin-dashboard';
  static const adminClientRequest = '/admin-client-request';

  static const employeeRegisterSuccess = '/employee-register-success';
  static const employeeHome = '/employee-home';
  static const employeeDashboard = '/employee-dashboard';
  static const employeeSelfProfile = '/employee-self-profile';

  static const clientHome = '/client-home';
  static const clientMyEmployee = '/client-my-employee';
  static const clientDashboard = '/client-dashboard';
  static const clientPaymentAndInvoice = '/client-payment-and-invoice';
  static const clientShortlisted = '/client-shortlisted';
  static const clientTermsConditionForHire = '/client-terms-condition-for-hire';
  static const paymentForHire = '/payment-for-hire';
  static const hireStatus = '/hire-status';
  static const clientRequestForEmployee = '/client-request-for-employee';
  static const clientSuggestedEmployees = '/client-suggested-employees';
  static const clientSelfProfile = '/client-self-profile';

  static const mhEmployees = '/mh-employees';
  static const employeeDetails = '/employee-details';

  static const termsAndCondition = '/terms-and-condition';
  static const mhEmployeesById = '/mh-employees-by-id';

  static const contactUs = '/contact-us';

  static const restaurantLocation = '/restaurant-location';
  static const adminClientRequestPositions = '/admin-client-request-positions';
  static const adminClientRequestPositionEmployees =
      '/admin-client-request-position-employees';
  static const clientEmployeeChat = '/client-employee-chat';
  static const supportChat = '/support-chat';
  static const notifications = '/notifications';
  static const invoicePdf = '/invoice-pdf';
  static const stripePayment = '/stripe-payment';
  static const employeePaymentHistory = '/employee-payment-history';
  static const calender = '/calender';
  static const employeeBookedHistory = '/employee-booked-history';
  static const employeeHiredHistory = '/employee-hired-history';
  static const employeeBookedHistoryDetails =
      '/employee-booked-history-details';
  static const settings = '/settings';
  static const emailInput = '/email-input';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const adminTodaysEmployees = '/admin-todays-employees';
  static const liveLocation = '/live-location';
  static const createJobPost = '/create-job-post';
  static const jobRequests = '/job-requests';
}
