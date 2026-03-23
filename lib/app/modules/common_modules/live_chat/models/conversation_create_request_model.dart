import 'dart:convert';

class ConversationCreateRequestModel {
  final String? senderId;
  final String? receiverId;
  final String? bookedId;
  final bool? isAdmin;

  ConversationCreateRequestModel({
    this.senderId,
    this.receiverId,
    this.bookedId,
    this.isAdmin,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => isAdmin == null
      ? {
          "senderId": senderId,
          "receiverId": receiverId,
          if ((bookedId ?? "").isNotEmpty) "bookedId": bookedId
        }
      : {"senderId": senderId, "isAdmin": isAdmin};

  Map<String, dynamic> toAnotherJson() =>  {
          "senderId": senderId, "isAdmin": isAdmin, if (isAdmin==false) "receiverId": receiverId
        };
}
