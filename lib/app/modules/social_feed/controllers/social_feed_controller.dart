import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mh/app/common/controller/app_controller.dart';
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

  String get _currentUserId => Get.find<AppController>().user.value.userId;

  @override
  void onInit() {
    super.onInit();
    _connect.httpClient.baseUrl = _baseUrl;
    _connect.httpClient.timeout = const Duration(seconds: 15);

    // Use the same request modifier pattern as ApiHelperImpl
    _connect.httpClient.addRequestModifier<dynamic>((Request request) {
      if (StorageHelper.hasToken) {
        request.headers['Authorization'] = 'Bearer ${StorageHelper.getToken}';
      }
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    fetchPosts();
  }

  Future<void> fetchPosts() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final response = await _connect.get(_baseUrl);

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

  bool isLikedByMe(SocialPost post) {
    if (post.likes == null) return false;
    return post.likes!.any((like) =>
      (like is String && like == _currentUserId) ||
      (like is Map && like['_id'] == _currentUserId) ||
      (like is Map && like['user'] == _currentUserId)
    );
  }

  Future<void> likeUnlike(String postId) async {
    try {
      await _connect.post(
        '${_baseUrl}like-unlike',
        json.encode({'postId': postId}),
        contentType: 'application/json',
      );
      await fetchPosts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to like/unlike post');
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      await _connect.post(
        '${_baseUrl}create-comment',
        json.encode({'postId': postId, 'content': content}),
        contentType: 'application/json',
      );
      await fetchPosts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final response = await _connect.delete(
        '$_baseUrl$postId',
        contentType: 'application/json',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        posts.removeWhere((p) => p.id == postId);
      } else {
        Get.snackbar('Error', 'Failed to delete post');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete post');
    }
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
