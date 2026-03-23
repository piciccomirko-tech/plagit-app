import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../modules/admin/admin_home/controllers/admin_home_controller.dart';
import '../modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import '../modules/common_modules/create_post/models/post_upload_model.dart';
import '../modules/employee/employee_home/controllers/employee_home_controller.dart';

class MediaData {
  final String url;
  final String type;
  // final String thumbnail;

  MediaData({
    required this.url,
    required this.type,
    // required this.thumbnail,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'type': type,
        // 'thumbnailUrl': thumbnail,
      };
}

class ChunkedUploadRepo {
  static const String apiBaseUrl =
      'https://server.plagit.com/api/v1/social-feed';
  static const int chunkSize = 5 * 1024 * 1024; // 5 MB chunks
  final List<MediaData> uploadedMedia = [];

  Future<void> createPost(String content, String token) async {
    try {
      final payload = {
        'content': content,
        'media': uploadedMedia.map((media) => media.toJson()).toList(),
      };

      if (kDebugMode) {
        print('Creating post with payload: $payload');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('Create Post Response Status: ${response.statusCode}');
        print('Create Post Response Body: ${response.body}');
      }

      if (response.statusCode != 201) {
        throw 'Failed to create post: ${response.statusCode}';
      } else {
        if (Get.isRegistered<ClientHomePremiumController>()) {
          Get.find<ClientHomePremiumController>().socialPostDataLoaded.value =
              false;
          Get.find<ClientHomePremiumController>().getSocialFeeds();
          if (kDebugMode) {
            print('ChunkedUploadRepo.createPost call home');
          }
        } else if (Get.isRegistered<EmployeeHomeController>()) {
          Get.find<EmployeeHomeController>().socialPostDataLoaded.value = false;
          Get.find<EmployeeHomeController>().getSocialFeeds();
        } else if (Get.isRegistered<AdminHomeController>()) {
          Get.find<AdminHomeController>().socialPostDataLoaded.value = false;
          Get.find<AdminHomeController>().getSocialFeeds();
        }
      }

      final result = jsonDecode(response.body);
      if (kDebugMode) {
        print('Post created successfully: $result');
      }

      uploadedMedia.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating post: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePost(String content, String token, String postId) async {
    try {
      final payload = {
        'content': content,
        'media': uploadedMedia.map((media) => media.toJson()).toList(),
      };

      if (kDebugMode) {
        print('Creating post with payload: $payload');
      }

      final response = await http.put(
        Uri.parse('$apiBaseUrl/update/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('Create Post Response Status: ${response.statusCode}');
        print('Create Post Response Body: ${response.body}');
        print('Create Post Response request: ${response.request}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw 'Failed to create post: ${response.statusCode}';
      }

      final result = jsonDecode(response.body);
      if (kDebugMode) {
        print('Post created successfully: $result');
      }

      uploadedMedia.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating post: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadMultipleFiles(
    List<MediaFileInfo> mediaFiles, {
    required Function(double) onProgress,
    String content = '',
    required String token,
    String? postId,
  }) async {
    final files = mediaFiles.map((mediaInfo) => File(mediaInfo.url)).toList();
    final totalSize = await _calculateTotalSize(files);
    final Set<int> completedFileIndices = {};
    bool hasShownCompletion = false;
    bool postCreated = false;

    try {
      if (kDebugMode) {
        print('ChunkedUploadService.uploadMultipleFiles');
      }
      await Future.wait(
        files.asMap().entries.map((entry) async {
          final index = entry.key;
          final file = entry.value;
          final mediaInfo = mediaFiles[index];
          await uploadSingleFile(
            file,
            onProgress: (fileProgress) async {
              if (hasShownCompletion) return;

              final fileSize = await file.length();
              final fileContribution = (fileSize / totalSize) * fileProgress;

              final completedFilesProgress =
                  (completedFileIndices.length * 100.0) / files.length;
              final currentFileProgress = fileContribution / files.length;
              final totalProgress = min(
                  100,
                  (completedFilesProgress + currentFileProgress)
                      .roundToDouble());

              if (kDebugMode) {
                print(
                  'File ${index + 1}/${files.length} Progress: ${fileProgress.round()}%');
              }
              if (kDebugMode) {
                print('Total Progress: ${totalProgress.round()}%');
              }

              if (fileProgress >= 100 &&
                  !completedFileIndices.contains(index)) {
                completedFileIndices.add(index);
                if (kDebugMode) {
                  print(
                    'Completed files: ${completedFileIndices.length}/${files.length}');
                }

                if (completedFileIndices.length == files.length &&
                    !hasShownCompletion) {
                  hasShownCompletion = true;
                  if (kDebugMode) {
                    print('All files uploaded successfully');
                  }
                  onProgress(100);
                } else if (!hasShownCompletion) {
                  onProgress(totalProgress.toDouble());
                }
              } else if (!hasShownCompletion) {
                onProgress(totalProgress.toDouble());
              }
            },
            width: mediaInfo.width,
            height: mediaInfo.height,
          );
        }),
      );

      if (completedFileIndices.length == files.length && !postCreated) {
        postCreated = true;
        if (postId != null) {
          await updatePost(content, token, postId);
        } else {
          await createPost(content, token);
        }

        if (!hasShownCompletion) {
          hasShownCompletion = true;
          if (kDebugMode) {
            print('Upload completed successfully');
          }
          onProgress(100);
        }
      } else if (!hasShownCompletion) {
        if (kDebugMode) {
          print(
            'Not all files completed. Completed: ${completedFileIndices.length}/${files.length}');
        }
        throw 'Not all files were uploaded successfully';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in multiple files upload: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadSingleFile(
    File file, {
    required Function(double) onProgress,
    String content = '',
    required double width,
    required double height,
  }) async {
    debugPrint('ChunkedUploadService.uploadSingleFile');
    try {
      final String fileName = file.path.split('/').last;
      final String fileType = _getFileType(file);

      if (kDebugMode) {
        print('Starting upload for file: $fileName (type: $fileType)');
      }

      final uploadData = await _startUpload(fileName, fileType, width, height);
      if (kDebugMode) {
        print('Upload data received: $uploadData');
      }

      if (uploadData == null || uploadData['uploadId'] == null) {
        if (kDebugMode) {
          print('Invalid upload data received: $uploadData');
        }
        throw 'Failed to get valid upload data from server';
      }

      final String uploadId = uploadData['uploadId'];
      final String serverFileName = uploadData['fileName'];

      if (kDebugMode) {
        print('Received uploadId: $uploadId');
        print('Server fileName: $serverFileName');
        print('Starting chunk upload with uploadId: $uploadId');
      }
      final fileLength = await file.length();
      final totalChunks = (fileLength / chunkSize).ceil();
      var completedChunks = 0;

      final List<Future> chunkFutures = [];

      for (var partNumber = 1; partNumber <= totalChunks; partNumber++) {
        final start = (partNumber - 1) * chunkSize;
        final end = min(fileLength, start + chunkSize);

        final chunk = await file.openRead(start, end).toList();
        final chunkData = List<int>.from(chunk.expand((x) => x));

        chunkFutures.add(_uploadChunkWithRetry(
          chunkData,
          serverFileName,
          uploadId,
          partNumber,
          totalChunks,
          file,
        ).then((_) {
          completedChunks++;
          final progress =
              min(100, ((completedChunks / totalChunks) * 100).roundToDouble());
          if (kDebugMode) {
            print(
              'Chunk $completedChunks/$totalChunks complete - Progress: ${progress.round()}%');
          }
          onProgress(progress.toDouble());
        }));
      }

      await Future.wait(chunkFutures);

      if (kDebugMode) {
        print('Completing upload for uploadId: $uploadId');
      }
      await _completeUpload(
        uploadId,
        serverFileName,
        fileType,
      );

      onProgress(100);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _startUpload(
    String fileName,
    String fileType,
    double? width,
    double? height,
  ) async {
    try {
      final cleanFileName = fileName;
      final payload = {
        'fileName': cleanFileName,
        'type': fileType,
        "width": width,
        "height": height,
      };
      if (kDebugMode) {
        print('Start Upload Request Payload: $payload');
        print('Start Upload URL: $apiBaseUrl/start-upload');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/start-upload'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('Start Upload Response Status: ${response.statusCode}');
        print('Start Upload Response Headers: ${response.headers}');
        print('Start Upload Response Body: ${response.body}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw 'Failed to start upload: ${response.statusCode}';
      }

      final result = jsonDecode(response.body);
      if (kDebugMode) {
        print('Start Upload Parsed Result: $result');
      }

      if (result['result'] == null || result['result']['uploadId'] == null) {
        throw 'Invalid response format: missing uploadId';
      }

      return result['result'];
    } catch (e) {
      if (kDebugMode) {
        print('Error starting upload: $e');
      }
      rethrow;
    }
  }

  Future<void> _uploadChunk(
    List<int> chunkData,
    String fileName,
    String uploadId,
    int partNumber,
    int totalChunks,
    File file,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/chunk-upload'),
      );

      final cleanFileName = fileName;

      request.files.add(
        http.MultipartFile.fromBytes(
          'chunk',
          chunkData,
          filename: cleanFileName,
        ),
      );

      final fields = {
        'uploadId': uploadId,
        'fileName': cleanFileName,
        'partNumber': partNumber.toString(),
        'mimeType': _getMimeType(file),
      };

      if (kDebugMode) {
        print('Chunk Upload Request for part $partNumber:');
        print('URL: ${request.url}');
        print('Fields: $fields');
        print('UploadId being used: $uploadId');
      }

      request.fields.addAll(fields);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Chunk Upload Response for part $partNumber:');
        print('Status: ${response.statusCode}');
        print('Headers: ${response.headers}');
        print('Body: ${response.body}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw 'Failed to upload chunk $partNumber: ${response.statusCode}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading chunk $partNumber: $e');
      }
      rethrow;
    }
  }

  Future<void> _uploadChunkWithRetry(
    List<int> chunkData,
    String fileName,
    String uploadId,
    int partNumber,
    int totalChunks,
    File file, {
    int maxRetries = 3,
  }) async {
    if (kDebugMode) {
      print('Starting upload attempt for chunk $partNumber');
    }
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _uploadChunk(
          chunkData,
          fileName,
          uploadId,
          partNumber,
          totalChunks,
          file,
        );
        if (kDebugMode) {
          print('Successfully uploaded chunk $partNumber on attempt ${attempts + 1}');
        }
        return;
      } catch (e) {
        attempts++;
        if (kDebugMode) {
          print('Attempt $attempts failed for chunk $partNumber: $e');
        }
        if (attempts >= maxRetries) {
          if (kDebugMode) {
            print('Max retries reached for chunk $partNumber');
          }
          rethrow;
        }
        if (kDebugMode) {
          print('Waiting before retry...');
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Future<void> _completeUpload(
    String uploadId,
    String fileName,
    String fileType,
  ) async {
    try {
      final cleanFileName = fileName;
      final payload = {
        'uploadId': uploadId,
        'fileName': cleanFileName,
        'type': fileType,
      };
      if (kDebugMode) {
        print('Complete Upload Request: $payload');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/complete-upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('Complete Upload Response Status: ${response.statusCode}');
        print('Complete Upload Response Body: ${response.body}');
      }

      if (response.statusCode != 201) {
        throw 'Failed to complete upload: ${response.statusCode}';
      }

      final result = jsonDecode(response.body);
      final fileUrl = result['fileUrl'];
      // final thumbnail = result['thumbnailUrl'];

      uploadedMedia.add(MediaData(
        url: fileUrl,
        type: fileType,
        // thumbnail: thumbnail,
      ));

      if (kDebugMode) {
        print('Upload completed successfully. File URL: $fileUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error completing upload: $e');
      }
      rethrow;
    }
  }

  Future<int> _calculateTotalSize(List<File> files) async {
    int totalSize = 0;
    for (final file in files) {
      totalSize += await file.length();
    }
    return totalSize;
  }

  String _getFileType(File file) {
    final mimeType = _getMimeType(file);
    return mimeType.startsWith('image/') ? 'image' : 'video';
  }

  String _getMimeType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
