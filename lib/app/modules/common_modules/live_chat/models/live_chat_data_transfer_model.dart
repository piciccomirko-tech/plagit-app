class LiveChatDataTransferModel {
  final String? id;
  final String toName;
  final String toId;
  final String? senderId;
  final String? bookedId;
  final String? role;
  final bool? isAdmin;
  final String toProfilePicture;

  LiveChatDataTransferModel(
      {this.role, this.id,
      required this.toName,
      required this.toId,
      required this.toProfilePicture,
      this.senderId,
      this.isAdmin,
      this.bookedId});
}
