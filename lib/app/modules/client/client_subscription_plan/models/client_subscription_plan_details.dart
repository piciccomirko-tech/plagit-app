class ClientSubscriptionPlanDetails {
  ClientSubscriptionPlanDetails({
      this.status, 
      this.statusCode, 
      this.message, 
      this.details,});

  ClientSubscriptionPlanDetails.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    details = json['details'] != null ? Details.fromJson(json['details']) : null;
  }
  String? status;
  num? statusCode;
  String? message;
  Details? details;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    if (details != null) {
      map['details'] = details?.toJson();
    }
    return map;
  }

}

class Details {
  Details({
      this.id, 
      this.userIdNumber, 
      this.email, 
      this.phoneNumber, 
      this.bankName, 
      this.accountNumber, 
      this.routingNumber, 
      this.additionalOne, 
      this.additionalTwo, 
      this.languages, 
      this.certificates, 
      this.countryName, 
      this.sourceId, 
      this.restaurantName, 
      this.restaurantAddress, 
      this.employee, 
      this.client, 
      this.admin, 
      this.hr, 
      this.marketing, 
      this.role, 
      this.isReferPerson, 
      this.isMhEmployee, 
      this.isHired, 
      this.profileCompleted, 
      this.profilePicture, 
      this.verified, 
      this.active, 
      this.rating, 
      this.totalWorkingHour, 
      this.otherCountryName, 
      this.hourlyRate, 
      this.clientDiscount, 
      this.lat, 
      this.long, 
      this.pushNotificationDetails, 
      this.vatNumber, 
      this.companyRegisterNumber, 
      this.skills, 
      this.contractorHourlyRate, 
      this.totalRating, 
      this.documents, 
      this.certified, 
      this.hasUniform, 
      this.companyName, 
      this.vlogs, 
      this.cardStatus, 
      this.sourceOfFunds, 
      this.emergencyContactNumber, 
      this.additionalEmailAddress, 
      this.blockUsers, 
      this.subscription, 
      this.jobPostsCount, 
      this.tokenId, 
      this.menuPermission, 
      this.available,});

