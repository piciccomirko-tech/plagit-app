import '../../../../models/social_feed_response_model.dart';

class PostLikeUnlikeResponseModel {
  PostLikeUnlikeResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.comment,});

  PostLikeUnlikeResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    comment = json['comment'] != null ? Comment.fromJson(json['comment']) : null;
  }
  String? status;
  num? statusCode;
  String? message;
  Comment? comment;

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   map['status'] = status;
  //   map['statusCode'] = statusCode;
  //   map['message'] = message;
  //   if (comment != null) {
  //     map['comment'] = comment?.toJson();
  //   }
  //   return map;
  // }

}

class Likes {
  Likes({
      this.id, 
      this.email, 
      this.countryName, 
      this.restaurantName, 
      this.role, 
      this.profilePicture,});

  Likes.fromJson(dynamic json) {
    id = json['_id'];
    email = json['email'];
    countryName = json['countryName'];
    restaurantName = json['restaurantName'];
    role = json['role'];
    profilePicture = json['profilePicture'];
  }
  String? id;
  String? email;
  String? countryName;
  String? restaurantName;
  String? role;
  String? profilePicture;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['email'] = email;
    map['countryName'] = countryName;
    map['restaurantName'] = restaurantName;
    map['role'] = role;
    map['profilePicture'] = profilePicture;
    return map;
  }

}