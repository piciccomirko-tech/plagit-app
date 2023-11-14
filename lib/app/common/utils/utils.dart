import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_invoice_model.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_history_model.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_model.dart';
import 'package:pdf/pdf.dart';
import '../../enums/error_from.dart';
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

  static get exitApp => SystemChannels.platform.invokeMethod('SystemNavigator.pop');

  static Future<bool> appExitConfirmation(BuildContext context) async => CustomDialogue.appExit(context) ?? false;

  static void setStatusBarColorColor(Brightness brightness) {
    Future.delayed(const Duration(milliseconds: 1)).then(
      (value) => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
          statusBarBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
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
      CustomDialogue.noInternetError(
        context: context,
        onRetry: customError.onRetry,
      );
    } else if (customError.errorFrom == ErrorFrom.api) {
      CustomDialogue.apiError(
        context: context,
        onRetry: customError.onRetry,
        errorCode: customError.errorCode,
        msg: customError.msg,
      );
    } else if (customError.errorFrom == ErrorFrom.typeConversion) {
      CustomDialogue.typeConversionError(
        context: context,
        onRetry: customError.onRetry,
      );
    } else if (customError.errorFrom == ErrorFrom.server) {
      CustomDialogue.serverError(
        context: context,
        onRetry: customError.onRetry,
        msg: customError.msg,
      );
    }
  }

  static bool isPositionActive(String positionId) {
    return (Get.find<AppController>().commons?.value.positions ?? [])
        .where((element) => element.id == positionId && (element.active ?? false))
        .isNotEmpty;
  }

  static String getPositionName(String positionId) {
    var result =
        (Get.find<AppController>().commons?.value.positions ?? []).where((element) => element.id == positionId);

    if (result.isEmpty) return "-";

    return result.first.name ?? "-";
  }

  static String getPositionId(String positionName) {
    var result =
        (Get.find<AppController>().commons?.value.positions ?? []).where((element) => element.name == positionName);

    return result.first.id ?? "";
  }

  static List<String> getSkillIds(List<String> skillNames) {
    var result =
        (Get.find<AppController>().commons?.value.skills ?? []).where((element) => skillNames.contains(element.name));

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

  static String minuteToHour(int minute) {
    if (minute < 60) return '$minute min';
    return "${(minute / 60).toStringAsFixed(0)} H ${minute % 60} min";
  }

  static int? _getWorkingTimeInMinute(DateTime? checkInTime, DateTime? checkOutTime, int? breakTime) {
    if (checkOutTime == null && checkInTime != null) {
      return getCurrentTime.difference(checkInTime.toLocal()).inMinutes;
    }

    if (checkInTime != null && checkOutTime != null) {
      int timeDifference = checkOutTime.difference(checkInTime).inMinutes;
      return (timeDifference - (breakTime ?? 0));
    }

    return null;
  }

  static UserDailyStatistics checkInOutToStatistics(CheckInCheckOutHistoryElement element) {
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
      totalWorkingTimeInMinute: 0,
    );

    DateTime? employeeCheckIn = element.checkInCheckOutDetails?.checkInTime;
    DateTime? employeeCheckout = element.checkInCheckOutDetails?.checkOutTime;
    DateTime? clientCheckIn = element.checkInCheckOutDetails?.clientCheckInTime;
    DateTime? clientCheckOut = element.checkInCheckOutDetails?.clientCheckOutTime;

    if (employeeCheckIn != null) {
      dailyStatistics.employeeCheckInTime = "${employeeCheckIn.toLocal().hour} : ${employeeCheckIn.toLocal().minute}";
    }
    if (employeeCheckout != null) {
      dailyStatistics.employeeCheckOutTime =
          "${employeeCheckout.toLocal().hour} : ${employeeCheckout.toLocal().minute}";
    }
    if (element.checkInCheckOutDetails?.breakTime != null && element.checkInCheckOutDetails?.breakTime != 0) {
      dailyStatistics.employeeBreakTime = "${element.checkInCheckOutDetails?.breakTime ?? 0} min";
    }

    if (clientCheckIn != null) {
      dailyStatistics.clientCheckInTime = "${clientCheckIn.toLocal().hour} : ${clientCheckIn.toLocal().minute}";
    }
    if (clientCheckOut != null) {
      dailyStatistics.clientCheckOutTime = "${clientCheckOut.toLocal().hour} : ${clientCheckOut.toLocal().minute}";
    }
    if (element.checkInCheckOutDetails?.clientBreakTime != null &&
        element.checkInCheckOutDetails?.clientBreakTime != 0) {
      dailyStatistics.clientBreakTime = "${element.checkInCheckOutDetails?.clientBreakTime ?? 0} min";
    }

    DateTime? tempCheckInTime = clientCheckIn ?? employeeCheckIn;
    DateTime? tempCheckOutTime = clientCheckOut ?? employeeCheckout;
    int? tempBreakTime = (element.checkInCheckOutDetails?.clientBreakTime ?? 0) == 0
        ? (element.checkInCheckOutDetails?.breakTime ?? 0)
        : (element.checkInCheckOutDetails?.clientBreakTime ?? 0);
    int? tempWorkingTimeInMinute = _getWorkingTimeInMinute(tempCheckInTime, tempCheckOutTime, tempBreakTime);

    if ((tempCheckInTime) != null) {
      dailyStatistics.date = DateTime.parse(tempCheckInTime.toLocal().toString().split(" ").first).dMMMy;
      dailyStatistics.displayCheckInTime = "${tempCheckInTime.toLocal().hour} : ${tempCheckInTime.toLocal().minute}";
    }

    if (tempCheckOutTime != null) {
      dailyStatistics.displayCheckOutTime = "${tempCheckOutTime.toLocal().hour} : ${tempCheckOutTime.toLocal().minute}";
    }

    if (tempBreakTime != 0) {
      dailyStatistics.displayBreakTime = "$tempBreakTime min";
    }

    // working time and amount
    if (tempWorkingTimeInMinute != null) {
      dailyStatistics.totalWorkingTimeInMinute = tempWorkingTimeInMinute;
      dailyStatistics.workingHour = minuteToHour(tempWorkingTimeInMinute);
      dailyStatistics.amount =
          ((tempWorkingTimeInMinute / 60) * (element.employeeDetails?.hourlyRate ?? 0)).toStringAsFixed(1);
    }

    dailyStatistics.restaurantName = element.restaurantDetails?.restaurantName ?? '';
    dailyStatistics.employeeName = element.employeeDetails?.name ?? '';
    dailyStatistics.position = element.employeeDetails?.positionName ?? '';
    dailyStatistics.complain = '-';
    return dailyStatistics;
  }

  static EmployeePaymentModel employeePaymentHistory(EmployeePaymentHistoryModel element) {
    EmployeePaymentModel employeePayment = EmployeePaymentModel(
        week: "-",
        contractor: '-',
        restaurantName: '-',
        position: '-',
        contractorPerHoursRate: 0.0,
        totalHours: 0.0,
        employeeAmount: 0.0,
        status: '-');

    DateTime? fromDate = element.fromDate;
    DateTime? toDate = element.toDate;

    if (fromDate != null && toDate != null) {
      employeePayment.week = "${fromDate.toLocal().dMMMy} - ${toDate.toLocal().dMMMy}";
    }
    employeePayment.contractor = element.employeeName ?? '';
    employeePayment.restaurantName = element.restaurantName ?? '';
    employeePayment.position = element.positionName ?? '';
    employeePayment.contractorPerHoursRate = element.contractorHourlyRate ?? 0.0;
    employeePayment.totalHours = element.totalHours ?? 0.0;
    employeePayment.employeeAmount = element.employeeAmount ?? 0.0;
    employeePayment.status = element.status ?? '';
    return employeePayment;
  }

  static String getCurrentTimeWithAMPM() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm a').format(now);
    return formattedTime;
  }

  // Function to generate the PDF
  static Future<File> generatePdfWithImageAndText({required InvoiceModel invoice}) async {
    final pw.Document pdf = pw.Document();
    pw.MemoryImage? image;
    File file;
    file = await assetToFile(MyAssets.logo);
    if (file.existsSync()) {
      image = pw.MemoryImage(file.readAsBytesSync());
    }

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(image!, height: 120, width: 120),
                pw.SizedBox(height: 30), // Add some spacing between image and text
                pw.Text(
                  'MH Premier Staffing Solutions',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('C6A34F'), // Set the text color to blue.
                    fontSize: 30,
                  ),
                ),
                pw.SizedBox(height: 70),
                pw.Row(children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('To:'),
                        pw.SizedBox(height: 10),
                        pw.Text(invoice.restaurantName ?? "", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.restaurantAddress ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.restaurantEmail ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.restaurantPhone ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ])),
                  pw.Expanded(flex: 1, child: pw.Wrap())
                ]),
                pw.SizedBox(height: 20),
                pw.Row(children: [
                  pw.Expanded(flex: 1, child: pw.Wrap()),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                        pw.Text('Invoice N: ${invoice.invoiceNumber}'),
                        pw.Text('Invoice date: ${DateFormat('d MMMM, y').format(invoice.invoiceDate!)}')
                      ]))
                ]),
                pw.SizedBox(height: 50),
                pw.Text(
                    '${invoice.restaurantName ?? ''} week from ${DateFormat('d MMMM, y').format(invoice.fromWeekDate!)} to ${DateFormat('d MMMM, y').format(invoice.toWeekDate!)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Text(
                    'Amount: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.amount?.toStringAsFixed(2)}'),
                pw.Text('VAT: ${invoice.vat}%'),
                pw.Text('VAT Amount: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.vatAmount?.toStringAsFixed(2)}'),
                pw.Text(
                    'Platform Fee: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.platformFee?.toStringAsFixed(2)}'),

                pw.Divider(indent: 100, endIndent: 100),
               // pw.SizedBox(height: 10),
                pw.Text(
                    'Total Amount: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.amount?.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 70),
                pw.Row(children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('Bank Transfer:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('MH Premier Staffing Solutions'),
                        pw.Text('48 Warwick St Regent Street W1B 5AW London'),
                        pw.Text('+44 20 3980 9360'),
                        pw.Text('info@mhpremierstaffingsolutions.com'),
                      ])),
                  pw.Expanded(flex: 1, child: pw.Wrap()),
                ]),
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

  static String getCurrencySymbol(String countryName) {
    switch (countryName.toLowerCase()) {
      case 'united kingdom':
        return '£';
      case 'united arab emirates':
        return 'د.إ';
      // Add more cases for other countries as needed
      default:
        return '\$';
    }
  }

  static void showSnackBar({required String message, required bool isTrue}) {
    Get.rawSnackbar(
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10.0),
        title: isTrue == true ? 'Success' : 'Warning!',
        message: message,
        backgroundColor: isTrue == true ? MyColors.c_C6A34F : Colors.red,
        borderRadius: 10.0);
  }
}
