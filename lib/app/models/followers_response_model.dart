class FollowersResponseModel {
  FollowersResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.result,});

  FollowersResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  String? status;
  num? statusCode;
  String? message;
  Result? result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    if (result != null) {
      map['result'] = result?.toJson();
    }
    return map;
  }

}

class Result {
  Result({
      this.following, 
      this.followers,});

  Result.fromJson(dynamic json) {
    if (json['following'] != null) {
      following = [];
      json['following'].forEach((v) {
        following?.add(Following.fromJson(v));
      });
    }
    if (json['followers'] != null) {
      followers = [];
      json['followers'].forEach((v) {
        followers?.add(Followers.fromJson(v));
      });
    }
  }
  List<Following>? following;
  List<Followers>? followers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (following != null) {
      map['following'] = following?.map((v) => v.toJson()).toList();
    }
    if (followers != null) {
      map['followers'] = followers?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Followers {
  Followers({
      this.id, 
      this.email, 
      this.name,
      this.restaurantName,
      this.positionName,
      this.role, 
      this.profilePicture, 
      this.countryName,});

  Followers.fromJson(dynamic json) {
    id = json['_id'];
    email = json['email'];
    name = json['name'];
    restaurantName = json['restaurantName'];
    positionName = json['positionName']??'';
    role = json['role']??'';
    profilePicture = json['profilePicture'];
    countryName = json['countryName'];
  }
  String? id;
  String? email;
  String? name;
  String? restaurantName;
  String? positionName;
  String? role;
  String? profilePicture;
  String? countryName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['email'] = email;
    map['name'] = name;
    map['positionName'] = positionName;
    map['restaurantName'] = restaurantName;
    map['role'] = role;
    map['profilePicture'] = profilePicture;
    map['countryName'] = countryName;
    return map;
  }

}

class Following {
  Following({
      this.id, 
      this.email, 
      this.name,
      this.countryName,
      this.positionName,
      this.restaurantName, 
      this.role, 
      this.profilePicture,
      this.notifications,
  });

  Following.fromJson(dynamic json) {
    id = json['_id'];
    email = json['email'];
    name = json['name'];
    countryName = json['countryName'];
    positionName = json['positionName']??'';
    restaurantName = json['restaurantName'];
    role = json['role']??'';
    profilePicture = json['profilePicture'];
    notifications = json['notifications'];
  }
  String? id;
  String? email;
  String? name;
  String? countryName;
  String? positionName;
  String? restaurantName;
  String? role;
  String? profilePicture;
  bool? notifications;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['email'] = email;
    map['name'] = name;
    map['countryName'] = countryName;
    map['positionName'] = positionName;
    map['restaurantName'] = restaurantName;
    map['role'] = role;
    map['profilePicture'] = profilePicture;
    map['notifications'] = notifications;
    return map;
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Following &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

}