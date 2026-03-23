import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mh/app/repository/server_urls.dart';
import '../common/controller/app_error_controller.dart';
import 'package:http/http.dart' as http;

class ApiHelperImplementWithFileUpload {
  static Future<Response?> updateProfilePicture(Map<String, dynamic> data) async {
  String url = "${ServerUrls.serverLiveUrlUser}users/update-profile-image"; // API endpoint
  SendPort percentSendPort = data["percentReceivePort"];
  SendPort responseSendPort = data["responseReceivePort"];

  // Send initial progress as 0
  percentSendPort.send(0);

  // Prepare FormData with the profile picture file
  FormData formData = FormData.fromMap({});

  if ((data["profilePicture"] ?? "").isNotEmpty) {
    formData.files.add(MapEntry(
      "file", // The key should match the Postman form-data key for file upload
      await MultipartFile.fromFile(
        data["profilePicture"], // File path
        filename: data["profilePicture"].split("/").last, // Extracting file name from path
        contentType: MediaType("image", "jpeg"), // Assuming JPEG, you can modify if the file format is different
      ),
    ));
  }

  Response? response;

  try {
    Options options = Options(
      headers: {
        'Content-Type': 'multipart/form-data',
        'Vary': 'Accept',
        if (data['token'] != null && data['token'].isNotEmpty)
          'Authorization': 'Bearer ${data["token"]}' // Add token if available
      },
      sendTimeout: const Duration(minutes: 5), // Timeout 5 minutes
      followRedirects: false,
    );

    // Send PUT request
    response = await Dio().put(
      url,
      data: formData,
      options: options,
      onSendProgress: (int count, int total) {
        percentSendPort.send(((100 / total) * count).toInt());
      },
    );

    // Log success for debugging
    if (kDebugMode) {
      print('Response: ${response.data}');
    }

    responseSendPort.send({"data": response?.data});
  } on DioException catch (e, s) {
    if (kDebugMode) {
      print(e.response);
      print(e);
      print(s);
    }

    // Log the error using your AppErrorController
    AppErrorController.submitAutomaticError(
      errorName: "From: api_helper_imp_with_file_upload.dart > on DioError catch",
      description: (e.response?.data ?? "").toString(),
    );

    return e.response; // Return the error response
  }

  return response;
}

  static void employeeRegister(Map<String, dynamic> data) async {
    SendPort responseSendPort = data["responseReceivePort"];

    Response? result = await _uploadData(
      "${ServerUrls.serverLiveUrlUser}users/employee-register",
      data,
      postMethod: true,
    );

    responseSendPort.send({"data": result?.data});
  }

  /// [List] has two data => [Response, isSuccess]
  static Future<Response?> _uploadData(String url, Map<String, dynamic> data, {bool postMethod = false}) async {
    String token = data["token"];
    SendPort percentSendPort = data["percentReceivePort"];
    percentSendPort.send(0);

    FormData formData = FormData.fromMap(data["basicData"]);

    if (url.split("/").last == "employee-register") {
      if ((data["profilePicture"] ?? "").isNotEmpty) {
        formData.files.add(MapEntry(
            "profilePicture",
            await MultipartFile.fromFile(
              data["profilePicture"],
              filename: data["profilePicture"].split("/").last,
              contentType: MediaType("image", "jpeg"),
            )));
      }

      if ((data["cv"] ?? "").isNotEmpty) {
        formData.files.add(MapEntry(
            "cv",
            await MultipartFile.fromFile(
              data["cv"],
              filename: data["cv"].split("/").last,
              contentType: MediaType("application", "pdf"),
            )));
      }
    }

    Response? response;

    if (kDebugMode) {
      print('Url: $url');
      print('fields: ${formData.fields}');
      print('files: ${formData.files}');
    }

    try {
      Options options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Vary': 'Accept',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token'
        },
        sendTimeout: const Duration(minutes: 5), // 5 min
        followRedirects: false,
      );

