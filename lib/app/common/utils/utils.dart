import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_plan_response_model.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_model.dart';
import 'package:mh/app/repository/server_urls.dart';
import 'package:mh/domain/model/payment_model.dart';
import 'package:pdf/pdf.dart';
import '../../enums/error_from.dart';
import '../../helpers/responsive_helper.dart';
import '../../models/check_in_out_histories.dart';
import '../../models/custom_error.dart';
import '../../models/employee_daily_statistics.dart';
import '../controller/app_controller.dart';
import '../widgets/custom_dialog.dart';
import 'exports.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class Utils {
  static final Utils _instance = Utils._();

  factory Utils() {
    return _instance;
  }

  Utils._();

  static unFocus() => FocusManager.instance.primaryFocus?.unfocus();

  static get exitApp =>
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');

  static Future<bool> appExitConfirmation(BuildContext context) async =>
      CustomDialogue.appExit(context) ?? false;

  static void setStatusBarColorColor(Brightness brightness) {
    Future.delayed(const Duration(milliseconds: 1)).then(
      (value) => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
    );
  }

  static String dropdownItemTitle(dynamic object, String keyword) {
    return object.toJson()[keyword];
  }

  static bool get isPhone => GetPlatform.isMobile;

  static errorDialog(BuildContext context, CustomError customError) {
    if (customError.errorFrom == ErrorFrom.noInternet) {
      // CustomDialogue.noInternetError(
      //   context: context,
      //   onRetry: customError.onRetry,
      // );
      Utils.showSnackBar(message: "No internet, Please try again.", isTrue: false);
    } else if (customError.errorFrom == ErrorFrom.api) {
      CustomDialogue.apiError(
        context: context,
        onRetry: customError.onRetry,
        errorCode: customError.errorCode,
        msg: customError.msg,
      );
    } else if (customError.errorFrom == ErrorFrom.typeConversion) {
      Utils.showSnackBar(message: "Please try again later.", isTrue: false);
      // CustomDialogue.typeConversionError(
      //   context: context,
      //   onRetry: customError.onRetry,
      // );
    } else if (customError.errorFrom == ErrorFrom.server) {
      // CustomDialogue.serverError(
      //   context: context,
      //   onRetry: customError.onRetry,
      //   msg: customError.msg,
      // );
      Utils.showSnackBar(message: "Something wrong. Please try again later.", isTrue: false);
    }
  }

  static bool isPositionActive(String positionId) {
    return (Get.find<AppController>().commons?.value.positions ?? [])
        .where(
            (element) => element.id == positionId && (element.active ?? false))
        .isNotEmpty;
  }

  static String getPositionName(String positionId) {
    var result = (Get.find<AppController>().commons?.value.positions ?? [])
        .where((element) => element.id == positionId);

    if (result.isEmpty) return "-";

    return result.first.name ?? "-";
  }

  static String getPositionId(String positionName) {
    var result = (Get.find<AppController>().commons?.value.positions ?? [])
        .where((element) => element.name == positionName);

    return result.first.id ?? "";
  }

  static List<String> getSkillIds(List<String> skillNames) {
    var result = (Get.find<AppController>().commons?.value.skills ?? [])
        .where((element) => skillNames.contains(element.name));

    return result.map((e) => e.id!).toList();
  }

  // 24hour format
  static DateTime get getCurrentTime {
    // Get the current time
    DateTime now = DateTime.now();

    // Format the current time in 24-hour format
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    return DateTime.parse('${now.toString().split(" ").first} $formattedTime');
  }

  static String truncateCharacters(String text, int charLimit) {
    // Check if the text exceeds the character limit
    if (text.length > charLimit) {
      return '${text.substring(0, charLimit)}...';
    }

    // Return the original text if it's within the limit
    return text;
  }

  static String secondToHour(int second) {
    Duration duration = Duration(seconds: second);
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return '${hours}h: ${minutes}m: ${seconds}s';
  }

  static int? _getWorkingTimeInSeconds(
      {DateTime? checkInTime, DateTime? checkOutTime, int? breakTime}) {
    if (checkOutTime == null && checkInTime != null) {
      return getCurrentTime.difference(checkInTime.toLocal()).inSeconds;
    }

    if (checkInTime != null && checkOutTime != null) {
      int timeDifference = checkOutTime.difference(checkInTime).inSeconds;
      return (timeDifference - (breakTime ?? 0) * 60);
    }

    return null;
  }

  static UserDailyStatistics checkInOutToStatistics(
      CheckInCheckOutHistoryElement element) {
    UserDailyStatistics dailyStatistics = UserDailyStatistics(
      date: "-",
      restaurantName: '-',
      employeeName: '-',
      position: '-',
      displayCheckInTime: "-",
      displayCheckOutTime: "-",
      displayBreakTime: "-",
      clientCheckInTime: "-",
      clientCheckOutTime: "-",
      clientBreakTime: "-",
      employeeCheckInTime: "-",
      employeeCheckOutTime: "-",
      employeeBreakTime: "-",
      workingHour: "-",
      amount: "-",
      complain: "-",
      totalWorkingTimeInSecond: 0,
    );

    DateTime? employeeCheckIn = element.checkInCheckOutDetails?.checkInTime;
    DateTime? employeeCheckout = element.checkInCheckOutDetails?.checkOutTime;
    DateTime? clientCheckIn = element.checkInCheckOutDetails?.clientCheckInTime;
    DateTime? clientCheckOut =
        element.checkInCheckOutDetails?.clientCheckOutTime;

    if (employeeCheckIn != null) {
      dailyStatistics.employeeCheckInTime =
          DateFormat('hh:mm:ss a').format(employeeCheckIn);
      //"${employeeCheckIn.toLocal().hour} : ${employeeCheckIn.toLocal().minute}";
    }
    if (employeeCheckout != null) {
      dailyStatistics.employeeCheckOutTime =
          DateFormat('hh:mm:ss a').format(employeeCheckout);
      //"${employeeCheckout.toLocal().hour} : ${employeeCheckout.toLocal().minute}";
    }
    if (element.checkInCheckOutDetails?.breakTime != null &&
        element.checkInCheckOutDetails?.breakTime != 0) {
      dailyStatistics.employeeBreakTime =
          "${element.checkInCheckOutDetails?.breakTime ?? 0} min";
    }

    if (clientCheckIn != null) {
      dailyStatistics.clientCheckInTime =
          DateFormat('HH: mm: ss').format(clientCheckIn);
      // "${clientCheckIn.toLocal().hour} : ${clientCheckIn.toLocal().minute}";
    }
    if (clientCheckOut != null) {
      dailyStatistics.clientCheckOutTime =
          DateFormat('HH: mm: ss').format(clientCheckOut);
      //"${clientCheckOut.toLocal().hour} : ${clientCheckOut.toLocal().minute}";
    }
    if (element.checkInCheckOutDetails?.clientBreakTime != null &&
        element.checkInCheckOutDetails?.clientBreakTime != 0) {
      dailyStatistics.clientBreakTime =
          "${element.checkInCheckOutDetails?.clientBreakTime ?? 0} min";
    }

    DateTime? tempCheckInTime =
        employeeCheckIn; //clientCheckIn ?? employeeCheckIn;
    DateTime? tempCheckOutTime =
        employeeCheckout; //clientCheckOut ?? employeeCheckout;
    int? tempBreakTime = (element.checkInCheckOutDetails?.breakTime ??
        0); /*(element.checkInCheckOutDetails?.clientBreakTime ?? 0) == 0
        ? (element.checkInCheckOutDetails?.breakTime ?? 0)
        : (element.checkInCheckOutDetails?.clientBreakTime ?? 0);*/
    int? tempWorkingTimeInSeconds = _getWorkingTimeInSeconds(
        checkInTime: tempCheckInTime,
        checkOutTime: tempCheckOutTime,
        breakTime: tempBreakTime);

    if ((tempCheckInTime) != null) {
      dailyStatistics.date =
          DateTime.parse(tempCheckInTime.toLocal().toString().split(" ").first)
              .dMMMy;
      dailyStatistics.displayCheckInTime =
          DateFormat('HH: mm: ss').format(tempCheckInTime);
    }

    if (tempCheckOutTime != null) {
      dailyStatistics.displayCheckOutTime =
          DateFormat('HH: mm: ss').format(tempCheckOutTime);
    }

    if (tempBreakTime != 0) {
      dailyStatistics.displayBreakTime = "$tempBreakTime min";
    }

    // working time and amount
    if (tempWorkingTimeInSeconds != null) {
      dailyStatistics.totalWorkingTimeInSecond = tempWorkingTimeInSeconds;
      dailyStatistics.workingHour = secondToHour(tempWorkingTimeInSeconds);
      dailyStatistics.amount = ((tempWorkingTimeInSeconds / 3600) *
              (element.employeeDetails?.hourlyRate ?? 0.0))
          .toStringAsFixed(2);
    }

    dailyStatistics.restaurantName =
        element.restaurantDetails?.restaurantName ?? '';
    dailyStatistics.employeeName = element.employeeDetails?.name ?? '';
    dailyStatistics.position = element.employeeDetails?.positionName ?? '';
    dailyStatistics.complain = '-';
    return dailyStatistics;
  }

  static EmployeePaymentModel employeePaymentHistory(
      CheckInCheckOutHistoryElement element) {
    EmployeePaymentModel employeePayment = EmployeePaymentModel(
        day: "-",
        restaurantName: '-',
        position: '-',
        contractorPerHoursRate: 0.0,
        totalHours: '0.0',
        employeeAmount: 0.0,
        status: '-');

    DateTime? hiredDate = element.hiredDate;

    if (hiredDate != null) {
      employeePayment.day = hiredDate.toLocal().dMMMy;
    }
    employeePayment.restaurantName =
        element.restaurantDetails?.restaurantName ?? '';
    employeePayment.position = element.employeeDetails?.positionName ?? '';
    employeePayment.contractorPerHoursRate =
        element.employeeDetails?.contractorHourlyRate ?? 0.0; //TODO:
    employeePayment.totalHours = element.workedHour ?? '0.0';
    employeePayment.employeeAmount = element.employeeAmount ?? 0.0;
    employeePayment.status = element.status ?? '';
    return employeePayment;
  }

  static String getCurrentTimeWithAMPM() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm a').format(now);
    return formattedTime;
  }

  static Future<File> generatePdfWithImageAndText(
      {required PaymentResult invoice, required String companyName}) async {
    final pw.Document pdf = pw.Document();
    pw.MemoryImage? image1;
    File file1;
    file1 = await assetToFile(MyAssets.logo);
    if (file1.existsSync()) {
      image1 = pw.MemoryImage(file1.readAsBytesSync());
    }

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.symmetric(horizontal: 15.0),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(children: [
                        pw.Image(image1!, height: 80, width: 80),
                        pw.Text("Plagit",
                            style: pw.TextStyle(
                                fontSize: 30,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('58c8c8'))),
                      ]),
                      pw.Text("INVOICE",
                          style: const pw.TextStyle(fontSize: 25)),
                    ]),
                pw.SizedBox(height: 30),
                pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40.0),
                    child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Payable To',
                                  style: pw.TextStyle(
                                      color: PdfColors
                                          .black, // Set the text color to blue.
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Text('202 Souk Al Bahar Saaha C,',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 12,
                                        color: PdfColors.black)),
                                pw.Text('Downtown Dubai',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 12,
                                        color: PdfColors.black)),
                                pw.Text('VAT number: 450105738',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 12,
                                        color: PdfColors.black)),
                              ]),
                          pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Invoice No: null',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 12,
                                        color: PdfColors.black)),
                                pw.SizedBox(height: 10),
                                pw.Text(
                                    'Date: ${DateFormat('d MMM y').format(DateTime.parse(invoice.createdAt ?? ''))}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 12,
                                        color: PdfColors.black))
                              ])
                        ])),
                pw.SizedBox(height: 30),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 40.0),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('To',
                                  style: pw.TextStyle(
                                      color: PdfColors
                                          .black, // Set the text color to blue.
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold))
                            ]),
                      ),
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                                invoice.restaurantDetails?.restaurantName ?? "",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 12,
                                    color: PdfColors.black)),
                            pw.SizedBox(height: 10),
                            pw.Text(companyName,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 12,
                                    color: PdfColors.black)),
                            pw.Text(
                                invoice.restaurantDetails?.restaurantAddress ??
                                    '',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 12,
                                    color: PdfColors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColor.fromHex('58c8c8').shade(0.2)),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('58c8c8').shade(0.2)),
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            child: pw.Center(
                                child: pw.Text(
                              'NAME',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                color: PdfColors.black,
                              ),
                            ))),
                        pw.Padding(
                            padding: pw.EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            child: pw.Center(
                                child: pw.Text(
                              'POSITION',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                color: PdfColors.black,
                              ),
                            ))),
                        pw.Padding(
                            padding: pw.EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            child: pw.Center(
                                child: pw.Text(
                              'AMOUNT',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                color: PdfColors.black,
                              ),
                            ))),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: pw.Center(
                              child:
                                  pw.Text(invoice.employeeDetails?.name ?? ''),
                            )),
                        pw.Padding(
                            padding: pw.EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: pw.Center(
                                child: pw.Text(
                                    invoice.employeeDetails?.positionName ??
                                        ''))),
                        pw.Padding(
                            padding: pw.EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: pw.Center(
                                child: pw.Text(
                                    '${getCurrencySymbol()}${invoice.employeeDetails?.hourlyRate ?? 0.0}'))),
                      ],
                    ),
                  ],
                ),
                pw.Divider(
                    color: PdfColors.grey400, height: 0.0, thickness: 0.1),
                pw.SizedBox(height: 10),
                pw.SizedBox(height: 80),
                pw.Center(
                    child: pw.Container(
                        height: 130,
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('58c8c8').shade(0.2)),
                        child: pw.Container(
                          margin: const pw.EdgeInsets.all(20.0),
                          padding: const pw.EdgeInsets.all(20.0),
                          child: pw.Column(children: [
                            pw.Text("www.plagit.com",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16,
                                    color: PdfColors.black)),
                            pw.SizedBox(height: 10),
                            pw.Text("info@plagit.com",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16,
                                    color: PdfColors.black)),
                            pw.SizedBox(height: 10),
                          ]),
                          decoration: pw.BoxDecoration(
                              // color: PdfColors.black,
                              borderRadius: pw.BorderRadius.circular(50.0)),
                        ))),
                pw.SizedBox(height: 10)
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF to a file.
    final appDocDir = await getApplicationDocumentsDirectory();
    final String sPath = '${appDocDir.path}/invoice.pdf';
    final File sFile = File(sPath);
    await sFile.writeAsBytes(await pdf.save());

    return sFile;
  }

  static Future<File> assetToFile(String assetPath) async {
    // Load the asset data as a byte array
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();

    // Get the temporary directory where we can write the asset data
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/${assetPath.split('/').last}';

    // Write the asset data to a temporary file
    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);

    return tempFile;
  }

  static void showSnackBar({required String message, required bool isTrue}) {
    Get.rawSnackbar(
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10.0),
        titleText: Text(
          isTrue == true
              ? MyStrings.success.tr.toUpperCase()
              : MyStrings.warning.tr.toUpperCase(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.isTab(Get.context)?9.sp:13.sp,
              color: Colors.white,
              fontFamily: MyAssets.fontKlavika),
        ),
        messageText: Text(
          message,
          style: TextStyle(
              fontSize: ResponsiveHelper.isTab(Get.context)?9.sp:13.sp, color: Colors.white, fontFamily: MyAssets.fontKlavika),
        ),
        backgroundColor: MyColors.primaryLight ,
        borderRadius: 10.0);
  }

  static void showToast({required String message, required Color bgColor}) {
    Fluttertoast.showToast(msg: message, backgroundColor: bgColor);
  }

  static Future<String?> uploadProfileImage({required File imageFile}) async {
    try {
      http.MultipartRequest request = http.MultipartRequest(
          'PUT',
          Uri.parse(
              "${ServerUrls.serverLiveUrlUser}users/update-profile-image"));
      request.headers['Authorization'] = "Bearer ${StorageHelper.getToken}";
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(await http.MultipartFile.fromPath(
          'file', imageFile.path,
          contentType: MediaType('image', 'jpeg')));

      http.StreamedResponse response = await request.send();
      if ([200, 201].contains(response.statusCode)) {
        return response.reasonPhrase;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static get primaryGradient => const LinearGradient(
      colors: [MyColors.primaryLight, MyColors.primaryDark]);

  static get secondaryGradient =>
      const LinearGradient(colors: [MyColors.c_9A9A9A, MyColors.c_7B7B7B]);

  static get percentageIndicatorGradient => const LinearGradient(
      colors: [MyColors.primaryDark, MyColors.primaryLight]);

  static get transparentGradient =>
      const LinearGradient(colors: [MyColors.noColor, MyColors.noColor]);

  static get comingSoon => Get.bottomSheet(
      backgroundColor: MyColors.lightCard(Get.context!),
      Container(
        height: 300,
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)),
            color: MyColors.lightCard(Get.context!)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkResponse(
                  onTap: () => Get.back(),
                  child: const CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.red,
                      child:
                          Icon(Icons.clear, color: MyColors.white, size: 15)),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Lottie.asset(MyAssets.lottie.comingSoonLottie, height: 200),
          ],
        ),
      ));

  static double getSubscriptionMonthlyCharge(
      {required SubscriptionPlanModel subscriptionPlan}) {
    switch (Get.find<AppController>().user.value.userCountry) {
      case 'United Kingdom':
        return subscriptionPlan.monthlyChargeInPound ?? 0.0;
      case 'United Arab Emirates':
        return subscriptionPlan.monthlyChargeInDirham ?? 0.0;
      case 'Italy':
        return subscriptionPlan.monthlyChargeInEuro ?? 0.0;
      default:
        return subscriptionPlan.monthlyChargeInPound ?? 0.0;
    }
  }

  static double getSubscriptionYearlyCharge(
      {required SubscriptionPlanModel subscriptionPlan}) {
    switch (Get.find<AppController>().user.value.userCountry) {
      case 'United Kingdom':
        return subscriptionPlan.yearlyChargeInPound ?? 0.0;
      case 'United Arab Emirates':
        return subscriptionPlan.yearlyChargeInDirham ?? 0.0;
      case 'Italy':
        return subscriptionPlan.yearlyChargeInEuro ?? 0.0;
      default:
        return subscriptionPlan.yearlyChargeInPound ?? 0.0;
    }
  }

  static String getCurrencySymbol() {
    switch (Get.find<AppController>().user.value.userCountry) {
      case 'Afghanistan':
        return '؋';
      case 'Albania':
        return 'L';
      case 'Algeria':
        return 'دج';
      case 'Argentina':
        return '\$';
      case 'Armenia':
        return '֏';
      case 'Australia':
        return '\$';
      case 'Austria':
        return '€';
      case 'Azerbaijan':
        return '₼';
      case 'Bahrain':
        return 'BD'; // Alternative: '.د.ب'
      case 'Bangladesh':
        return '৳';
      case 'Belarus':
        return 'Br';
      case 'Belgium':
        return '€';
      case 'Brazil':
        return 'R\$';
      case 'Bulgaria':
        return 'лв';
      case 'Canada':
        return '\$';
      case 'Chile':
        return '\$';
      case 'China':
        return '¥';
      case 'Colombia':
        return '\$';
      case 'Croatia':
        return 'kn';
      case 'Czech Republic':
        return 'Kč';
      case 'Denmark':
        return 'kr';
      case 'Egypt':
        return '£';
      case 'Eurozone':
      case 'Finland':
      case 'France':
      case 'Germany':
      case 'Greece':
      case 'Ireland':
      case 'Italy':
      case 'Netherlands':
      case 'Portugal':
      case 'Spain':
        return '€';
      case 'Hong Kong':
        return '\$';
      case 'Hungary':
        return 'Ft';
      case 'Iceland':
        return 'kr';
      case 'India':
        return '₹';
      case 'Indonesia':
        return 'Rp';
      case 'Iran':
        return '﷼';
      case 'Iraq':
        return 'ع.د';
      case 'Israel':
        return '₪';
      case 'Japan':
        return '¥';
      case 'Jordan':
        return 'د.ا';
      case 'Kazakhstan':
        return '₸';
      case 'Kenya':
        return 'Sh';
      case 'Kuwait':
        return 'د.ك';
      case 'Lebanon':
        return 'ل.ل';
      case 'Malaysia':
        return 'RM';
      case 'Mexico':
        return '\$';
      case 'Morocco':
        return 'د.م.';
      case 'New Zealand':
        return '\$';
      case 'Nigeria':
        return '₦';
      case 'Norway':
        return 'kr';
      case 'Oman':
        return 'ر.ع.';
      case 'Pakistan':
        return '₨';
      case 'Philippines':
        return '₱';
      case 'Poland':
        return 'zł';
      case 'Qatar':
        return 'ر.ق';
      case 'Romania':
        return 'lei';
      case 'Russia':
        return '₽';
      case 'Saudi Arabia':
        return '﷼';
      case 'Singapore':
        return '\$';
      case 'South Africa':
        return 'R';
      case 'South Korea':
        return '₩';
      case 'Sweden':
        return 'kr';
      case 'Switzerland':
        return 'CHF';
      case 'Taiwan':
        return 'NT\$';
      case 'Thailand':
        return '฿';
      case 'Turkey':
        return '₺';
      case 'United Arab Emirates':
        return 'AED'; // Alternative: '\u062F\u002E\u0625' (د.إ)
      case 'United Kingdom':
        return '\u00A3'; // Unicode for £
      case 'United States':
        return '\$';
      case 'Vietnam':
        return '₫';
      default:
        return '\$'; // Default symbol, usually for USD
    }
  }

  static String getCurrencySymbolModified(String country) {
    switch (country) {
      case 'Afghanistan':
        return '؋';
      case 'Albania':
        return 'L';
      case 'Algeria':
        return 'دج';
      case 'Argentina':
        return '\$';
      case 'Armenia':
        return '֏';
      case 'Australia':
        return '\$';
      case 'Austria':
        return '€';
      case 'Azerbaijan':
        return '₼';
      case 'Bahrain':
        return 'BD'; // Alternative: '.د.ب'
      case 'Bangladesh':
        return '৳';
      case 'Belarus':
        return 'Br';
      case 'Belgium':
        return '€';
      case 'Brazil':
        return 'R\$';
      case 'Bulgaria':
        return 'лв';
      case 'Canada':
        return '\$';
      case 'Chile':
        return '\$';
      case 'China':
        return '¥';
      case 'Colombia':
        return '\$';
      case 'Croatia':
        return 'kn';
      case 'Czech Republic':
        return 'Kč';
      case 'Denmark':
        return 'kr';
      case 'Egypt':
        return '£';
      case 'Eurozone':
      case 'Finland':
      case 'France':
      case 'Germany':
      case 'Greece':
      case 'Ireland':
      case 'Italy':
      case 'Netherlands':
      case 'Portugal':
      case 'Spain':
        return '€';
      case 'Hong Kong':
        return '\$';
      case 'Hungary':
        return 'Ft';
      case 'Iceland':
        return 'kr';
      case 'India':
        return '₹';
      case 'Indonesia':
        return 'Rp';
      case 'Iran':
        return '﷼';
      case 'Iraq':
        return 'ع.د';
      case 'Israel':
        return '₪';
      case 'Japan':
        return '¥';
      case 'Jordan':
        return 'د.ا';
      case 'Kazakhstan':
        return '₸';
      case 'Kenya':
        return 'Sh';
      case 'Kuwait':
        return 'د.ك';
      case 'Lebanon':
        return 'ل.ل';
      case 'Malaysia':
        return 'RM';
      case 'Mexico':
        return '\$';
      case 'Morocco':
        return 'د.م.';
      case 'New Zealand':
        return '\$';
      case 'Nigeria':
        return '₦';
      case 'Norway':
        return 'kr';
      case 'Oman':
        return 'ر.ع.';
      case 'Pakistan':
        return '₨';
      case 'Philippines':
        return '₱';
      case 'Poland':
        return 'zł';
      case 'Qatar':
        return 'ر.ق';
      case 'Romania':
        return 'lei';
      case 'Russia':
        return '₽';
      case 'Saudi Arabia':
        return '﷼';
      case 'Singapore':
        return '\$';
      case 'South Africa':
        return 'R';
      case 'South Korea':
        return '₩';
      case 'Sweden':
        return 'kr';
      case 'Switzerland':
        return 'CHF';
      case 'Taiwan':
        return 'NT\$';
      case 'Thailand':
        return '฿';
      case 'Turkey':
        return '₺';
      case 'United Arab Emirates':
        return 'د.إ'; // Alternative: '\u062F\u002E\u0625' (د.إ)
      case 'United Kingdom':
        return '\u00A3'; // Unicode for £
      case 'United States':
        return '\$';
      case 'Vietnam':
        return '₫';
      default:
        return '\$'; // Default symbol, usually for USD
    }
  }

  static double getActualSubscriptionMonthlyCharge(
      {required SubscriptionPlanModel subscription}) {
    double actualCharge = 0.0;

    if (subscription.hasDiscount == true) {
      if (subscription.discountType == "percent") {
        return actualCharge =
            getSubscriptionMonthlyCharge(subscriptionPlan: subscription) +
                (getSubscriptionMonthlyCharge(subscriptionPlan: subscription) *
                        (subscription.discount ?? 0.0)) ~/
                    100;
      } else {
        return actualCharge =
            getSubscriptionMonthlyCharge(subscriptionPlan: subscription) +
                (subscription.discount ?? 0.0);
      }
    } else {
      return actualCharge;
    }
  }

  static double getClientActualSubscriptionMonthlyCharge(
      {required subscription }) {
    double actualCharge = 0.0;
    if (subscription.hasDiscount == true &&
        subscription.discountType == "percent") {
      return actualCharge =
      subscription.monthlyCharge -
          (subscription.monthlyCharge *
                  (subscription.discount ?? 0.0)) ~/
              100;
    } else {
      return actualCharge =
          subscription.monthlyCharge + (subscription.discount ?? 0.0);
    }
  }

  static String getDiscountText({required SubscriptionPlanModel subscription}) {
    if (subscription.hasDiscount == true) {
      if (subscription.discountType == "percent") {
        return "${subscription.discount}% Discount";
      } else {
        return "${getCurrencySymbol()}${subscription.discount} Discount";
      }
    } else {
      return '';
    }
  }

  static String formatDateTime(DateTime dateTime,
      {bool? socialFeed, bool? message}) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return "Just Now";
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      if (socialFeed ?? false) {
        return DateFormat('dd MMM yyyy').format(dateTime);
      } else {
        if (message ?? false) {
          return "${DateFormat('dd MMM yyyy').format(dateTime)} ${DateFormat('hh:mm a').format(dateTime)}";
        } else {
          return "${DateFormat('dd MMM yyyy').format(dateTime)}\n   ${DateFormat('hh:mm a').format(dateTime)}";
        }
      }
    }
  }

    static String getTime(DateTime dateTime){
      // DateTime dateTime = DateTime.parse(dateTimeString);
      String formattedTime = DateFormat('hh:mm:ss a').format(dateTime);
      return formattedTime;
  }

  static int getDaysDifference(DateTime fromTime,DateTime toTime){
    // Calculate the difference
    Duration difference = toTime.difference(fromTime);

    // Display the results
    // print("Difference in days: ${difference.inDays}");
    // print("Difference in hours: ${difference.inHours}");
    // print("Difference in minutes: ${difference.inMinutes}");
    // print("Difference in seconds: ${difference.inSeconds}");
    // print("Difference in milliseconds: ${difference.inMilliseconds}");
    // print("Difference in microseconds: ${difference.inMicroseconds}");
    return difference.inSeconds;
  }

  // static String getCountryFlag({required String countryName}) {
  //   switch (countryName.toUpperCase()) {
  //     case 'UNITED KINGDOM':
  //       return "🇬🇧"; // United Kingdom flag
  //     case 'ITALY':
  //       return "🇮🇹"; // Italy flag
  //     case 'UNITED ARAB EMIRATES':
  //       return "🇦🇪"; // UAE flag
  //     default:
  //       return "🇬🇧"; // Default to United Kingdom flag
  //   }
  // }
