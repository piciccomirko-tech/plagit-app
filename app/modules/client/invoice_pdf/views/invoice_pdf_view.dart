import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import '../controllers/invoice_pdf_controller.dart';

class InvoicePdfView extends GetView<InvoicePdfController> {
  const InvoicePdfView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onDownloadPressed,
        backgroundColor: MyColors.c_C6A34F,
        child: const Icon(Icons.download, color: MyColors.c_FFFFFF),
      ),
      appBar: CustomAppbar.appbar(
        title: MyStrings.invoice.tr,
        context: context,
      ),
      body: PDFView(
        filePath: controller.invoiceFile.path,
        autoSpacing: false,
      ),
    );
  }
}
