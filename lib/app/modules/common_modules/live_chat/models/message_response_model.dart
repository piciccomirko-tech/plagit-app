import 'dart:convert';

class MessageResponseModel {
  final String? status;
  final int? statusCode;
  final int? count;
  final int? next;
  final List<MessageModel>? messages;

  MessageResponseModel({
    this.status,
    this.statusCode,
    this.count,
    this.next,
    this.messages,
  });

  factory MessageResponseModel.fromRawJson(String str) => MessageResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) => MessageResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    count: json["count"],
    next: json["next"],
    messages: json["messages"] == null ? [] : List<MessageModel>.from(json["messages"]!.map((x) => MessageModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "count": count,
    "next": next,
    "messages": messages == null ? [] : List<dynamic>.from(messages!.map((x) => x.toJson())),
  };
}

class MessageModel {
  final String? id;
  final String? conversationId;
  final String? senderId;
  final SenderDetailsModel? senderDetails;
  final String? text;
  final bool? sendByPlagItSupport;
  final DateTime? dateTime;
  final bool? read;

  MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderDetails,
    this.sendByPlagItSupport,
    this.text,
    this.dateTime,
    this.read,
  });

  factory MessageModel.fromRawJson(String str) => MessageModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json["_id"],
    conversationId: json["conversationId"],
    senderId: json["senderId"],
    sendByPlagItSupport: json["sendByPlagItSupport"],
    senderDetails: json["senderDetails"] == null ? null : SenderDetailsModel.fromJson(json["senderDetails"]),
    text: json["text"],
    dateTime: json["dateTime"] == null ? null : DateTime.parse(json["dateTime"]).toLocal(),
    read: json["read"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "conversationId": conversationId,
    "senderDetails": senderDetails?.toJson(),
    "text": text,
    "sendByPlagItSupport": sendByPlagItSupport,
    "dateTime": dateTime?.toIso8601String(),
    "read": read,
  };
}

class SenderDetailsModel {
  final String? senderId;
  final String? name;
  final String? role;
  final String? id;

  SenderDetailsModel({
    this.senderId,
    this.name,
    this.role,
    this.id,
  });

  factory SenderDetailsModel.fromRawJson(String str) => SenderDetailsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SenderDetailsModel.fromJson(Map<String, dynamic> json) => SenderDetailsModel(
    senderId: json["senderId"],
    name: json["name"],
    role: json["role"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "senderId": senderId,
    "name": name,
    "role": role,
    "_id": id,
  };
}
