class LiveChatDataTransferModel {
  final String toName;
  final String toId;
  final String? senderId;
  final String? bookedId;
  final String toProfilePicture;

  LiveChatDataTransferModel(
      {required this.toName, required this.toId, required this.toProfilePicture, this.senderId, this.bookedId});
}
