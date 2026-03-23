import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_loader.dart';

class InvoicePdfController extends GetxController {
  late File invoiceFile;
  late String invoiceDownloadLink;
  late BuildContext context;

  @override
  void onInit() {
    invoiceFile = Get.arguments[0];
    try {
      invoiceDownloadLink = Get.arguments[1];
    }catch(e){
      invoiceDownloadLink = '';
    }
    super.onInit();
  }

  void onDownloadPressed() async {
    try {
      Uri url = Uri.parse(invoiceDownloadLink);
      if (await canLaunchUrl(url)) {
        Platform.isAndroid
            ? await launchUrl(url)
            : await _saveFile(invoiceFile);
      } else {
        throw 'Could not launch $url';
      }
    } catch (_) {}
    // if (invoiceFile.path.isNotEmpty) {
    //   // Show custom loader before the download starts
    //   CustomLoader.show(context);
    //   await downloadInvoicePDF(File(invoiceFile.path));
    //   // Hide custom loader after the download is completed
    //   CustomLoader.hide(context);
    // } else {
    //   Utils.showSnackBar(
    //       message: MyStrings.generateInvoiceFirst.tr, isTrue: false);
    // }
  }

  // Function to download the invoice PDF to the Downloads folder.
  Future<void> downloadInvoicePDF(File invoiceFile) async {
    try {
      // Ensure permission is granted on Android
      if (Platform.isAndroid) {
        await _saveFile(invoiceFile);
      } else if (Platform.isIOS) {
        // For iOS, just proceed with saving since permission is not required in the same way
        await _saveFile(invoiceFile);
      }
    } catch (error) {
      Utils.showSnackBar(
        message: "Error during the download process",
        isTrue: false,
      );
    } finally {
      // Ensure loader is hidden in case of errors or success
      CustomLoader.hide(context);
    }
  }


  Future<void> _saveFile(File invoiceFile) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (Platform.isAndroid) {
      // For Android, get Downloads directory
      final Directory? downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir!=null) {
        final String downloadPath = '${downloadsDir.path}/invoice_$timestamp.pdf';
        final File newFile = await invoiceFile.copy(downloadPath);

        var r= await FileSaver.instance.saveFile(
          name: "invoice_$timestamp",
          bytes: newFile.readAsBytesSync(),
          ext: "pdf",
          mimeType: MimeType.pdf,
        );

        print(r);
        Utils.showSnackBar(
          message: MyStrings.invoicePdfDownload.tr,
          isTrue: true,
        );
      } else {
        Utils.showSnackBar(
          message: "Download path error",
          isTrue: false,
        );
      }
    } else if (Platform.isIOS) {
      // For iOS, use application documents directory
      final Directory iosDir = await getApplicationDocumentsDirectory();
      final String downloadPath = '${iosDir.path}/invoice_$timestamp.pdf';
      final File newFile = await invoiceFile.copy(downloadPath);

      var r = await FileSaver.instance.saveFile(
        name: "invoice_$timestamp",
        bytes: newFile.readAsBytesSync(),
        ext: "pdf",
        mimeType: MimeType.pdf,
      );
print(r);
      Utils.showSnackBar(
        message: MyStrings.invoicePdfDownload.tr,
        isTrue: true,
      );
    }
  }
}