      response = postMethod
          ? await Dio().post(
              url,
              data: formData,
              options: options,
              onSendProgress: (int count, int total) {
                percentSendPort.send(((100 / total) * count).toInt());
              },
            )
          : await Dio().put(
              url,
              data: formData,
              options: options,
              onSendProgress: (int count, int total) {
                percentSendPort.send(((100 / total) * count).toInt());
              },
            );
    } on DioException catch (e, s) {
      if (kDebugMode) {
        print(e.response);
        print(e);
        print(s);
      }

      AppErrorController.submitAutomaticError(
        errorName: "From: api_helper_imp_with_file_upload.dart > on DioError catch",
        description: (e.response?.data ?? "").toString(),
      );

      return e.response;
    }

    return response;
  }
  /// New function to update CV using PUT method
  static Future<Response?> updateCv({
    required String token,
    required File cvFile, // CV file to be uploaded
  }) async {
    String url = "${ServerUrls.serverLiveUrlUser}users/update-employee"; // API endpoint for updating CV
    
    FormData formData = FormData.fromMap({});

    // Attach the CV file to formData
    if (cvFile.path.isNotEmpty) {
      formData.files.add(MapEntry(
        "cv", // Key for the CV file as expected by the API
        await MultipartFile.fromFile(
          cvFile.path, // Path to the CV file
          filename: cvFile.path.split("/").last, // Extracting the file name from the path
          contentType: MediaType("application", "pdf"), // Assuming it's a PDF file
        ),
      ));
    }

    Response? response;

    try {
      Options options = Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $token', // Token for authentication
        },
        sendTimeout: const Duration(minutes: 5), // Timeout 5 minutes
      );

      // Send PUT request with the file and headers
      response = await Dio().put(
        url,
        data: formData,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      return e.response; // Return error response
    }
  }
  
  static Future<bool> uploadCvUpdated({
  required String token,
  required File cvFile,
  required SendPort percentSendPort, // Progress SendPort for updates
}) async {
   String url = "${ServerUrls.serverLiveUrlUser}users/update-employee"; // API endpoint for updating CV

  FormData formData = FormData();
  formData.files.add(MapEntry(
    "cv",
    await MultipartFile.fromFile(
      cvFile.path,
      filename: cvFile.path.split("/").last,
      contentType: MediaType("application", "pdf"),
    ),
  ));

  try {
    Response response = await Dio().put(
      url,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
        sendTimeout: const Duration(minutes: 5),
      ),
      onSendProgress: (int sent, int total) {
        int progress = ((sent / total) * 100).toInt();
        percentSendPort.send(progress); // Send progress to main isolate
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    if (kDebugMode) {
      print("Error uploading CV: $e");
    }
    percentSendPort.send(-1); // Indicate failure with -1
    return false;
  }
}

  static Future<String> uploadExtraFile({required File file, required String fileName}) async {
    try {
      final String url = '${ServerUrls.serverLiveUrlUser}document/upload-document';
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(await http.MultipartFile.fromPath('document', file.absolute.path,
          filename: fileName, contentType: MediaType('application', 'pdf')));
      http.StreamedResponse streamResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamResponse);
      if ([200, 201].contains(response.statusCode)) {
        return jsonDecode(response.body)['details']['document'][0];
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }


//working ends
static Future<void> updateEmployeeProfile(Map<String, dynamic> data) async {
  String updateProfileUrl = "${ServerUrls.serverLiveUrlUser}users/update-employee"; // API endpoint for updating employee
  SendPort percentSendPort = data["percentReceivePort"];
  SendPort responseSendPort = data["responseReceivePort"];

  // Send initial progress as 0
  percentSendPort.send(0);

  // Prepare FormData with profile information and files
  FormData formData = FormData.fromMap(data["basicData"]);

  try {
    // Add CV if available
    if (data["cv"] != null) {
      formData.files.add(MapEntry(
        "cv",
        await MultipartFile.fromFile(
          data["cv"],
          filename: data["cv"].split("/").last,
          contentType: MediaType("application", "pdf"),
        ),
      ));
    }

    Response? response;

    Options options = Options(
      headers: {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${data["token"]}', // Add token if needed
      },
      sendTimeout: const Duration(minutes: 5), // Timeout 5 minutes
    );

    // Use Dio to send the PUT request and track upload progress
    response = await Dio().put(
      updateProfileUrl,
      data: formData,
      options: options,
      onSendProgress: (int sent, int total) {
        int progress = ((100 / total) * sent).toInt();
        percentSendPort.send(progress);  // Send progress to the main isolate
      },
    );

    responseSendPort.send({"data": response.data});

    // Now upload certificates if available
    if (data["certificates"] != null && data["certificates"].isNotEmpty) {
      await uploadCertificates(data["certificates"], data["basicData"]["id"], data["token"], percentSendPort);
    }

  } on DioException catch (e, s) {
    responseSendPort.send({"error": e.response?.data});
  }
}

// Function to upload multiple certificates and track progress
// Function to upload multiple certificates and track progress
static Future<void> uploadCertificates(List<Map<String, dynamic>> certificates, String userId, String token, SendPort percentSendPort) async {
  String uploadCertificateUrl = "${ServerUrls.serverLiveUrlUser}users/certificate/upload"; // API endpoint for certificate upload

  int totalFiles = certificates.length;
  int uploadedFiles = 0;

  for (var certificate in certificates) {
    String certificateName = certificate['certificateName'];
    String filePath = certificate['filePath'];  // Assuming file path is stored in certificate['filePath']

    // Skip remote URLs
    if (filePath.startsWith('http')) {
      continue; // Skip this iteration if the file is a remote URL
    }

    // Prepare FormData for each certificate
    FormData formData = FormData.fromMap({
      "id": userId,
      "certificateName": certificateName, // Use the certificate name
      "attachment": await MultipartFile.fromFile(
        filePath,
        filename: certificateName,  // Use certificate name or original filename
        contentType: MediaType("application", "pdf"),  // Adjust MIME type if needed
      ),
    });

    try {
      Response response = await Dio().put(
        uploadCertificateUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Pass the token
          },
          sendTimeout: const Duration(minutes: 5), // Timeout 5 minutes
        ),
        onSendProgress: (int sent, int total) {
          // Calculate and send progress for the current certificate upload
          int progress = ((100 / total) * sent).toInt();
          percentSendPort.send(progress);  // Send progress to the main isolate
        },
      );

      uploadedFiles++;
      int overallProgress = ((uploadedFiles / totalFiles) * 100).toInt();
      percentSendPort.send(overallProgress);  // Send overall progress to the main isolate

    } on DioException catch (_) {
    }
  }
}

