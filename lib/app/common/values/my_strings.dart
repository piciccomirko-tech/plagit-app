// ignore_for_file: library_private_types_in_public_api

class MyStrings {
  static final MyStrings _instance = MyStrings._();

  factory MyStrings() {
    return _instance;
  }

  MyStrings._();

  static _Arguements get arg => _Arguements();
  static _PayloadScreen get payloadScreen => _PayloadScreen();

  // validation
  static const String required = "This field is required";
  static const String invalidEmailAddress = "invalidEmailAddress";
  static const String atLeast1CharNeeded = "atLeast1CharNeeded";
  static const String atLeast1DigitNeeded = "atLeast1DigitNeeded";
  static const String minimum8Char = "minimum8Char";
  static const String enterNewPassword = "EnterNewPassword";
  static const String newPasswordAndConfirmPasswordNotMatch = "newPasswordAndConfirmPasswordNotMatch";

  static const String deviceNotSupport = "deviceNotSupport";
  static const String skip = "skip";
  static const String premierStaffingSolutions = "premierStaffingSolutions";
  static const String login = "login";

  static const String submit = "Submit";
  static const String signUp = "signUp";
  static const String welcomeBack = "welcomeBack";
  static const String userNameEmailId = "userNameEmailId";
  static const String password = "password";
  static const String newPassword = "New Password";
  static const String currentPassword = "Current Password";
  static const String savePassword = "savePassword";
  static const String forgotPassword = "forgotPassword";
  static const String dontHaveAnAccount = "dontHaveAnAccount";
  static const String register = "register";
  static const String client = "client";
  static const String employee = "employee";
  static const String restaurantName = "restaurantName";
  static const String restaurantAddress = "restaurantAddress";
  static const String emailAddress = "emailAddress";
  static const String phoneNumber = "phoneNumber";
  static const String restaurantIpAddress = "restaurantIpAddress";
  static const String iAgreeToTheOf = "iAgreeToTheOf";
  static const String termsConditions = "termsConditions";
  static const String mhApp = "mhApp";
  static const String alreadyHaveAnAccount = "alreadyHaveAnAccount";
  static const String continue_ = "continue";
  static const String confirmPassword = "Confirm Password";
  static const String almostDoneRegisteringTheAccount = "almostDoneRegisteringTheAccount";
  static const String countryAddressLanguage = "countryAddressLanguage";
  static const String educationLicenseSkill = "educationLicenseSkill";
  static const String imageCertificate = "imageCertificate";
  static const String steps = "steps";
  static const String provideAStrongPasswordToSecureYourAccount = "provideAStrongPasswordToSecureYourAccount";
  static const String pleaseProvideTheFollowingInfoToo = "pleaseProvideTheFollowingInfoToo";
  static const String howYouKnowAboutUs = "howYouKnowAboutUs";
  static const String selectFromHere = "selectFromHere";
  static const String enterHere = "enterHere";
  static const String refer = "refer";
  static const String uploadYourPhoto = "uploadYourPhoto";
  static const String firstName = "firstName";
  static const String lastName = "lastName";
  static const String position = "position";
  static const String gender = "gender";
  static const String dateOfBirth = "dateOfBirth";
  static const String country = "country";
  static const String presentAddress = "presentAddress";
  static const String permanentAddress = "permanentAddress";
  static const String language = "language";
  static const String higherEducation = "higherEducation";
  static const String licensesNo = "licensesNo";
  static const String certificationsName = "certificationsName";
  static const String emergencyContact = "emergencyContact";
  static const String skills = "skills";
  static const String hiRestaurant = "hiRestaurant";
  static const String exploreTheFeaturesOfMhAppBelow = "exploreTheFeaturesOfMhAppBelow";
  static const String mh = "mh";
  static const String employees = "employees";
  static const String dashboard = "dashboard";
  static const String myEmployees = "myEmployees";
  static const String invoicePayment = "invoicePayment";
  static const String stripePayment = "Stripe Payment";
  static const String invoice = "Invoice";
  static const String helpSupport = "helpSupport";
  static const String myDashboard = "My Dashboard";
  static const String paymentHistory = "Payment History";
  static const String bookedHistory = "Booked History";
  static const String calendar = "Calendar";
  static const String hiredHistory = "Hired History";
  static const String areShowing = "areShowing";
  static const String exp = "exp";
  static const String countYears = "countYears";
  static const String totalHours = "totalHours";
  static const String countH = "countH";
  static const String rate = "rate";
  static const String ratePerHour = "ratePerHour";
  static const String bookNow = "bookNow";
  static const String filters = "filters";
  static const String rating = "rating";
  static const String experience = "experience";
  static const String years = "years";
  static const String totalHour = "totalHour";
  static const String min = "min";
  static const String max = "max";
  static const String resetData = "resetData";
  static const String apply = "apply";
  static const String ageWithYears = "ageWithYears";
  static const String age = "Age:";
  static const String review = "Review";
  static const String countTime = "countTime";
  static const String licenseNo = "licenseNo";
  static const String location = "location";
  static const String education = "education";
  static const String certificate = "certificate";
  static const String countPosition = "countPosition";
  static const String selectDateRangeForThisEmployeeToBookAllOfThemAtOnce = "selectDateRangeForThisEmployeeToBookAllOfThemAtOnce";
  static const String dateRange = "dateRange";
  static const String bookAll = "bookAll";
  static const String selectDateRange = "selectDateRange";
  static const String applyRange = "applyRange";
  static const String rememberMeText = "Remember Me";
  static const String paymentSucessText = "Payment Successful";
}

class _Arguements {
  String data = "data";
  String showAsAdmin = "showAsAdmin";
  String chatWith = "chatWith";
  String receiverId = "receiverId";


  String receiverName = "receiverName";
  String fromId = "fromId";
  String toId = "toId";
  String clientId = "clientId";
  String employeeId = "employeeId";
  String supportChatDocId = "supportChatDocId";

  String fromWhere = "fromWhere";
  String clientSuggestedViewText = "client_suggested_view";
  String mhEmployeeViewByIdText = "mh_employee_view_by_id";
}

class _PayloadScreen {
  String clientEmployeeChat = "ClientEmployeeChat";
  String supportChat = "supportChat";
}
