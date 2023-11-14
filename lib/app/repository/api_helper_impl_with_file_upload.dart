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
}
