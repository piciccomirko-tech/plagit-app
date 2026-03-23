import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/add_social_media_request_model.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/upload_file_for_social_feed_model.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import 'package:mh/app/modules/common_modules/create_post/models/social_media_upload_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_root/controllers/employee_root_controller.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:mh/core/loggers/logger.dart';
import 'package:mh/domain/model/start_upload_model.dart';
import 'package:mh/domain/repositories/social_post_repository.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart' as dio;

class CreatePostController extends GetxController {
  CreatePostController({
    required this.socialPostRepository,
  });

  final ApiHelper _apiHelper = Get.find();

  final SocialPostRepository socialPostRepository;

  BuildContext? context;

  var selectedFiles = <PlatformFileUpload>[].obs;

  Rx<SocialMediaUploadResponseModel> socialMediaUploadResponse =
      SocialMediaUploadResponseModel().obs;

  RxList<SocialMedia> mediaPathList = <SocialMedia>[].obs;

  var isUploadLoading = false.obs;

  var newTextContent = ''.obs;

  String title = '';

  var isUploading = false.obs;

  TextEditingController tecContent = TextEditingController();

  SocialPostModel? socialPost;

  var chunkFileName = ''.obs;

  dio.Dio dioInstance = dio.Dio();

  var fileChunkSize = 5 * 1024 * 1024;

  int currentFileNumber = 0;

  @override
  void onInit() {
    if (Get.arguments != null) {
      socialPost = Get.arguments[0];
      title = Get.arguments[1];
      _getSocialData();
    }
    super.onInit();
  }

  void _getSocialData() {
    if (socialPost != null) {
      tecContent.text = socialPost?.content ?? "";
      if ((socialPost?.media ?? []).isNotEmpty) {
        mediaPathList.addAll((socialPost?.media ?? []).map((Media e) {
          return SocialMedia(url: e.url ?? "", type: e.type ?? "");
        }).toList());
      }
      if ((socialPost?.media ?? []).isNotEmpty) {
        selectedFiles.addAll((socialPost?.media ?? []).map((Media e) {
          return PlatformFileUpload(
            uploadPercentage: 100,
            type: e.type ?? "",
            file: PlatformFile(path: e.url ?? '', name: '', size: 0),
            fileSize: 0,
          );
        }).toList());
      }

      selectedFiles.refresh();
      mediaPathList.refresh();
    }
  }

  void createPost() async {
    CustomLoader.show(context!);

    if (tecContent.text.trim().isEmpty && mediaPathList.isEmpty) {
      CustomLoader.hide(context!);
      emptyContentErrorSnackbar();
      return;
    }

    _addSocialPost();

    _navigateToHome();
  }

