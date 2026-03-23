

class DownloadManager {

/*
 static Future<void> downloadMediaIOS({required Media media, required BuildContext context}) async {
    // Request storage permission
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        if (media.type == 'image') {
          CustomLoader.show(context);

          // Download the image
          var response = await Dio().get(
            (media.url ?? "").imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );

          // Save the image using image_gallery_saver_plus
          final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.data),
            name: (media.url ?? "").imageUrl
                .split('/')
                .last
                .split('.')
                .first,
          );
          CustomLoader.hide(context);

          if (result['isSuccess']) {
            Utils.showSnackBar(
              message: MyStrings.imageDownloadedSuccessfully.tr,
              isTrue: true,
            );
          } else {
            Utils.showSnackBar(
                message: MyStrings.failedToSaveImage.tr, isTrue: false);
          }
        } else if (media.type == 'video') {
          CustomLoader.show(context);
          // Download the video
          var response = await Dio().get(
            (media.url ?? "").imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );

          // Get the directory for saving the video
          Directory? directory;
          if (Platform.isAndroid) {
            directory = await getExternalStorageDirectory();
            String newPath =
            path.join(directory!.path, 'Movies', 'DownloadedVideos');
            directory = Directory(newPath);
          } else if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
          }

          // Create the directory if it doesn't exist
          if (!await directory!.exists()) {
            await directory.create(recursive: true);
          }

          // Create the file path and save the video
          String fileName = (media.url ?? "").imageUrl
              .split('/')
              .last;
          String filePath = path.join(directory.path, fileName);

          File file = File(filePath);
          await file.writeAsBytes(Uint8List.fromList(response.data));

          // Save the video file using image_gallery_saver_plus
          final result = await ImageGallerySaver.saveFile(file.path);

          CustomLoader.hide(context);

          if (result['isSuccess']) {
            Utils.showSnackBar(
              message: MyStrings.videoDownloadedSuccessfully.tr,
              isTrue: true,
            );
          } else {
            Utils.showSnackBar(
                message: MyStrings.failedToSaveVideo.tr, isTrue: false);
          }
        }
      } catch (e) {
        Utils.showSnackBar(
            message: "${MyStrings.failedToDownload.tr} ${media.type}",
            isTrue: false);
      }
    } else {
      Utils.showSnackBar(
          message: MyStrings.storagePermissionDenied.tr, isTrue: false);
    }
  }
*/

/*  static Future<void> downloadMediaAndroid(
      {required Media media, required BuildContext context})
  async {
    PermissionStatus status;

    // Check the platform and request the appropriate permissions
    if (Platform.isAndroid) {
      status = await Permission.manageExternalStorage.request();
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = PermissionStatus.denied;
    }

    if (status.isGranted) {
      try {
        if (media.type == 'image') {
          CustomLoader.show(context);

          // Download the image
          var response = await Dio().get(
            (media.url ?? "").imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );

          // Save the image using image_gallery_saver_plus
          final result = await ImageGallerySaverPlus.saveImage(
            Uint8List.fromList(response.data),
            name: (media.url ?? "").imageUrl.split('/').last.split('.').first,
          );
          CustomLoader.hide(context);

          if (result['isSuccess']) {
            Utils.showSnackBar(
              message: MyStrings.imageDownloadedSuccessfully.tr,
              isTrue: true,
            );
          } else {
            Utils.showSnackBar(
                message: MyStrings.failedToSaveImage.tr, isTrue: false);
          }
        } else if (media.type == 'video') {
          CustomLoader.show(context);

          // Download the video
          var response = await Dio().get(
            (media.url ?? "").imageUrl,
            options: Options(responseType: ResponseType.bytes),
          );

          // Get the directory for saving the video
          Directory? directory;
          if (Platform.isAndroid) {
            directory = await getExternalStorageDirectory();
            String newPath =
                path.join(directory!.path, 'Movies', 'DownloadedVideos');
            directory = Directory(newPath);
          } else if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
          }

          // Create the directory if it doesn't exist
          if (!await directory!.exists()) {
            await directory.create(recursive: true);
          }

          // Create the file path and save the video
          String fileName = (media.url ?? "").imageUrl.split('/').last;
          String filePath = path.join(directory.path, fileName);

          File file = File(filePath);
          await file.writeAsBytes(Uint8List.fromList(response.data));

          // Save the video file using image_gallery_saver_plus
          final result = await ImageGallerySaverPlus.saveFile(file.path);

          CustomLoader.hide(context);

          if (result['isSuccess']) {
            Utils.showSnackBar(
              message: MyStrings.videoDownloadedSuccessfully.tr,
              isTrue: true,
            );
          } else {
            Utils.showSnackBar(
                message: MyStrings.failedToSaveVideo.tr, isTrue: false);
          }
        }
      } catch (e) {
        CustomLoader.hide(context);
        Utils.showSnackBar(
            message: "${MyStrings.failedToDownload.tr} ${media.type}",
            isTrue: false);
      }
    } else if (status.isDenied) {
      _showPermissionDeniedDialog(context: context);
    } else if (status.isPermanentlyDenied) {
      // Show a dialog that tells the user to manually enable permission in app settings
      _showPermissionPermanentlyDeniedDialog(context: context);
    }
  }

  static void _showPermissionDeniedDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Storage Permission Denied'),
          content: Text(
              'This app requires storage permission to download media. Please allow storage access to proceed.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void _showPermissionPermanentlyDeniedDialog(
      {required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Storage Permission Permanently Denied'),
          content: Text(
              'Storage permission has been permanently denied. You can enable it in the app settings.'),
          actions: <Widget>[
            TextButton(
              child: Text('Go to Settings'),
              onPressed: () {
                openAppSettings(); // Opens the app settings
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/
}


