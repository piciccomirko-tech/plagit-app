import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mh/core/loggers/logger.dart';

abstract class ApiClient {
  String get baseUrl;

  Future<Map<String, String>> getCustomHeader();

  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    final url = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    _logRequest('GET', url, headers: await getCustomHeader());

    final response = await http.get(url, headers: await getCustomHeader());

    _logResponse(response);

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      body: jsonEncode(data),
      headers: await _buildHeaders(headers),
    );

    _logRequest('POST', Uri.parse('$baseUrl/$endpoint'),
        data: data, headers: headers);
    _logResponse(response);

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      body: jsonEncode(data),
      headers: await _buildHeaders(headers),
    );

    _logRequest('PUT', Uri.parse('$baseUrl/$endpoint'),
        data: data, headers: headers);
    _logResponse(response);

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint,
      {Map<String, String>? headers}) async {
    _logRequest('DELETE', Uri.parse('$baseUrl/$endpoint'), headers: headers);

    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _buildHeaders(headers),
    );

    _logResponse(response);

    return _processResponse(response);
  }

  Future<Map<String, String>> _buildHeaders(
      Map<String, String>? headers) async {
    return {...await getCustomHeader(), ...?headers};
  }

  void _logRequest(String method, Uri url,
      {Map<String, dynamic>? data, Map<String, String>? headers}) {
    Log.info('Sending $method request to $url');
    if (headers != null && headers.isNotEmpty) {
      var formattedHeaders = const JsonEncoder.withIndent(' ').convert(headers);
      Log.info('Request Headers: $formattedHeaders');
    }
    if (data != null && data.isNotEmpty) {
      Log.info('Request Data: $data');
    }
  }

  void _logResponse(http.Response response) {
    var jsonObj = jsonDecode(response.body);
    // The response could be minified, so we need to re-encode it to get a formatted JSON string
    var formattedJsonStr = const JsonEncoder.withIndent('  ').convert(jsonObj);
    Log.info(
        'Received response - Status code: ${response.statusCode}, Body: $formattedJsonStr');
    if (response.headers.isNotEmpty) {
      var formattedHeaders =
          const JsonEncoder.withIndent(' ').convert(response.headers);
      Log.info('Response Headers: $formattedHeaders');
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    // if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    // } else {
    //   throw NetworkException(
    //     data['error'] ?? data['message'] ?? 'Unknown error',
    //     code: response.statusCode,
    //   );
    // }
  }
}
