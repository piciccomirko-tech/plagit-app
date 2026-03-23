import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common/values/my_color.dart';
import 'PDFViewScreen.dart';
import 'full_screen_image_view.dart';

class FileThumbnailWidget extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String fileId;
  final Function(String) onDelete;

  FileThumbnailWidget({
    required this.fileUrl,
    required this.fileName,
    required this.fileId,
    required this.onDelete,
  });

  @override
  _FileThumbnailWidgetState createState() => _FileThumbnailWidgetState();
}

class _FileThumbnailWidgetState extends State<FileThumbnailWidget> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      if (widget.fileUrl.startsWith('http')) {
        final file = await DefaultCacheManager().getSingleFile(widget.fileUrl);
        if (mounted) {
          setState(() {
            localFilePath = file.path;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            localFilePath = widget.fileUrl;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          localFilePath = widget.fileUrl;
        });
      }
      if (kDebugMode) {
        print("Error downloading file: $e");
      }
    }
  }

  Widget _buildThumbnail() {
    if (kDebugMode) {
      print('fillllle: ${widget.fileUrl}');
    }
    if (widget.fileUrl.endsWith('.pdf')) {
      // Show first page of the PDF as a thumbnail
      return localFilePath != null
          ? PDFView(
              filePath: localFilePath,
              enableSwipe: false,
              swipeHorizontal: false,
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
          : Center(child: CircularProgressIndicator());
    }else if (widget.fileUrl.endsWith('.jpg')||widget.fileUrl.endsWith('.jpeg')||widget.fileUrl.endsWith('.png')) {
      // Show first page of the PDF as a thumbnail
      return localFilePath != null
          // ? widget.fileUrl.startsWith('/data')?Text('local'):Text( 'remote')
          ? Image.file(File(localFilePath.toString()))
          : Center(child: CircularProgressIndicator());
    } else {
      // Display a generic file icon for non-PDF files
      return Icon(
        Icons.insert_drive_file,
        color: Colors.grey,
        size: 50,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text("path: ${widget.fileUrl}"),
        // Text("local path: ${localFilePath}"),
        Stack(
          children: [
            Container(
              width: 100, // Thumbnail width
              height: 140, // Thumbnail height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: _buildThumbnail(),
            ),
            if (localFilePath != null && localFilePath!.isNotEmpty)
              Positioned(
                left: 10.w,
                bottom: 5,
                child: GestureDetector(
                  onTap: () {
                    if(widget.fileUrl.endsWith('.pdf')){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PdfViewerScreen(pdfPath: localFilePath!),
                          ),
                    );
                    }else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImageView(fileUrl: localFilePath!,),
                        ),
                      );

                    }
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
            // Positioned(
            //   right: 0,
            //   top: 0,
            //   child:
            //   IconButton(
            //     // color: Colors.red,
            //     style: ButtonStyle(
            //         backgroundColor:
            //         WidgetStatePropertyAll(Color.fromARGB(5, 255, 0, 0))),
            //     // padding: EdgeInsets.all(15),
            //     onPressed: () => widget.onDelete(widget.fileId),
            //     icon: Icon(Icons.clear, color: Colors.red, size: 25),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          widget.fileName.length > 20
              ? '${widget.fileName.substring(0, 17)}...'
              : widget.fileName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
