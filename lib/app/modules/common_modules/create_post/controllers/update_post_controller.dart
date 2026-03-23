import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import 'package:mh/app/modules/employee/employee_root/controllers/employee_root_controller.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:mh/core/loggers/logger.dart';
import 'package:mh/app/common/background_service/background_upload_service.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/add_social_media_request_model.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/common_modules/create_post/models/post_upload_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

import '../../../../../domain/repositories/social_post_repository.dart';

class UpdatePostController extends GetxController {
  final SocialPostRepository socialPostRepository;
  UpdatePostController({
    required this.socialPostRepository,
  });

  SocialPostModel? socialPost;
  // String title = '';

  final ImagePicker _picker = ImagePicker();
  final RxList<String> _selectedFiles = <String>[].obs;
  final RxMap<String, String> _videoThumbnails = <String, String>{}.obs;
  final RxMap<String, bool> _thumbnailLoadingStates = <String, bool>{}.obs;
  final TextEditingController descriptionController = TextEditingController();
  var newTextContent = ''.obs;
  final RxBool isUploading = false.obs;
  final RxBool isExistingMedia = false.obs;
  final isAllDataGenerated = false.obs;

  List<String> get selectedFiles => _selectedFiles;
  Map<String, String> get videoThumbnails => _videoThumbnails;
  Map<String, bool> get thumbnailLoadingStates => _thumbnailLoadingStates;
  bool get uploading => isUploading.value;
  bool get existingMedia => isExistingMedia.value;

  final ApiHelper _apiHelper = Get.find();
  RxList<SocialMedia> mediaPathList = <SocialMedia>[].obs;

  // Add dimension map
  final RxMap<String, Map<String, double>> _fileDimensions =
      <String, Map<String, double>>{}.obs;

  @override
  Future<void> onInit() async {
    if (Get.arguments != null) {
      socialPost = Get.arguments[0];
      // title = Get.arguments[1];
      await _getSocialData();
      isAllDataGenerated.value = true;
    } else {
      isAllDataGenerated.value = true;
    }
    // print('NewCreatePostController.onInit:${socialPost?.media?.first.localPath}');
    super.onInit();
  }

  Future<void> _getSocialData() async {
    if (socialPost == null) return;

    descriptionController.text = socialPost?.content ?? "";
    final mediaList = socialPost?.media ?? [];

    if (mediaList.isEmpty) {
      isAllDataGenerated.value = true;
      return;
    }

    isExistingMedia.value = true;
    mediaPathList.assignAll(
      mediaList.map((media) => SocialMedia(
            url: media.url ?? "",
            type: media.type ?? "",
          )),
    );

    final tempDir = await getTemporaryDirectory();

    // Split media into videos and images for optimized processing
    final videos =
        mediaList.where((m) => m.type?.toLowerCase() == 'video').toList();
    final images =
        mediaList.where((m) => m.type?.toLowerCase() != 'video').toList();

    // Process images first (faster)
    if (images.isNotEmpty) {
      await Future.wait(images.map((media) async {
        final mediaUrl = media.url?.socialMediaUrl ?? "";
        if (mediaUrl.isEmpty) return;

        try {
          final fileName = mediaUrl.split('/').last;
          final file = File('${tempDir.path}/$fileName');

          if (await file.exists()) {
            // Get dimensions from URL using Media's method
            final dimensions = media.getDimensionsFromUrl();
            _fileDimensions[file.path] = dimensions;
            _selectedFiles.add(file.path);
            return;
          }

          final response = await http.get(Uri.parse(mediaUrl));
          if (response.statusCode == 200) {
            await file.writeAsBytes(response.bodyBytes);
            // Get dimensions from URL using Media's method
            final dimensions = media.getDimensionsFromUrl();
            _fileDimensions[file.path] = dimensions;
            _selectedFiles.add(file.path);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error processing image: $e');
          }
        }
      }));
    }

    // Then process videos
    if (videos.isNotEmpty) {
      final tempDir2 = await getTemporaryDirectory();
      final int maxConcurrentDownloads = 5;
      final client = http.Client();
      final List<Future<void>> downloadTasks = [];

      for (var media in videos) {
        if (downloadTasks.length >= maxConcurrentDownloads) {
          await Future.any(downloadTasks);
        }
        downloadTasks
            .add(_downloadVideoWithDimensions(media, tempDir2, client));
      }

      await Future.wait(downloadTasks);
      client.close();
    }

    mediaPathList.refresh();
    _selectedFiles.refresh();
    isAllDataGenerated.value = true;
  }

