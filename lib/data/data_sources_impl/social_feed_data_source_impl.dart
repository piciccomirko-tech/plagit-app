import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/core/api_client/api_client.dart';
import 'package:mh/core/api_client/api_end_points.dart';
import '../../app/models/comment_response_model.dart';
import '../../app/models/post_save_model.dart';
import '../../app/models/repost_request_model.dart';
import '../../app/models/social_comment_request_model.dart';
import '../../app/models/social_feed_request_model.dart';
import '../../app/models/social_feed_response_model.dart';
import '../../app/models/social_post_report_request_model.dart';
import '../../app/models/user_block_unblock_response_model.dart';
import '../../app/modules/common_modules/common_social_feed/models/follow_unfollow_response_model.dart';
import '../../app/modules/common_modules/common_social_feed/models/post_like_unlike_response_model.dart';
import '../data_sources/social_feed_data_source.dart';

class SocialFeedDataSourceImpl implements SocialFeedDataSource {
  ApiClient apiClient;

  SocialFeedDataSourceImpl({required this.apiClient});

  @override
  Future<SocialFeedResponseModel> getSocialPost(
      {required SocialFeedRequestModel socialFeedRequestModel}) async {
    var socialFeedBaseUrl = EndPoints.socialFeed;
    if (socialFeedRequestModel.socialFeedType == SocialFeedType.public) {
      socialFeedBaseUrl +=
          "?active=true&limit=${socialFeedRequestModel.limit}&page=${socialFeedRequestModel.page}";
    } else {
      socialFeedBaseUrl +=
          "?user=${socialFeedRequestModel.userId}&limit=${socialFeedRequestModel.limit}&page=${socialFeedRequestModel.page}";
    }

    final response = await apiClient.get(
      socialFeedBaseUrl,
    );

    return SocialFeedResponseModel.fromJson(response);
  }

  @override
  Future<PostLikeUnlikeResponseModel> postSocialPostReact(
      {required String postId}) async {
    Map<String, dynamic> requestBody = {"postId": postId};

    final response = await apiClient.post(
      EndPoints.socialFeedPostLikeUnlike,
      data: requestBody,
    );

    return PostLikeUnlikeResponseModel.fromJson(response);
  }

  @override
  Future<CommentResponseModel> postSocialPostComment(
      {required SocialCommentRequestModel socialCommentRequestModel}) async {
    final response = await apiClient.post(
      EndPoints.socialFeedPostComment,
      data: socialCommentRequestModel.toJson(),
    );

    return CommentResponseModel.fromJson(response);
  }

  @override
  Future<CommonResponseModel> postReportAgainstSocialPost(
      {required SocialPostReportRequestModel
          socialPostReportRequestModel}) async {
    final response = await apiClient.post(
      EndPoints.socialFeedPostReport,
      data: socialPostReportRequestModel.toJson(),
    );

    return CommonResponseModel.fromJson(response);
  }

  @override
  Future<CommonResponseModel> postRepostToMySocialFeed(
      {required RepostRequestModel repostRequestModel}) async {
    final response = await apiClient.post(
      EndPoints.socialFeedRePost,
      data: repostRequestModel.toJson(),
    );

    return CommonResponseModel.fromJson(response);
  }

  @override
  Future<CommonResponseModel> deleteSocialPost({required String postId}) async {
    final response = await apiClient.delete("${EndPoints.socialFeed}/$postId");

    return CommonResponseModel.fromJson(response);
  }

  @override
  Future<CommonResponseModel> inactiveSocialPost(
      {required String postId, required bool active}) async {
    Map<String, dynamic> requestBody = {"active": active};
    final response = await apiClient.put(
        "${EndPoints.socialFeedPostActiveInActive}/$postId",
        data: requestBody);

    return CommonResponseModel.fromJson(response);
  }

  @override
  Future<CommonResponseModel> deleteComment(
      {required String postId, required String commentId}) async {
    Map<String, dynamic> requestBody = {
      "postId": postId,
      "id": commentId,
    };
    final response = await apiClient.put(EndPoints.socialFeedPostCommentDelete,
        data: requestBody);

    return CommonResponseModel.fromJson(response);
  }

  @override
  Future<CommonResponseModel> updateComment(
      {required String postId,
      required String commentId,
      required String newText}) async {
    Map<String, dynamic> requestBody = {
      "text": newText,
      "postId": postId,
      "id": commentId,
    };
    final response = await apiClient.put(EndPoints.socialFeedPostCommentUpdate,
        data: requestBody);

    return CommonResponseModel.fromJson(response);
  }

  @override
  Future<UserBlockUnblockResponseModel> blockUnblockUser(
      {required String userId, required String action}) async {
    Map<String, dynamic> requestBody = {
      "id": userId,
      "action": action //BLOCK, UNBLOCK
    };
    final response =
        await apiClient.put(EndPoints.userBlockUnblock, data: requestBody);

    return UserBlockUnblockResponseModel.fromJson(response);
  }

  @override
  Future<FollowUnfollowResponseModel> followUnfollow(
      {required String userId}) async {
    Map<String, dynamic> requestBody = {
      "followUserId": userId,
    };
    final response =
        await apiClient.post(EndPoints.userFollowUnfollow, data: requestBody);

    return FollowUnfollowResponseModel.fromJson(response);
  }

  @override
  Future<PostSaveModel> savePost({required String postId}) async {
    Map<String, dynamic> requestBody = {
      "postId": postId,
    };
    final response =
        await apiClient.post("${EndPoints.savePost}/post", data: requestBody);

    return PostSaveModel.fromJson(response);
  }

  @override
  Future<PostSaveModel> deleteSavePost({required String postId}) async {
    final response = await apiClient.delete("${EndPoints.savePost}/$postId");

    return PostSaveModel.fromJson(response);
  }
}
