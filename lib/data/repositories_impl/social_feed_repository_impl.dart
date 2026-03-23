import 'package:mh/data/data_sources/social_feed_data_source.dart';
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
import '../../app/modules/employee/employee_home/models/common_response_model.dart';
import '../../domain/repositories/social_feed_repository.dart';

class SocialFeedRepositoryImpl implements SocialFeedRepository {
  final SocialFeedDataSource socialFeedDataSource;

  SocialFeedRepositoryImpl({
    required this.socialFeedDataSource,
  });

  @override
  Future<SocialFeedResponseModel?> getSocialPost(
      {required int pageNumber}) async {
    final response = await socialFeedDataSource.getSocialPost(
        socialFeedRequestModel: SocialFeedRequestModel(
            limit: 20,
            page: pageNumber,
            socialFeedType: SocialFeedType.public));

    return response;
  }

  @override
  Future<PostLikeUnlikeResponseModel?> postSocialPostReact(
      {required String postId}) async {
    final response =
        await socialFeedDataSource.postSocialPostReact(postId: postId);

    return response;
  }

  @override
  Future<CommentResponseModel?> postSocialPostComment(
      {required SocialCommentRequestModel socialCommentRequestModel}) async {
    final response = await socialFeedDataSource.postSocialPostComment(
        socialCommentRequestModel: socialCommentRequestModel);

    return response;
  }

  @override
  Future<CommonResponseModel?> postReportAgainstSocialPost(
      {required SocialPostReportRequestModel
          socialPostReportRequestModel}) async {
    final response = await socialFeedDataSource.postReportAgainstSocialPost(
        socialPostReportRequestModel: socialPostReportRequestModel);

    return response;
  }

  @override
  Future<CommonResponseModel?> postRepostToMySocialFeed(
      {required RepostRequestModel repostRequestModel}) async {
    final response = await socialFeedDataSource.postRepostToMySocialFeed(
        repostRequestModel: repostRequestModel);

    return response;
  }

  @override
  Future<CommonResponseModel?> deleteSocialPost(
      {required String postId}) async {
    final response =
        await socialFeedDataSource.deleteSocialPost(postId: postId);

    return response;
  }

  @override
  Future<CommonResponseModel?> inactiveSocialPost(
      {required String postId, required bool active}) async {
    final response = await socialFeedDataSource.inactiveSocialPost(
        postId: postId, active: active);

    return response;
  }

  @override
  Future<CommonResponseModel?> deleteComment(
      {required String postId, required String commentId}) async {
    final response = await socialFeedDataSource.deleteComment(
        postId: postId, commentId: commentId);

    return response;
  }

  @override
  Future<CommonResponseModel?> updateComment(
      {required String postId,
      required String commentId,
      required String newText}) async {
    final response = await socialFeedDataSource.updateComment(
        postId: postId, commentId: commentId, newText: newText);

    return response;
  }

  @override
  Future<UserBlockUnblockResponseModel?> blockUnblockUser(
      {required String userId, required String action}) async {
    final response = await socialFeedDataSource.blockUnblockUser(
        userId: userId, action: action);

    return response;
  }

  @override
  Future<FollowUnfollowResponseModel?> followUnfollow(
      {required String userId}) async {
    final response = await socialFeedDataSource.followUnfollow(userId: userId);

    return response;
  }

  @override
  Future<PostSaveModel?> savePost({required String postId}) async {
    final response = await socialFeedDataSource.savePost(postId: postId);

    return response;
  }

  @override
  Future<PostSaveModel?> deleteSavePost({required String postId}) async {
    final response = await socialFeedDataSource.deleteSavePost(postId: postId);

    return response;
  }
}