  Future<void> _downloadVideoWithDimensions(
      Media media, Directory tempDir, http.Client client) async {
    final mediaUrl = media.url?.socialMediaUrl ?? "";
    if (mediaUrl.isEmpty) {
      if (kDebugMode) {
        print('❌ Skipping: Invalid URL');
      }
      return;
    }

    final fileName = mediaUrl.split('/').last;
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      if (kDebugMode) {
        print('✅ File already exists: $filePath');
      }
      // Get dimensions from URL using Media's method
      final dimensions = media.getDimensionsFromUrl();
      _fileDimensions[filePath] = dimensions;
      _selectedFiles.add(filePath);
      return;
    }

    try {
      if (kDebugMode) {
        print('⬇️ Downloading: $mediaUrl');
      }

      final request = http.Request('GET', Uri.parse(mediaUrl));
      request.headers['Connection'] = 'Keep-Alive';
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final fileStream = file.openWrite();
        await response.stream.pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();

        // Get dimensions from URL using Media's method
        final dimensions = media.getDimensionsFromUrl();
        _fileDimensions[filePath] = dimensions;
        _selectedFiles.add(filePath);
        if (kDebugMode) {
          print('✅ Download complete: $filePath');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to download: ${response.statusCode} -> $mediaUrl');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error downloading video: $e');
      }
    }
  }

  Future<void> _generateAndSaveThumbnail(
      String videoPath, String thumbnailPath) async {
    _thumbnailLoadingStates[videoPath] = true;
    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 100, // Limit height for faster processing
        maxWidth: 100, // Limit width for faster processing
        quality: 50, // Lower quality for faster generation
        timeMs: 1000, // Take thumbnail from 1 second mark
      );
      if (thumbnail != null) {
        _videoThumbnails[videoPath] = thumbnail;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating thumbnail: $e');
      }
    } finally {
      _thumbnailLoadingStates[videoPath] = false;
    }
  }

  Future<void> pickMultipleMediaFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result?.files.isEmpty ?? true) {
        Log.debug('No file selected');
        return;
      }

      for (var pickedFile in result!.files) {
        final File file = File(pickedFile.path!);
        final int fileSize = await file.length();

        if (fileSize > 200 * 1024 * 1024) {
          largeFileUploadingErrorSnackbar();
          continue;
        }

        final bool isVideo = pickedFile.extension!.toLowerCase() == 'mp4' ||
            pickedFile.extension!.toLowerCase() == 'mov';

        if (isVideo) {
          _thumbnailLoadingStates[pickedFile.path!] = true;
          _selectedFiles.add(pickedFile.path!);
          await generateVideoThumbnail(pickedFile.path!);
        } else {
          // For images, get dimensions directly
          final dimensions = await _getImageDimensions(pickedFile.path!);
          _fileDimensions[pickedFile.path!] = dimensions;
          _selectedFiles.add(pickedFile.path!);

          if (kDebugMode) {
            print(
              'Image dimensions: ${dimensions['width']}x${dimensions['height']}');
          }
        }
      }

      _selectedFiles.refresh();
    } catch (e) {
      Log.debug('Error picking media: $e');
      Get.snackbar('Error', 'Error selecting media: ${e.toString()}');
    }
  }

  Future<void> pickMedia() async {
    try {
      // Pick media (both image and video)
      final XFile? pickedFile = await _picker.pickMedia();

      if (pickedFile == null) return; // Exit if no file is selected

      final File file = File(pickedFile.path);
      final int fileSize = await file.length(); // Get file size in bytes

      // Check if the file size exceeds 200MB
      if (fileSize > 200 * 1024 * 1024) {
        if (Get.isRegistered<ScaffoldMessenger>()) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(
              content:
                  Text('File size too large. Please select a smaller file.'),
            ),
          );
        }
        return; // Exit if file is too large
      }

      // Determine if the file is an image or a video
      final bool isVideo = pickedFile.path.toLowerCase().endsWith('.mp4') ||
          pickedFile.path.toLowerCase().endsWith('.mov');

      if (isVideo) {
        _thumbnailLoadingStates[pickedFile.path] = true; // Set loading state
        _selectedFiles.add(pickedFile.path);
        await generateVideoThumbnail(
            pickedFile.path); // Generate thumbnail for video
      } else {
        _selectedFiles.add(pickedFile.path); // Add image to the list
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking media: $e');
      }
      Get.snackbar('Error', 'Error selecting media: ${e.toString()}');
    }
  }

  Future<void> generateVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );

      if (thumbnailPath != null) {
        // Get dimensions from thumbnail
        final dimensions = await _getImageDimensions(thumbnailPath);
        _fileDimensions[videoPath] = dimensions;

        _videoThumbnails[videoPath] = thumbnailPath;
        _thumbnailLoadingStates[videoPath] = false;

        if (kDebugMode) {
          print(
            'Video dimensions: ${dimensions['width']}x${dimensions['height']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating thumbnail: $e');
      }
    }
  }

  /*Future<void> createPost(BuildContext context) async {
    if (descriptionController.text.trim().isEmpty && _selectedFiles.isEmpty) {
      emptyContentErrorSnackbar();
      return;
    }

    Get.back();
    isUploading.value = true;

    try {
      final post = PostUpload(
        mediaFiles: _selectedFiles,
        caption: newTextContent.value,
      );

      await BackgroundUploadService.startUpload(post, StorageHelper.getToken);

      _selectedFiles.clear();
      _videoThumbnails.clear();
      descriptionController.clear();
      isUploading.value = false;

      if (Get.isRegistered<ScaffoldMessenger>()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Upload started. You can close the app, and we\'ll notify you when it\'s done.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      isUploading.value = false;

      if (Get.isRegistered<ScaffoldMessenger>()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to start upload. Please try again.')),
        );
      }
    }
  }*/

  Future<void> updatePost(BuildContext context) async {
    if (descriptionController.text.trim().isEmpty && _selectedFiles.isEmpty) {
      emptyContentErrorSnackbar();
      return;
    }

    Get.back();
    isUploading.value = true;

    try {
      final post = PostUpload(
        mediaFiles: _selectedFiles.map((file) {
          final dimensions =
              _fileDimensions[file] ?? {'width': 16, 'height': 9};
          return MediaFileInfo(
            url: file,
            width: dimensions['width']!,
            height: dimensions['height']!,
          );
        }).toList(),
        caption: newTextContent.value,
      );

      await BackgroundUploadService.startUpload(
        post,
        StorageHelper.getToken,
        postId: socialPost?.id ?? '',
      );

      _selectedFiles.clear();
      _videoThumbnails.clear();
      _fileDimensions.clear(); // Clear dimensions
      descriptionController.clear();
      isUploading.value = false;

      if (Get.isRegistered<ScaffoldMessenger>()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Update started. You can close the app, and we\'ll notify you when it\'s done.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      isUploading.value = false;
      if (Get.isRegistered<ScaffoldMessenger>()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to start update. Please try again.')),
        );
      }
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  String get name {
    if (Get.isRegistered<ClientHomePremiumController>()) {
      return (Get.find<ClientHomePremiumController>()
              .client
              .value
              .details
              ?.restaurantName ??
          "");
    } else if (Get.isRegistered<AdminHomeController>()) {
      return (socialPost?.user?.name ?? "");
    } else {
      return "${(Get.find<EmployeeHomeController>().employee.value.details?.firstName ?? "")} ${(Get.find<EmployeeHomeController>().employee.value.details?.lastName ?? "")}";
    }
  }

  String get getProfilePictureUrl {
    if (Get.isRegistered<ClientHomePremiumController>()) {
      return (Get.find<ClientHomePremiumController>()
              .client
              .value
              .details
              ?.profilePicture ??
          "");
    } else if (Get.isRegistered<AdminHomeController>()) {
      return (socialPost?.user?.profilePicture ?? "");
    } else {
      return (Get.find<EmployeeHomeController>()
              .employee
              .value
              .details
              ?.profilePicture) ??
          "";
    }
  }

  void updateSocialPost(BuildContext context) async {
    if (descriptionController.text.trim().isEmpty && mediaPathList.isEmpty) {
      emptyContentErrorSnackbar();
      return;
    }

    AddSocialMediaRequestModel addSocialMediaRequestModel =
        AddSocialMediaRequestModel(
      content: descriptionController.text,
      media: mediaPathList,
    );

    CustomLoader.show(context);

    Either<CustomError, CommonResponseModel> responseData =
        await _apiHelper.updateSocialPost(
            addSocialMediaRequestModel: addSocialMediaRequestModel,
            postId: socialPost?.id ?? '');

    CustomLoader.hide(context);

    responseData.fold(
      (CustomError customError) {
        Utils.errorDialog(context, customError);
      },
      (CommonResponseModel response) async {
        if (response.status == "success") {
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);

          _navigateToHome();
        } else {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      },
    );
  }

  void _navigateToHome() {
    if (Get.isRegistered<ClientPremiumRootController>()) {
      Get.offAllNamed(Routes.clientPremiumRoot);
    } else if (Get.isRegistered<EmployeeRootController>()) {
      Get.offAllNamed(Routes.employeeRoot);
    }
  }

  void emptyContentErrorSnackbar() {
    Utils.showSnackBar(
      message: "Please add content or media before creating a post.",
      isTrue: false,
    );
  }

  void largeFileUploadingErrorSnackbar() {
    Utils.showSnackBar(
      message: "File size too large. Please select smaller files.",
      isTrue: false,
    );
  }

  // Add helper method to get image dimensions
  Future<Map<String, double>> _getImageDimensions(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final Uint8List bytes = await imageFile.readAsBytes();
      final image = await decodeImageFromList(bytes);

      return {
        'width': image.width.toDouble(),
        'height': image.height.toDouble(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image dimensions: $e');
      }
      return {'width': 16, 'height': 9};
    }
  }
}
