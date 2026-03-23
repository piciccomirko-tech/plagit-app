class UnreadMessageResponseModel {
  final String? status;
  final int? statusCode;
  final int? unreadConversationsCount;

  UnreadMessageResponseModel({
    this.status,
    this.statusCode,
    this.unreadConversationsCount,
  });

  factory UnreadMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      UnreadMessageResponseModel(
        status: json["status"],
        statusCode: json["statusCode"],
        unreadConversationsCount: json["unreadConversationsCount"],
      );
}
