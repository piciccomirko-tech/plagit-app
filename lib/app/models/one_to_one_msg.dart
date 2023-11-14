import 'dart:convert';

class OneToOneMsg {
  OneToOneMsg({
    this.status,
    this.statusCode,
    this.message,
    this.count,
    this.next,
    this.messages,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final int? count;
  final dynamic next;
  final List<Message>? messages;

  factory OneToOneMsg.fromRawJson(String str) => OneToOneMsg.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OneToOneMsg.fromJson(Map<String, dynamic> json) => OneToOneMsg(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    count: json["count"],
    next: json["next"],
    messages: json["messages"] == null ? [] : List<Message>.from(json["messages"]!.map((x) => Message.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "count": count,
    "next": next,
    "messages": messages == null ? [] : List<dynamic>.from(messages!.map((x) => x.toJson())),
  };
}

class Message {
  Message({
    this.id,
    this.receiverId,
    this.senderId,
    this.senderDetails,
    this.receiverDetails,
    this.text,
    this.active,
    this.createdBy,
    this.dateTime,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  final String? id;
  final String? receiverId;
  final String? senderId;
  final SenderDetails? senderDetails;
  final ReceiverDetails? receiverDetails;
  final String? text;
  final bool? active;
  final String? createdBy;
  final DateTime? dateTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["_id"],
    receiverId: json["receiverId"],
    senderId: json["senderId"],
    senderDetails: json["senderDetails"] == null ? null : SenderDetails.fromJson(json["senderDetails"]),
    receiverDetails: json["receiverDetails"] == null ? null : ReceiverDetails.fromJson(json["receiverDetails"]),
    text: json["text"],
    active: json["active"],
    createdBy: json["createdBy"],
    dateTime: json["dateTime"] == null ? null : DateTime.parse(json["dateTime"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "receiverId": receiverId,
    "senderId": senderId,
    "senderDetails": senderDetails?.toJson(),
    "receiverDetails": receiverDetails?.toJson(),
    "text": text,
    "active": active,
    "createdBy": createdBy,
    "dateTime": dateTime?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ReceiverDetails {
  ReceiverDetails({
    this.receiverId,
    this.name,
    this.id,
  });

  final String? receiverId;
  final String? name;
  final String? id;

  factory ReceiverDetails.fromRawJson(String str) => ReceiverDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReceiverDetails.fromJson(Map<String, dynamic> json) => ReceiverDetails(
    receiverId: json["receiverId"],
    name: json["name"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "receiverId": receiverId,
    "name": name,
    "_id": id,
  };
}

class SenderDetails {
  SenderDetails({
    this.senderId,
    this.id,
  });

  final String? senderId;
  final String? id;

  factory SenderDetails.fromRawJson(String str) => SenderDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SenderDetails.fromJson(Map<String, dynamic> json) => SenderDetails(
    senderId: json["senderId"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "senderId": senderId,
    "_id": id,
  };
}