static String getCountryFlag({required String countryName}) {
  const Map<String, String> flags = {
    'AFGHANISTAN': "🇦🇫",
    'ALBANIA': "🇦🇱",
    'ALGERIA': "🇩🇿",
    'ANDORRA': "🇦🇩",
    'ANGOLA': "🇦🇴",
    'ANTIGUA AND BARBUDA': "🇦🇬",
    'ARGENTINA': "🇦🇷",
    'ARMENIA': "🇦🇲",
    'AUSTRALIA': "🇦🇺",
    'AUSTRIA': "🇦🇹",
    'AZERBAIJAN': "🇦🇿",
    'BAHAMAS': "🇧🇸",
    'BAHRAIN': "🇧🇭",
    'BANGLADESH': "🇧🇩",
    'BARBADOS': "🇧🇧",
    'BELARUS': "🇧🇾",
    'BELGIUM': "🇧🇪",
    'BELIZE': "🇧🇿",
    'BENIN': "🇧🇯",
    'BHUTAN': "🇧🇹",
    'BOLIVIA': "🇧🇴",
    'BOSNIA AND HERZEGOVINA': "🇧🇦",
    'BOTSWANA': "🇧🇼",
    'BRAZIL': "🇧🇷",
    'BRUNEI': "🇧🇳",
    'BULGARIA': "🇧🇬",
    'BURKINA FASO': "🇧🇫",
    'BURUNDI': "🇧🇮",
    'CABO VERDE': "🇨🇻",
    'CAMBODIA': "🇰🇭",
    'CAMEROON': "🇨🇲",
    'CANADA': "🇨🇦",
    'CENTRAL AFRICAN REPUBLIC': "🇨🇫",
    'CHAD': "🇹🇩",
    'CHILE': "🇨🇱",
    'CHINA': "🇨🇳",
    'COLOMBIA': "🇨🇴",
    'COMOROS': "🇰🇲",
    'CONGO, REPUBLIC OF THE': "🇨🇬",
    'CONGO, DEMOCRATIC REPUBLIC OF THE': "🇨🇩",
    'COSTA RICA': "🇨🇷",
    'CROATIA': "🇭🇷",
    'CUBA': "🇨🇺",
    'CYPRUS': "🇨🇾",
    'CZECH REPUBLIC': "🇨🇿",
    'DENMARK': "🇩🇰",
    'DJIBOUTI': "🇩🇯",
    'DOMINICA': "🇩🇲",
    'DOMINICAN REPUBLIC': "🇩🇴",
    'ECUADOR': "🇪🇨",
    'EGYPT': "🇪🇬",
    'EL SALVADOR': "🇸🇻",
    'EQUATORIAL GUINEA': "🇬🇶",
    'ERITREA': "🇪🇷",
    'ESTONIA': "🇪🇪",
    'ESWATINI': "🇸🇿",
    'ETHIOPIA': "🇪🇹",
    'Fiji': "🇫🇯",
    'FINLAND': "🇫🇮",
    'FRANCE': "🇫🇷",
    'GABON': "🇬🇦",
    'GAMBIA': "🇬🇲",
    'GEORGIA': "🇬🇪",
    'GERMANY': "🇩🇪",
    'GHANA': "🇬🇭",
    'GREECE': "🇬🇷",
    'GRENADA': "🇬🇩",
    'GUATEMALA': "🇬🇹",
    'GUINEA': "🇬🇼",
    'GUINEA-BISSAU': "🇬🇧",
    'GUYANA': "🇬🇾",
    'HAITI': "🇭🇹",
    'HONDURAS': "🇭🇳",
    'HUNGARY': "🇭🇺",
    'ICELAND': "🇮🇸",
    'INDIA': "🇮🇳",
    'INDONESIA': "🇮🇩",
    'IRAN': "🇮🇷",
    'IRAQ': "🇮🇶",
    'IRELAND': "🇮🇪",
    'ISRAEL': "🇮🇱",
    'ITALY': "🇮🇹",
    'JAMAICA': "🇯🇲",
    'JAPAN': "🇯🇵",
    'JORDAN': "🇯🇴",
    'KAZAKHSTAN': "🇰🇿",
    'KENYA': "🇰🇪",
    'KIRIBATI': "🇰🇷",
    'KOREA, NORTH': "🇰🇵",
    'KOREA, SOUTH': "🇰🇷",
    'KOSOVO': "🇽🇰",
    'Kuwait': "🇰🇼",
    'KYRGYZSTAN': "🇰🇬",
    'LAOS': "🇱🇦",
    'LATVIA': "🇱🇻",
    'LEBANON': "🇱🇧",
    'LESOTHO': "🇱🇸",
    'LIBERIA': "🇱🇷",
    'LIBYA': "🇱🇾",
    'LIECHTENSTEIN': "🇱🇮",
    'LITHUANIA': "🇱🇹",
    'LUXEMBOURG': "🇱🇺",
    'MADAGASCAR': "🇲🇬",
    'MALAWI': "🇲🇼",
    'MALAYSIA': "🇲🇾",
    'MALDIVES': "🇲🇻",
    'MALI': "🇲🇱",
    'MALTA': "🇲🇹",
    'MAROCCO': "🇲🇦",
    'MAURITANIA': "🇲🇷",
    'MAURITIUS': "🇲🇺",
    'MEXICO': "🇲🇽",
    'MICRONESIA': "🇫🇲",
    'MOLDOVA': "🇲🇩",
    'MONACO': "🇲🇨",
    'MONGOLIA': "🇲🇳",
    'MONTENEGRO': "🇲🇪",
    'MOROCCO': "🇲🇦",
    'MOZAMBIQUE': "🇲🇿",
    'MYANMAR': "🇲🇲",
    'NAMIBIA': "🇳🇦",
    'NAURU': "🇦🇷",
    'NEPAL': "🇳🇵",
    'NETHERLANDS': "🇳🇱",
    'NEW ZEALAND': "🇳🇿",
    'NICARAGUA': "🇳🇮",
    'NIGER': "🇳🇪",
    'NIGERIA': "🇳🇬",
    'NORWAY': "🇳🇴",
    'OMAN': "🇴🇲",
    'PAKISTAN': "🇵🇰",
    'PALAU': "🇵🇼",
    'PANAMA': "🇵🇦",
    'PAPUA NEW GUINEA': "🇵🇬",
    'PARAGUAY': "🇵🇾",
    'PERU': "🇵🇪",
    'PHILIPPINES': "🇵🇭",
    'POLAND': "🇵🇱",
    'PORTUGAL': "🇵🇹",
    'QATAR': "🇶🇦",
    'ROMANIA': "🇷🇴",
    'RUSSIA': "🇷🇺",
    'RWANDA': "🇷🇼",
    'SAINT KITTS AND NEVIS': "🇰🇳",
    'SAINT LUCIA': "🇱🇨",
    'SAINT VINCENT AND THE GRENADINES': "🇻🇨",
    'Samoa': "🇼🇸",
    'SAN MARINO': "🇸🇲",
    'SAO TOME AND PRINCIPE': "🇸🇹",
    'SAUDI ARABIA': "🇸🇦",
    'SENEGAL': "🇸🇳",
    'SERBIA': "🇷🇸",
    'SEYCHELLES': "🇸🇨",
    'SIERRA LEONE': "🇸🇱",
    'SINGAPORE': "🇸🇬",
    'SLOVAKIA': "🇸🇰",
    'SLOVENIA': "🇸🇮",
    'SOLOMON ISLANDS': "🇸🇧",
    'SOMALIA': "🇸🇴",
    'SOUTH AFRICA': "🇿🇦",
    'SOUTH SUDAN': "🇸🇸",
    'SPAIN': "🇪🇸",
    'SRI LANKA': "🇱🇰",
    'SUDAN': "🇸🇩",
    'SURINAME': "🇸🇷",
    'SWEDEN': "🇸🇪",
    'SWITZERLAND': "🇨🇭",
    'SYRIA': "🇸🇾",
    'TAIWAN': "🇹🇼",
    'TAJIKISTAN': "🇹🇯",
    'TANZANIA': "🇹🇿",
    'THAILAND': "🇹🇭",
    'TOGO': "🇹🇬",
    'TONGA': "🇹🇴",
    'TRINIDAD AND TOBAGO': "🇹🇹",
    'TUNISIA': "🇹🇳",
    'TURKMENISTAN': "🇹🇲",
    'TURKEY': "🇹🇷",
    'TUVALU': "🇹🇻",
    'UGANDA': "🇺🇬",
    'UKRAINE': "🇺🇦",
    'UNITED ARAB EMIRATES': "🇦🇪",
    'UNITED KINGDOM': "🇬🇧",
    'UNITED STATES': "🇺🇸",
    'URUGUAY': "🇺🇾",
    'UZBEKISTAN': "🇺🇿",
    'VANUATU': "🇻🇺",
    'VATICAN CITY': "🇻🇦",
    'VENEZUELA': "🇻🇪",
    'VIETNAM': "🇻🇳",
    'YEMEN': "🇾🇪",
    'ZAMBIA': "🇿🇲",
    'ZIMBABWE': "🇿🇼",
  };

    return flags[countryName.toUpperCase()] ?? "🏳️"; // Default to a white flag
  }

  static String get getProfilePicture {
    if (Get.isRegistered<ClientHomePremiumController>()) {
      return Get.find<ClientHomePremiumController>()
              .client
              .value
              .details
              ?.profilePicture ??
          "";
    } else if (Get.isRegistered<EmployeeHomeController>()) {
      return Get.find<EmployeeHomeController>()
              .employee
              .value
              .details
              ?.profilePicture ??
          "";
    } else if (Get.isRegistered<AdminHomeController>()) {
      return Get.find<AdminHomeController>()
              .admin
              .value
              .details
              ?.profilePicture ??
          "";
    } else {
      return "";
    }
  }
}
