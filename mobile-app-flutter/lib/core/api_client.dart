import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:plagit/config/app_config.dart';
import 'package:plagit/core/token_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _client = http.Client();
  final _baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final url = '$_baseUrl$path';
    debugPrint('[API] POST $url');
    final response = await _client.post(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    debugPrint('[API] POST $path -> ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body.substring(0, response.body.length.clamp(0, 300))}');
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body['error']?.toString() ?? 'Unknown error',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
