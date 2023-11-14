import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SendPush {
  static Future<void> sendMsgNotification({
    required List<String> deviceTokens,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    final Dio dio = Dio();
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] =
        "key=AAAAwaSQwc4:APA91bH5pzh_j3LHx3O2oKcn557nkJ6juoizHpe-ltzai3t1I2ChyzYSXLK3g_LZBNP1MiYHS_Wll3x0ED1Tj9zCAaA8G5jeY_qHsq_Zx7RiO-cdS2Mu6H-az-WbrGwBfsCdO8NRohNg";

    for (String token in deviceTokens) {
      final Response response = await dio.post(
        'https://fcm.googleapis.com/fcm/send',
        data: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
            'priority': 'high',
            'data': payload,
            'to': token,
          },
        ),
      );

      if (kDebugMode) {
        print("${response.statusCode} : $token");
      }
    }
  }
}