  void _addSocialPost() {
    AddSocialMediaRequestModel addSocialMediaRequestModel =
        AddSocialMediaRequestModel(
      content: tecContent.text,
      media: mediaPathList,
    );

    _apiHelper
        .addSocialPost(addSocialMediaRequestModel: addSocialMediaRequestModel)
        .then(
      (responseData) {
        CustomLoader.hide(context!);

        responseData.fold(
          (CustomError customError) {
            Utils.errorDialog(context!, customError);
          },
          (CommonResponseModel response) {
            if (response.status == "success") {
              selectedFiles.clear();
              mediaPathList.clear();
              Utils.showSnackBar(message: response.message ?? "", isTrue: true);
            } else {
              Utils.showSnackBar(
                  message: response.message ?? "", isTrue: false);
            }
          },
        );
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

  void updateSocialPost() async {
    AddSocialMediaRequestModel addSocialMediaRequestModel =
        AddSocialMediaRequestModel(
            content: tecContent.text, media: mediaPathList);

    CustomLoader.show(context!);

    Either<CustomError, CommonResponseModel> responseData =
        await _apiHelper.updateSocialPost(
            addSocialMediaRequestModel: addSocialMediaRequestModel,
            postId: socialPost?.id ?? '');

    CustomLoader.hide(context!);

    responseData.fold(
      (CustomError customError) {
        Utils.errorDialog(context!, customError);
      },
      (CommonResponseModel response) async {
        if (response.status == "success") {
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);

          _navigateToHome();

          // if (Get.isRegistered<MySocialFeedController>()) {
          //   Get.find<MySocialFeedController>().getSocialFeeds();
          // } else {
          //   Get.find<AdminHomeController>().getSocialFeeds();
          // }

          //Get.back();
        } else {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      },
    );
  }

  Future<void> filePickAndCompressed() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result?.files.isEmpty ?? true) {
      Log.debug('No file selected');
      return;
    }

    isUploadLoading.value = true;

    final uploadTasks = <Future<void>>[];

    for (var i = 0; i < result!.files.length; i++) {
      final pickedFile = result.files[i];
      final originalFile = File(pickedFile.path!);

      final fileSizeInMB = originalFile.lengthSync() / (1024 * 1024);

      if (fileSizeInMB > 100) {
        Log.debug('File ${originalFile.path} exceeds 5MB, skipping.');
        largeFileUploadingErrorSnackbar();
        continue;
      }

      final fileType = _getFileType(originalFile);

      selectedFiles.add(
        PlatformFileUpload(
          file: PlatformFile(
            name: originalFile.path.split('/').last,
            path: originalFile.path,
            size: originalFile.lengthSync(),
            bytes: originalFile.readAsBytesSync(),
          ),
          type: fileType,
          fileSize: originalFile.lengthSync(),
        ),
      );

      final uploadTask = _uploadLargeFiles(i, pickedFile);

      uploadTasks.add(uploadTask);
    }

    await Future.wait(uploadTasks);

    Log.debug("Files picked and uploaded: ${mediaPathList.length}");

    isUploadLoading.value = false;
  }

  Future<void> _uploadSmallFiles(int position, File file) async {
    try {
      String? mimeType = lookupMimeType(file.path);
      List<String>? mimeTypeSplit = mimeType?.split('/');
      if (mimeTypeSplit == null || mimeTypeSplit.length != 2) {
        Utils.showSnackBar(
            message: MyStrings.unsupportedFileType.tr, isTrue: false);
      } else {
        final response = await socialPostRepository.commonUpload(
          file: file,
          mimeTypeSplit: mimeTypeSplit,
        );

        if (response?.status != true || response?.fileUrl == null) {
          Utils.showSnackBar(
              message: MyStrings.uploadFailedWithStatus.tr, isTrue: false);
          throw Exception('Failed to complete upload');
        } else {
          Log.debug("${response!.fileUrl}File upload successfully");

          mediaPathList.add(
            SocialMedia(
              url: response.fileUrl,
              type: _getFileType(file),
            ),
          );
        }
      }
    } catch (e) {
      Log.error('Unexpected error: $e');
    }
  }

  Future<void> _uploadLargeFiles(
    int i,
    PlatformFile singleFile,
  ) async {
    final fileBytes =
        singleFile.bytes ?? await File(singleFile.path!).readAsBytes();
    final fileName = singleFile.name;
    final fileMimeType = getMimeType(singleFile.extension.toString());
    final fileType =
        fileMimeType?.startsWith('image') == true ? 'image' : 'video';

    try {
      final response = await _startUpload(fileName, fileType);
      if (response == null) return;

      final uploadId = response.uploadId;
      await _chunksUpload(
        i,
        fileBytes,
        response.fileName,
        uploadId,
        fileMimeType!,
      );

      await _completeUpload(uploadId, response.fileName, fileType);
    } catch (error) {
      Log.error('Error uploading file $fileName: $error');
    }
  }

  Future<StartUploadModel?> _startUpload(
    String fileName,
    String fileType,
  ) async {
    try {
      final response = await socialPostRepository.startUpload(
        fileName: fileName,
        fileType: fileType,
      );

      if (response?.status != true) {
        throw Exception('Failed to start upload');
      }

      Log.debug('Started Upload Session');

      return response;
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
      return null;
    }
  }

  Future<void> _chunksUpload(
    int i,
    Uint8List fileBytes,
    String fileName,
    String uploadId,
    String fileMimeType,
  ) async {
    final int fileSize = fileBytes.length;
    final int totalChunks = (fileSize / fileChunkSize).ceil();

    Log.debug(
        'Total Chunks: $totalChunks, File Size: ${fileBytes.length} bytes');

    try {
      List<Future<void>> uploadTasks = [];

      for (int partNumber = 1; partNumber <= totalChunks; partNumber++) {
        final int start = (partNumber - 1) * fileChunkSize;
        final int end = (start + fileChunkSize > fileBytes.length)
            ? fileBytes.length
            : start + fileChunkSize;
        final chunk = fileBytes.sublist(start, end);

        uploadTasks.add(
          _uploadChunk(
            i,
            chunk,
            fileName,
            uploadId,
            fileMimeType,
            partNumber,
            totalChunks,
          ),
        );
      }

      await Future.wait(uploadTasks);

      Log.debug('All chunks uploaded successfully for file: $fileName');
    } catch (error) {
      Log.error('Error uploading chunks concurrently: $error');
    }
  }

  Future<void> _uploadChunk(
    int i,
    Uint8List chunk,
    String fileName,
    String uploadId,
    String fileMimeType,
    int partNumber,
    int totalChunks,
  ) async {
    try {
      final response = await socialPostRepository.chunkUpload(
        uploadId: uploadId,
        fileName: fileName,
        partNumber: partNumber.toString(),
        fileMimeType: fileMimeType,
        chunk: chunk,
      );

      if (response.statusCode != 201) {
        Log.error('Error uploading code: ${response.statusCode}');
        throw Exception('Failed to upload chunk $partNumber');
      }

      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);

      double progress = 100 / totalChunks;
      updateUploadProgress(i, progress, '');

      Log.debug('Uploaded part $partNumber of $totalChunks: $result');
    } catch (error) {
      Log.error('Error uploading chunk $partNumber: $error');
      rethrow;
    }
  }

