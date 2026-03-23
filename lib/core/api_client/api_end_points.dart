class EndPoints {
  static const String commonUpload = 'commons/upload-file';
  static const String socialFeed = 'social-feed';
  static const String startUpload = '$socialFeed/start-upload';
  static const String chunkUpload = '$socialFeed/chunk-upload';
  static const String completeUpload = '$socialFeed/complete-upload';
  static const String socialFeedPostLikeUnlike = '$socialFeed/like-unlike';
  static const String socialFeedPostComment = '$socialFeed/create-comment';
  static const String socialFeedPostReport = '$socialFeed/report';
  static const String socialFeedRePost = '$socialFeed/repost';
  static const String socialFeedPostActiveInActive = '$socialFeed/update';
  static const String socialFeedPostCommentCreate =
      '$socialFeed/create-comment';
  static const String socialFeedPostCommentDelete =
      '$socialFeed/delete-comment';
  static const String socialFeedPostCommentUpdate =
      '$socialFeed/update-comment';
  static const String userBlockUnblock = 'users/block-unblock';
  static const String userFollowUnfollow = '$socialFeed/follow-unfollow';

  static const String savePost = 'social-feed-save';

  static const String payment = 'book-history/payments';
  static const String checkInCheckOutUpdateHistory = 'check-in-check-out-histories/update-history/';
}