  Details.fromJson(dynamic json) {
    id = json['_id'];
    userIdNumber = json['userIdNumber'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    bankName = json['bankName'];
    accountNumber = json['accountNumber'];
    routingNumber = json['routingNumber'];
    additionalOne = json['additionalOne'];
    additionalTwo = json['additionalTwo'];
    // if (json['languages'] != null) {
    //   languages = [];
    //   json['languages'].forEach((v) {
    //     languages?.add(Dynamic.fromJson(v));
    //   });
    // }
    // if (json['certificates'] != null) {
    //   certificates = [];
    //   json['certificates'].forEach((v) {
    //     certificates?.add(Dynamic.fromJson(v));
    //   });
    // }
    countryName = json['countryName'];
    sourceId = json['sourceId'];
    restaurantName = json['restaurantName'];
    restaurantAddress = json['restaurantAddress'];
    employee = json['employee'];
    client = json['client'];
    admin = json['admin'];
    hr = json['hr'];
    marketing = json['marketing'];
    role = json['role'];
    isReferPerson = json['isReferPerson'];
    isMhEmployee = json['isMhEmployee'];
    isHired = json['isHired'];
    profileCompleted = json['profileCompleted'];
    profilePicture = json['profilePicture'];
    verified = json['verified'];
    active = json['active'];
    rating = json['rating'];
    totalWorkingHour = json['totalWorkingHour'];
    otherCountryName = json['otherCountryName'];
    hourlyRate = json['hourlyRate'];
    clientDiscount = json['clientDiscount'];
    lat = json['lat'];
    long = json['long'];
    pushNotificationDetails = json['pushNotificationDetails'] != null ? PushNotificationDetails.fromJson(json['pushNotificationDetails']) : null;
    vatNumber = json['vatNumber'];
    companyRegisterNumber = json['companyRegisterNumber'];
    // if (json['skills'] != null) {
    //   skills = [];
    //   json['skills'].forEach((v) {
    //     skills?.add(Dynamic.fromJson(v));
    //   });
    // }
    contractorHourlyRate = json['contractorHourlyRate'];
    totalRating = json['totalRating'];
    // if (json['documents'] != null) {
    //   documents = [];
    //   json['documents'].forEach((v) {
    //     documents?.add(Dynamic.fromJson(v));
    //   });
    // }
    certified = json['certified'];
    hasUniform = json['hasUniform'];
    companyName = json['companyName'];
    // if (json['vlogs'] != null) {
    //   vlogs = [];
    //   json['vlogs'].forEach((v) {
    //     vlogs?.add(Dynamic.fromJson(v));
    //   });
    // }
    cardStatus = json['cardStatus'];
    sourceOfFunds = json['sourceOfFunds'];
    emergencyContactNumber = json['emergencyContactNumber'];
    additionalEmailAddress = json['additionalEmailAddress'];
    if (json['blockUsers'] != null) {
      blockUsers = [];
      json['blockUsers'].forEach((v) {
        blockUsers?.add(BlockUsers.fromJson(v));
      });
    }
    subscription = json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null;
    jobPostsCount = json['jobPostsCount'];
    tokenId = json['tokenId'];
    // if (json['menuPermission'] != null) {
    //   menuPermission = [];
    //   json['menuPermission'].forEach((v) {
    //     menuPermission?.add(Dynamic.fromJson(v));
    //   });
    // }
    available = json['available'];
  }
  String? id;
  String? userIdNumber;
  String? email;
  String? phoneNumber;
  String? bankName;
  String? accountNumber;
  String? routingNumber;
  String? additionalOne;
  String? additionalTwo;
  List<dynamic>? languages;
  List<dynamic>? certificates;
  String? countryName;
  String? sourceId;
  String? restaurantName;
  String? restaurantAddress;
  bool? employee;
  bool? client;
  bool? admin;
  bool? hr;
  bool? marketing;
  String? role;
  bool? isReferPerson;
  bool? isMhEmployee;
  bool? isHired;
  num? profileCompleted;
  String? profilePicture;
  bool? verified;
  bool? active;
  num? rating;
  String? totalWorkingHour;
  bool? otherCountryName;
  num? hourlyRate;
  num? clientDiscount;
  String? lat;
  String? long;
  PushNotificationDetails? pushNotificationDetails;
  String? vatNumber;
  String? companyRegisterNumber;
  List<dynamic>? skills;
  num? contractorHourlyRate;
  num? totalRating;
  List<dynamic>? documents;
  bool? certified;
  bool? hasUniform;
  String? companyName;
  List<dynamic>? vlogs;
  String? cardStatus;
  String? sourceOfFunds;
  String? emergencyContactNumber;
  String? additionalEmailAddress;
  List<BlockUsers>? blockUsers;
  Subscription? subscription;
  num? jobPostsCount;
  String? tokenId;
  List<dynamic>? menuPermission;
  String? available;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['userIdNumber'] = userIdNumber;
    map['email'] = email;
    map['phoneNumber'] = phoneNumber;
    map['bankName'] = bankName;
    map['accountNumber'] = accountNumber;
    map['routingNumber'] = routingNumber;
    map['additionalOne'] = additionalOne;
    map['additionalTwo'] = additionalTwo;
    if (languages != null) {
      map['languages'] = languages?.map((v) => v.toJson()).toList();
    }
    if (certificates != null) {
      map['certificates'] = certificates?.map((v) => v.toJson()).toList();
    }
    map['countryName'] = countryName;
    map['sourceId'] = sourceId;
    map['restaurantName'] = restaurantName;
    map['restaurantAddress'] = restaurantAddress;
    map['employee'] = employee;
    map['client'] = client;
    map['admin'] = admin;
    map['hr'] = hr;
    map['marketing'] = marketing;
    map['role'] = role;
    map['isReferPerson'] = isReferPerson;
    map['isMhEmployee'] = isMhEmployee;
    map['isHired'] = isHired;
    map['profileCompleted'] = profileCompleted;
    map['profilePicture'] = profilePicture;
    map['verified'] = verified;
    map['active'] = active;
    map['rating'] = rating;
    map['totalWorkingHour'] = totalWorkingHour;
    map['otherCountryName'] = otherCountryName;
    map['hourlyRate'] = hourlyRate;
    map['clientDiscount'] = clientDiscount;
    map['lat'] = lat;
    map['long'] = long;
    if (pushNotificationDetails != null) {
      map['pushNotificationDetails'] = pushNotificationDetails?.toJson();
    }
    map['vatNumber'] = vatNumber;
    map['companyRegisterNumber'] = companyRegisterNumber;
    if (skills != null) {
      map['skills'] = skills?.map((v) => v.toJson()).toList();
    }
    map['contractorHourlyRate'] = contractorHourlyRate;
    map['totalRating'] = totalRating;
    if (documents != null) {
      map['documents'] = documents?.map((v) => v.toJson()).toList();
    }
    map['certified'] = certified;
    map['hasUniform'] = hasUniform;
    map['companyName'] = companyName;
    if (vlogs != null) {
      map['vlogs'] = vlogs?.map((v) => v.toJson()).toList();
    }
    map['cardStatus'] = cardStatus;
    map['sourceOfFunds'] = sourceOfFunds;
    map['emergencyContactNumber'] = emergencyContactNumber;
    map['additionalEmailAddress'] = additionalEmailAddress;
    if (blockUsers != null) {
      map['blockUsers'] = blockUsers?.map((v) => v.toJson()).toList();
    }
    if (subscription != null) {
      map['subscription'] = subscription?.toJson();
    }
    map['jobPostsCount'] = jobPostsCount;
    map['tokenId'] = tokenId;
    if (menuPermission != null) {
      map['menuPermission'] = menuPermission?.map((v) => v.toJson()).toList();
    }
    map['available'] = available;
    return map;
  }

}

