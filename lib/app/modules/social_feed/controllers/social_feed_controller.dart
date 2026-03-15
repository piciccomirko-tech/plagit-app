import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import '../models/social_feed_model.dart';

class SocialFeedController extends GetxController with GetSingleTickerProviderStateMixin {
  BuildContext? context;

  final RxList<SocialPost> posts = <SocialPost>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final GetConnect _connect = GetConnect();
  final String _baseUrl = 'http://52.86.43.146:3002/api/v1/social-feed/';

  @override
  void onInit() {
    super.onInit();
    _connect.timeout = const Duration(seconds: 15);
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final token = StorageHelper.getToken;
      final response = await _connect.get(
        _baseUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == null) {
        hasError.value = true;
        errorMessage.value = 'Network error. Please try again.';
        isLoading.value = false;
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        if (body is Map<String, dynamic>) {
          final feedResponse = SocialFeedResponse.fromJson(body);
          posts.value = feedResponse.posts ?? [];
        } else if (body is List) {
          posts.value = body.map((x) => SocialPost.fromJson(x)).toList();
        }
      } else {
        hasError.value = true;
        errorMessage.value = response.body?['message'] ?? 'Failed to load feed';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Connection error. Please try again.';
    }

    isLoading.value = false;
  }

  String timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
