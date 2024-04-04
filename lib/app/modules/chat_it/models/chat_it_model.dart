import 'dart:convert';

class ChatItModel {
  final String? status;
  final int? statusCode;
  final List<Conversation>? conversations;

  ChatItModel({
    this.status,
    this.statusCode,
    this.conversations,
  });

  factory ChatItModel.fromRawJson(String str) => ChatItModel.fromJson(json.decode(str));

  factory ChatItModel.fromJson(Map<String, dynamic> json) => ChatItModel(
    status: json["status"],
    statusCode: json["statusCode"],
    conversations: json["conversations"] == null ? [] : List<Conversation>.from(json["conversations"]!.map((x) => Conversation.fromJson(x))),
  );

}

class Conversation {
  final String? id;
  final List<Member>? members;
  final bool? active;
  final bool? isAdmin;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final LatestMessage? latestMessage;

  Conversation({
    this.id,
    this.members,
    this.active,
    this.isAdmin,
    this.country,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.latestMessage,
  });

  factory Conversation.fromRawJson(String str) => Conversation.fromJson(json.decode(str));

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json["_id"],
    members: json["members"] == null ? [] : List<Member>.from(json["members"]!.map((x) => Member.fromJson(x))),
    active: json["active"],
    isAdmin: json["isAdmin"],
    country: json["country"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    latestMessage: json["latestMessage"] == null ? null : LatestMessage.fromJson(json["latestMessage"]),
  );

}

class LatestMessage {
  final String? id;
  final String? senderId;
  final String? conversationId;
  final Member? senderDetails;
  final String? text;
  final DateTime? dateTime;
  final bool? read;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  LatestMessage({
    this.id,
    this.senderId,
    this.conversationId,
    this.senderDetails,
    this.text,
    this.dateTime,
    this.read,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LatestMessage.fromRawJson(String str) => LatestMessage.fromJson(json.decode(str));

  factory LatestMessage.fromJson(Map<String, dynamic> json) => LatestMessage(
    id: json["_id"],
    senderId: json["senderId"],
    conversationId: json["conversationId"],
    senderDetails: json["senderDetails"] == null ? null : Member.fromJson(json["senderDetails"]),
    text: json["text"],
    dateTime: json["dateTime"] == null ? null : DateTime.parse(json["dateTime"]),
    read: json["read"],
    createdBy: json["createdBy"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

}

class Member {
  final String? senderId;
  final String? name;
  final String? profilePicture;
  final String? role;
  final String? id;
  final String? restaurantName;

  Member({
    this.senderId,
    this.name,
    this.profilePicture,
    this.role,
    this.id,
    this.restaurantName,
  });

  factory Member.fromRawJson(String str) => Member.fromJson(json.decode(str));

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    senderId: json["senderId"],
    name: json["name"],
    profilePicture: json["profilePicture"],
    role: json["role"],
    id: json["_id"],
    restaurantName: json["restaurantName"],
  );

}
