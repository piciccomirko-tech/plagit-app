import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:plagit/config/env_config.dart';
import 'package:plagit/core/network/api_error.dart';
import 'package:plagit/core/token_storage.dart';

/// Production-grade HTTP client for the Plagit backend API.
///
/// Supports:
/// - Automatic bearer token injection
/// - JSON encoding/decoding
/// - Error mapping to [ApiError]
/// - Timeout handling
/// - Debug logging
class PlagitApiClient {
  static final PlagitApiClient instance = PlagitApiClient._();
  PlagitApiClient._();

  final _client = http.Client();
  static const _timeout = Duration(seconds: 30);

  String get _baseUrl => EnvConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request returning raw JSON map.
  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? queryParams}) async {
    final uri =
        Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
    return _execute(() => _client.get(uri, headers: _syncHeaders()));
  }

  /// POST request with JSON body.
  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    return _execute(() => _client.post(uri,
        headers: _syncHeaders(),
        body: body != null ? jsonEncode(body) : null));
  }

  /// PUT request with JSON body.
  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    return _execute(() => _client.put(uri,
        headers: _syncHeaders(),
        body: body != null ? jsonEncode(body) : null));
  }

  /// DELETE request.
  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    return _execute(() => _client.delete(uri, headers: _syncHeaders()));
  }

  /// PATCH request with JSON body.
  Future<Map<String, dynamic>> patch(String path,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    return _execute(() => _client.patch(uri,
        headers: _syncHeaders(),
        body: body != null ? jsonEncode(body) : null));
  }

  // We need async headers but http package wants sync — workaround:
  Map<String, String>? _cachedHeaders;
  Map<String, String> _syncHeaders() =>
      _cachedHeaders ??
      {'Content-Type': 'application/json', 'Accept': 'application/json'};

  Future<void> refreshHeaders() async {
    _cachedHeaders = await _headers();
  }

  Future<Map<String, dynamic>> _execute(
      Future<http.Response> Function() request) async {
    await refreshHeaders();
    try {
      final response = await request().timeout(_timeout);

      if (kDebugMode) {
        debugPrint('[API] ${response.statusCode} ${response.request?.url}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {'success': true, 'data': null};
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      // Extract error message from response body if possible
      String? errorMsg;
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        errorMsg = body['message'] as String? ?? body['error'] as String?;
      } catch (_) {}

      throw ApiError.fromStatusCode(response.statusCode, errorMsg);
    } on SocketException catch (e) {
      throw ApiError.network(e);
    } on http.ClientException catch (e) {
      throw ApiError.network(e);
    } on ApiError {
      rethrow;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw ApiError.timeout();
      }
      throw ApiError(
          type: ApiErrorType.unknown,
          message: e.toString(),
          originalError: e);
    }
  }
}
