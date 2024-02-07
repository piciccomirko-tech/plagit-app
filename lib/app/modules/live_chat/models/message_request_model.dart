class MessageRequestModel {
  String conversationId;
  int limit;
  int page;

  MessageRequestModel({required this.conversationId, required this.limit, required this.page});
}