class Subscription {
  Subscription({
      this.id, 
      this.plan, 
      this.sourceOfFund, 
      this.currency, 
      this.monthlyCharge, 
      this.paymentFailedCount, 
      this.startDate, 
      this.endDate, 
      this.paymentDate, 
      this.active, 
      this.user, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  Subscription.fromJson(dynamic json) {
    id = json['_id'];
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
    sourceOfFund = json['sourceOfFund'];
    currency = json['currency'];
    monthlyCharge = json['monthlyCharge'];
    paymentFailedCount = json['paymentFailedCount'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    paymentDate = json['paymentDate'];
    active = json['active'];
    user = json['user'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  Plan? plan;
  String? sourceOfFund;
  String? currency;
  num? monthlyCharge;
  num? paymentFailedCount;
  String? startDate;
  String? endDate;
  String? paymentDate;
  bool? active;
  String? user;
  String? createdAt;
  String? updatedAt;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    if (plan != null) {
      map['plan'] = plan?.toJson();
    }
    map['sourceOfFund'] = sourceOfFund;
    map['currency'] = currency;
    map['monthlyCharge'] = monthlyCharge;
    map['paymentFailedCount'] = paymentFailedCount;
    map['startDate'] = startDate;
    map['endDate'] = endDate;
    map['paymentDate'] = paymentDate;
    map['active'] = active;
    map['user'] = user;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}

class Plan {
  Plan({
      this.id, 
      this.name, 
      this.role, 
      this.keys, 
      this.features, 
      this.order, 
      this.maxJobPosts, 
      this.planDuration, 
      this.maxPaymentRetry, 
      this.monthlyCharge, 
      this.currency, 
      this.currencySymbol, 
      this.hasDiscount, 
      this.active, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  Plan.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    role = json['role'];
    keys = json['keys'] != null ? json['keys'].cast<String>() : [];
    if (json['features'] != null) {
      features = [];
      json['features'].forEach((v) {
        features?.add(Features.fromJson(v));
      });
    }
    order = json['order'];
    maxJobPosts = json['maxJobPosts'];
    planDuration = json['planDuration'];
    maxPaymentRetry = json['maxPaymentRetry'];
    monthlyCharge = json['monthlyCharge'];
    currency = json['currency'];
    currencySymbol = json['currencySymbol'];
    hasDiscount = json['hasDiscount'];
    active = json['active'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? name;
  String? role;
  List<String>? keys;
  List<Features>? features;
  num? order;
  num? maxJobPosts;
  num? planDuration;
  num? maxPaymentRetry;
  num? monthlyCharge;
  String? currency;
  String? currencySymbol;
  bool? hasDiscount;
  bool? active;
  String? createdAt;
  String? updatedAt;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['role'] = role;
    map['keys'] = keys;
    if (features != null) {
      map['features'] = features?.map((v) => v.toJson()).toList();
    }
    map['order'] = order;
    map['maxJobPosts'] = maxJobPosts;
    map['planDuration'] = planDuration;
    map['maxPaymentRetry'] = maxPaymentRetry;
    map['monthlyCharge'] = monthlyCharge;
    map['currency'] = currency;
    map['currencySymbol'] = currencySymbol;
    map['hasDiscount'] = hasDiscount;
    map['active'] = active;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}

class Features {
  Features({
      this.name, 
      this.key, 
      this.value,});

  Features.fromJson(dynamic json) {
    name = json['name'];
    key = json['key'];
    value = json['value'];
  }
  String? name;
  String? key;
  num? value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['key'] = key;
    map['value'] = value;
    return map;
  }

}

class BlockUsers {
  BlockUsers({
      this.id, 
      this.email, 
      this.countryName, 
      this.restaurantName, 
      this.role, 
      this.profilePicture,});

  BlockUsers.fromJson(dynamic json) {
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

class PushNotificationDetails {
  PushNotificationDetails({
      this.uuid, 
      this.fcmToken, 
      this.platform, 
      this.id,});

  PushNotificationDetails.fromJson(dynamic json) {
    uuid = json['uuid'];
    fcmToken = json['fcmToken'];
    platform = json['platform'];
    id = json['_id'];
  }
  String? uuid;
  String? fcmToken;
  String? platform;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['uuid'] = uuid;
    map['fcmToken'] = fcmToken;
    map['platform'] = platform;
    map['_id'] = id;
    return map;
  }

}