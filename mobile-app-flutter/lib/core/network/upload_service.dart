import 'dart:convert';
import 'dart:typed_data';
import 'package:plagit/config/env_config.dart';
import 'package:plagit/core/network/api_client.dart';

/// Handles file uploads for photos, CVs, and logos.
/// Files are sent as base64 strings in JSON body (matching Swift pattern).
class UploadService {
  static final UploadService instance = UploadService._();
  UploadService._();

  final _api = PlagitApiClient.instance;

  /// Upload candidate profile photo. Returns photo URL.
  Future<String> uploadCandidatePhoto(Uint8List imageData) async {
    if (EnvConfig.useMockData) {
      return 'https://mock.plagit.com/photos/candidate.jpg';
    }
    final b64 = base64Encode(imageData);
    final resp = await _api.post('/candidate/photo', body: {'photo': b64});
    return resp['data']['photoUrl'] as String;
  }

  /// Upload candidate CV. Returns CV URL.
  Future<String> uploadCandidateCV(Uint8List fileData, String fileName) async {
    if (EnvConfig.useMockData) return 'https://mock.plagit.com/cv/$fileName';
    final b64 = base64Encode(fileData);
    final resp = await _api
        .post('/candidate/cv', body: {'cv': b64, 'file_name': fileName});
    return resp['data']['cvUrl'] as String;
  }

  /// Upload business logo. Returns logo URL.
  Future<String> uploadBusinessLogo(Uint8List imageData) async {
    if (EnvConfig.useMockData) {
      return 'https://mock.plagit.com/logos/business.jpg';
    }
    final b64 = base64Encode(imageData);
    final resp = await _api.post('/business/logo', body: {'logo': b64});
    return resp['data']['logoUrl'] as String;
  }
}
