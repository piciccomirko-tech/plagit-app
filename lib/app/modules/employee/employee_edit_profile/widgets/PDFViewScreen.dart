import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../../common/widgets/custom_appbar.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfPath;

  PdfViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "PDF  Viewer",

        context: context,
        centerTitle: true,
      ),
      body: PDFView(
        filePath: pdfPath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
        nightMode: true,
        onError: (error) {
          if (kDebugMode) {
            print(error.toString());
          }
        },
        onRender: (pages) {
          if (kDebugMode) {
            print("Rendered $pages pages");
          }
        },
      ),
    );
  }
}