  Future<void> _completeUpload(
    String uploadId,
    String fileName,
    String fileType,
  ) async {
    try {
      final response = await socialPostRepository.completeUpload(
        uploadId: uploadId,
        fileName: fileName,
        fileType: fileType,
      );

      if (response?.status != true) {
        throw Exception('Failed to complete upload');
      }

      Log.debug('Complete Upload Response: ${response!.fileUrl}');

      final uploadedFileUrl =
          'https://d1ew68mie4ej5v.cloudfront.net/public/users/profile/${response.fileUrl}';

      mediaPathList.add(
        SocialMedia(
          url: response.fileUrl,
          type: fileType,
        ),
      );
      Log.debug('Uploaded file URL: $uploadedFileUrl');
    } catch (error) {
      Log.error('Error completing upload: $error');
    }
  }

  void updateUploadProgress(int index, double progress, String url) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles[index].uploadPercentage += progress;
      if (url.isNotEmpty) {
        selectedFiles[index].uploadedUrl = url;
      }
      selectedFiles.refresh();
    }
  }

  String? getMimeType(String extension) {
    final mimeMap = {
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'mp4': 'video/mp4',
      'pdf': 'application/pdf',
    };
    return mimeMap[extension];
  }

  String _getFileType(File file) {
    String ext = path.extension(file.path).toLowerCase();
    if ([
      '.mp4',
      '.mov',
      '.mkv',
      '.avi',
      '.flv',
      '.wmv',
      '.webm',
      '.mpeg',
      '.mpg',
      '.3gp',
      '.m4v',
    ].contains(ext)) {
      return "video";
    } else {
      return "image";
    }
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

  void emptyContentErrorSnackbar() {
    Utils.showSnackBar(
      message: "Please add some content or media before creating a post.",
      isTrue: false,
    );
  }

  void mediaLoadingErrorSnackbar() {
    Utils.showSnackBar(
      message: "Media files are loading, please wait.",
      isTrue: false,
    );
  }

  void largeFileUploadingErrorSnackbar() {
    Utils.showSnackBar(
      message: "Cannot upload files larger than 100 MB.",
      isTrue: false,
    );
  }
}