static Future<bool> uploadCertificatesUpdated({
  required String token,
  required String userId,
  required List<Map<String, dynamic>> certificates,
  required SendPort percentSendPort, // Progress SendPort for updates
}) async {
   String uploadCertificateUrl = "${ServerUrls.serverLiveUrlUser}users/certificate/upload";
  int totalFiles = certificates.length;
  int uploadedFiles = 0;
  bool isSuccess = true;

  for (var certificate in certificates) {
    String certificateName = certificate['certificateName'];
    String filePath = certificate['filePath'];

    if (filePath.startsWith('http')) continue; // Skip remote files

    FormData formData = FormData.fromMap({
      "id": userId,
      "certificateName": certificateName,
      "attachment": await MultipartFile.fromFile(
        filePath,
        filename: certificateName,
        contentType: MediaType("application", "pdf"),
      ),
    });

    try {
      Response response = await Dio().put(
        uploadCertificateUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (int sent, int total) {
          int fileProgress = ((sent / total) * 100).toInt();
          int overallProgress = ((uploadedFiles + fileProgress / 100) / totalFiles * 100).toInt();
          percentSendPort.send(overallProgress); // Send overall progress to main isolate
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        isSuccess = false;
      } else {
        uploadedFiles++; // Track successfully uploaded files
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading certificate $certificateName: $e");
      }
      isSuccess = false;
      percentSendPort.send(-1); // Indicate failure with -1
    }
  }

  percentSendPort.send(100); // Send 100% completion after all files uploaded
  return isSuccess;
}


}
