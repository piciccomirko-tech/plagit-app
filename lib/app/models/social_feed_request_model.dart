class SocialFeedRequestModel {
  String? userId;
  int limit;
  int page;
  SocialFeedType socialFeedType;

  SocialFeedRequestModel(
      {this.userId,
      required this.limit,
      required this.page,
      required this.socialFeedType});
}

enum SocialFeedType { public, self }
