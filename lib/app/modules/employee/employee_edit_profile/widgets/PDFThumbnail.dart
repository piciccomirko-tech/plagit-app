
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:url_launcher/url_launcher.dart';

import 'PDFViewScreen.dart';

class PdfThumbnailWidget extends StatefulWidget {
  final String pdfUrl;
  final String certificateName;
  final String certificateId;
  final bool? isRemoveIcon;
  final Function(String) onDelete; // Callback for deletion

  PdfThumbnailWidget({
    required this.pdfUrl,
    required this.certificateName,
    required this.certificateId,
    required this.onDelete,
    this.isRemoveIcon,
  });

  @override
  _PdfThumbnailWidgetState createState() => _PdfThumbnailWidgetState();
}

class _PdfThumbnailWidgetState extends State<PdfThumbnailWidget> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    // log("url: ${widget.pdfUrl}");
    try {
      if (widget.pdfUrl.startsWith('http')) {
        // Attempt to download and cache the file if it's a remote URL
        final file = await DefaultCacheManager().getSingleFile(widget.pdfUrl);
        if (mounted) {
          setState(() {
            localFilePath = file.path; // Set the local file path
          });
        }
      } else {
        // Use the local file path directly if it's not a URL
        if (mounted) {
          setState(() {
            localFilePath = widget.pdfUrl;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          localFilePath = widget.pdfUrl;
        });
      }
      // Log the error and avoid calling setState if an error occurs
      if (kDebugMode) {
        print("Error downloading or setting PDF file path: $e");
      }
    }
  }
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text("${widget.pdfUrl}"),
        Stack(
          children: [
            Container(
              width: 100.w, // Thumbnail width
              height: 140.h, // Thumbnail height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: localFilePath != null
                  ? PDFView(
                      filePath: localFilePath,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                      defaultPage: 0, // Display the first page
                      onRender: (pages) {
                        if (kDebugMode) {
                          print("Rendered PDF with $pages pages");
                        }
                      },
                      onError: (error) {
                        if (kDebugMode) {
                          print("Error rendering PDF: $error");
                        }
                      },
                    )  
                  : 
                   GestureDetector(
                    onTap: () {
    _launchURL(widget.pdfUrl);
  },
                     child: Center(
                              child: Text(
                        "Download",
                        style: TextStyle(color: Colors.white),
                      )),
                   ),
                  // Center(
                  //     child: CupertinoActivityIndicator(), // Loading indicator
                  //   ),
            ),
            if (localFilePath != null && localFilePath!.isNotEmpty)
              Positioned(
                left: 10.w,
                bottom: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PdfViewerScreen(pdfPath: localFilePath!),
                      ),
                    );
                  },
                  child: Container(
                    // width: Get.width,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: ShapeDecoration(
                        color: MyColors.primaryDark,
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.elliptical(30, 40),
                                right: Radius.elliptical(30, 40)))),
                    child:
                        //  Icon(Icons.preview_sharp, color: Colors.white,)
                        Center(
                            child: Text(
                      "Preview",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
              ),
        if( widget.isRemoveIcon!=null && widget.isRemoveIcon==true)
          Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                // color: Colors.red,
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Color.fromARGB(5, 255, 0, 0))),
                // padding: EdgeInsets.all(15),
                onPressed: () => widget.onDelete(widget.certificateId),
                icon: Icon(Icons.clear, color: Colors.red, size: 25),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          widget.certificateName.length > 20
              ? '${widget.certificateName.substring(0, 17)}...'
              : widget.certificateName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(fontSize: 13),
        ),
        // Text("${widget.pdfUrl}")
      ],
    );
  }
}
