import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_model.dart';
import 'package:mh/app/repository/server_urls.dart';
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

  static String secondToHour(int second) {
    Duration duration = Duration(seconds: second);
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return '${hours}h: ${minutes}m: ${seconds}s';
  }

  static int? _getWorkingTimeInSeconds({DateTime? checkInTime, DateTime? checkOutTime, int? breakTime}) {
    if (checkOutTime == null && checkInTime != null) {
      return getCurrentTime.difference(checkInTime.toLocal()).inSeconds;
    }

    if (checkInTime != null && checkOutTime != null) {
      int timeDifference = checkOutTime.difference(checkInTime).inSeconds;
      return (timeDifference - (breakTime ?? 0) * 60);
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
      totalWorkingTimeInSecond: 0,
    );

    DateTime? employeeCheckIn = element.checkInCheckOutDetails?.checkInTime;
    DateTime? employeeCheckout = element.checkInCheckOutDetails?.checkOutTime;
    DateTime? clientCheckIn = element.checkInCheckOutDetails?.clientCheckInTime;
    DateTime? clientCheckOut = element.checkInCheckOutDetails?.clientCheckOutTime;

    if (employeeCheckIn != null) {
      dailyStatistics.employeeCheckInTime = DateFormat('HH: mm: ss').format(employeeCheckIn);
      //"${employeeCheckIn.toLocal().hour} : ${employeeCheckIn.toLocal().minute}";
    }
    if (employeeCheckout != null) {
      dailyStatistics.employeeCheckOutTime = DateFormat('HH: mm: ss').format(employeeCheckout);
      //"${employeeCheckout.toLocal().hour} : ${employeeCheckout.toLocal().minute}";
    }
    if (element.checkInCheckOutDetails?.breakTime != null && element.checkInCheckOutDetails?.breakTime != 0) {
      dailyStatistics.employeeBreakTime = "${element.checkInCheckOutDetails?.breakTime ?? 0} min";
    }

    if (clientCheckIn != null) {
      dailyStatistics.clientCheckInTime = DateFormat('HH: mm: ss').format(clientCheckIn);
      // "${clientCheckIn.toLocal().hour} : ${clientCheckIn.toLocal().minute}";
    }
    if (clientCheckOut != null) {
      dailyStatistics.clientCheckOutTime = DateFormat('HH: mm: ss').format(clientCheckOut);
      //"${clientCheckOut.toLocal().hour} : ${clientCheckOut.toLocal().minute}";
    }
    if (element.checkInCheckOutDetails?.clientBreakTime != null &&
        element.checkInCheckOutDetails?.clientBreakTime != 0) {
      dailyStatistics.clientBreakTime = "${element.checkInCheckOutDetails?.clientBreakTime ?? 0} min";
    }

    DateTime? tempCheckInTime = employeeCheckIn; //clientCheckIn ?? employeeCheckIn;
    DateTime? tempCheckOutTime = employeeCheckout; //clientCheckOut ?? employeeCheckout;
    int? tempBreakTime = (element.checkInCheckOutDetails?.breakTime ??
        0); /*(element.checkInCheckOutDetails?.clientBreakTime ?? 0) == 0
        ? (element.checkInCheckOutDetails?.breakTime ?? 0)
        : (element.checkInCheckOutDetails?.clientBreakTime ?? 0);*/
    int? tempWorkingTimeInSeconds = _getWorkingTimeInSeconds(
        checkInTime: tempCheckInTime, checkOutTime: tempCheckOutTime, breakTime: tempBreakTime);

    if ((tempCheckInTime) != null) {
      dailyStatistics.date = DateTime.parse(tempCheckInTime.toLocal().toString().split(" ").first).dMMMy;
      dailyStatistics.displayCheckInTime = DateFormat('HH: mm: ss').format(tempCheckInTime);
    }

    if (tempCheckOutTime != null) {
      dailyStatistics.displayCheckOutTime = DateFormat('HH: mm: ss').format(tempCheckOutTime);
    }

    if (tempBreakTime != 0) {
      dailyStatistics.displayBreakTime = "$tempBreakTime min";
    }

    // working time and amount
    if (tempWorkingTimeInSeconds != null) {
      dailyStatistics.totalWorkingTimeInSecond = tempWorkingTimeInSeconds;
      dailyStatistics.workingHour = secondToHour(tempWorkingTimeInSeconds);
      dailyStatistics.amount =
          ((tempWorkingTimeInSeconds / 3600) * (element.employeeDetails?.hourlyRate ?? 0.0)).toStringAsFixed(2);
    }

    dailyStatistics.restaurantName = element.restaurantDetails?.restaurantName ?? '';
    dailyStatistics.employeeName = element.employeeDetails?.name ?? '';
    dailyStatistics.position = element.employeeDetails?.positionName ?? '';
    dailyStatistics.complain = '-';
    return dailyStatistics;
  }

  static EmployeePaymentModel employeePaymentHistory(CheckInCheckOutHistoryElement element) {
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
    employeePayment.restaurantName = element.restaurantDetails?.restaurantName ?? '';
    employeePayment.position = element.employeeDetails?.positionName ?? '';
    employeePayment.contractorPerHoursRate = element.employeeAmount ?? 0.0; //TODO:
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

  // Function to generate the PDF
/*  static Future<File> generatePdfWithImageAndText({required CheckInCheckOutHistoryElement invoice}) async {
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
                  'Plagit',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('58c8c8'), // Set the text color to blue.
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
                        pw.Text(invoice.restaurantDetails?.restaurantName ?? "",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.restaurantDetails?.restaurantAddress ?? '',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.restaurantDetails?.email ?? '',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        // pw.Text(invoice.restaurantDetails?.restaurantPhone ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                        pw.Text('Invoice date: ${DateFormat('d MMMM, y').format(invoice.createdAt!)}')
                      ]))
                ]),
                pw.SizedBox(height: 50),
                pw.Text(
                    '${invoice.restaurantDetails?.restaurantName ?? ''} of ${DateFormat('d MMMM, y').format(invoice.hiredDate!)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Text(
                    'Amount: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.clientAmount?.toStringAsFixed(2)}'),
                pw.Text('VAT: ${invoice.vat}%'),
                pw.Text(
                    'VAT Amount: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.vatAmount?.toStringAsFixed(2)}'),
                pw.Text(
                    'Platform Fee: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.platformFee?.toStringAsFixed(2)}'),

                pw.Divider(indent: 100, endIndent: 100),
                // pw.SizedBox(height: 10),
                pw.Text(
                    'Total Amount: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.totalAmount?.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 70),
                pw.Row(children: [
                  pw.Expanded(
                      flex: 1,
                      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('Bank Transfer:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Plagit'),
                        pw.Text('48 Warwick St Regent Street W1B 5AW London'),
                        pw.Text('+44 20 3980 9360'),
                        pw.Text('info@plagit.com'),
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
  }*/

  static Future<File> generatePdfWithImageAndText(
      {required CheckInCheckOutHistoryElement invoice, required String companyName}) async {
    final pw.Document pdf = pw.Document();
    pw.MemoryImage? image1, image2, image3, image4;
    File file1, file2, file3, file4;
    file1 = await assetToFile(MyAssets.logo);
    if (file1.existsSync()) {
      image1 = pw.MemoryImage(file1.readAsBytesSync());
    }
    file2 = await assetToFile(MyAssets.web);
    if (file2.existsSync()) {
      image2 = pw.MemoryImage(file2.readAsBytesSync());
    }
    file3 = await assetToFile(MyAssets.phone);
    if (file3.existsSync()) {
      image3 = pw.MemoryImage(file3.readAsBytesSync());
    }
    file4 = await assetToFile(MyAssets.email);
    if (file4.existsSync()) {
      image4 = pw.MemoryImage(file4.readAsBytesSync());
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
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Row(children: [
                    pw.Image(image1!, height: 80, width: 80),
                    pw.Text("Plagit",
                        style: pw.TextStyle(
                            fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('58c8c8'))),
                  ]),
                  pw.Text("INVOICE", style: const pw.TextStyle(fontSize: 25)),
                ]),
                pw.SizedBox(height: 30),
                pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40.0),
                    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text(
                          'Payable To',
                          style: pw.TextStyle(
                              color: PdfColors.black, // Set the text color to blue.
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('48 Warwick St, Regent St',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                        pw.Text('London, W1B SAW',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                        pw.Text('VAT number: 450105738',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                      ]),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('Invoice No: ${invoice.invoiceNumber}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                        pw.SizedBox(height: 10),
                        pw.Text('Date: ${DateFormat('d MMM y').format(invoice.createdAt!)}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black))
                      ])
                    ])),
                pw.SizedBox(height: 30),
                pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40.0),
                    child: pw.Row(children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('To',
                                  style: pw.TextStyle(
                                      color: PdfColors.black, // Set the text color to blue.
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold))
                            ]),
                      ),
                      pw.Expanded(
                          flex: 5,
                          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                            pw.Text(invoice.restaurantDetails?.restaurantName ?? "",
                                style:
                                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                            pw.SizedBox(height: 10),
                            pw.Text(companyName,
                                style:
                                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                            pw.Text(invoice.restaurantDetails?.restaurantAddress ?? '',
                                style:
                                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                            pw.Text(invoice.restaurantDetails?.email ?? '',
                                style:
                                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black))
                          ])),
                    ])),
                pw.SizedBox(height: 30),
                pw.Container(
                    padding: const pw.EdgeInsets.all(10.0),
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('58c8c8').shade(0.2)),
                    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                      pw.Text('NAME',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('POSITION',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('RATE',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('TOTAL HOUR',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('AMOUNT',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white))
                    ])),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Text(invoice.employeeDetails?.name ?? "",
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  pw.SizedBox(width: 20),
                  pw.Text(invoice.employeeDetails?.positionName ?? "",
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  pw.SizedBox(width: 60),
                  pw.Text(
                      "${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.employeeDetails?.hourlyRate ?? 0.0}",
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  pw.SizedBox(width: 80),
                  pw.Text(invoice.workedHour ?? "",
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  pw.SizedBox(width: 110),
                  pw.Text(
                      '${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.clientAmount?.toStringAsFixed(2)}  ',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black))
                ]),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.grey400, height: 0.0, thickness: 0.1),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Expanded(flex: 1, child: pw.Wrap()),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                        pw.Text('VAT: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                        pw.Text('${invoice.vat}% = ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                        pw.Text(
                            '${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.vatAmount?.toStringAsFixed(2)}  ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black))
                      ]))
                ]),
                pw.SizedBox(height: 10),
                pw.Row(children: [
                  pw.Expanded(flex: 1, child: pw.Wrap()),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                        pw.Text('Platform Fee: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black)),
                        pw.Text(
                            '${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.platformFee?.toStringAsFixed(2)}  ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.black))
                      ]))
                ]),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.grey900, height: 0.0,indent: 400, thickness: 2.0),
                pw.SizedBox(height: 10),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Text(
                      'TOTAL: ${getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${invoice.totalAmount?.toStringAsFixed(2)}  ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
                ]),
                pw.SizedBox(height: 80),
                pw.Center(
                    child: pw.Container(
                        height: 130,
                        width: double.infinity,
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex('58c8c8').shade(0.2)),
                        child: pw.Container(
                          margin: const pw.EdgeInsets.all(20.0),
                          padding: const pw.EdgeInsets.all(20.0),
                          child: pw.Column(children: [
                            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly, children: [
                              pw.Row(children: [
                                pw.Image(image2!, height: 20, width: 20),
                                pw.Text("www.plagit.com",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.white)),
                              ]),
                              pw.Row(children: [
                                pw.Image(image3!, height: 20, width: 20),
                                pw.Text("07960966110",
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.white))
                              ])
                            ]),
                            pw.SizedBox(height: 10),
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                              pw.Image(image4!, height: 20, width: 20),
                              pw.Text("support@plagit.com",
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.white))
                            ])
                          ]),
                          decoration:
                              pw.BoxDecoration(color: PdfColors.black, borderRadius: pw.BorderRadius.circular(50.0)),
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
        title: isTrue == true ? MyStrings.success.tr : MyStrings.warning.tr,
        message: message,
        backgroundColor: isTrue == true ? MyColors.c_C6A34F : Colors.red,
        borderRadius: 10.0);
  }

  static Future<String?> uploadProfileImage({required File imageFile}) async {
    try {
      http.MultipartRequest request =
          http.MultipartRequest('PUT', Uri.parse("${ServerUrls.serverLiveUrlUser}users/update-profile-image"));
      request.headers['Authorization'] = "Bearer ${StorageHelper.getToken}";
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path, contentType: MediaType('image', 'jpeg')));

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
}
