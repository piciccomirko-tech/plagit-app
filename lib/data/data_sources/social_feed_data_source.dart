import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import '../../app/models/comment_response_model.dart';
import '../../app/models/post_save_model.dart';
import '../../app/models/repost_request_model.dart';
import '../../app/models/social_comment_request_model.dart';
import '../../app/models/social_feed_request_model.dart';
import '../../app/models/user_block_unblock_response_model.dart';
import '../../app/modules/common_modules/common_social_feed/models/follow_unfollow_response_model.dart';
import '../../app/modules/common_modules/common_social_feed/models/post_like_unlike_response_model.dart';
import '../../app/modules/employee/employee_home/models/common_response_model.dart';

abstract class SocialFeedDataSource {
  Future<SocialFeedResponseModel> getSocialPost(
      {required SocialFeedRequestModel socialFeedRequestModel});
  Future<PostLikeUnlikeResponseModel> postSocialPostReact(
      {required String postId});
  Future<CommentResponseModel> postSocialPostComment(
      {required SocialCommentRequestModel socialCommentRequestModel});
  Future<CommonResponseModel> postReportAgainstSocialPost(
      {required SocialPostReportRequestModel socialPostReportRequestModel});
  Future<CommonResponseModel> postRepostToMySocialFeed({required RepostRequestModel repostRequestModel});
  Future<CommonResponseModel> deleteSocialPost({required String postId});
  Future<CommonResponseModel> inactiveSocialPost({required String postId, required bool active});
  Future<CommonResponseModel> deleteComment({required String postId, required String commentId});
  Future<CommonResponseModel> updateComment({required String postId, required String commentId, required String newText});
  Future<UserBlockUnblockResponseModel> blockUnblockUser({required String userId, required String action});
  Future<FollowUnfollowResponseModel> followUnfollow({required String userId});
  Future<PostSaveModel> savePost({required String postId});
  Future<PostSaveModel> deleteSavePost({required String postId});
}
