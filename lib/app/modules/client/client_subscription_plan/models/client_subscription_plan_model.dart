class ClientSubscriptionPlanModel {
  ClientSubscriptionPlanModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.result,});

  ClientSubscriptionPlanModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['result'] != null) {
      result = [];
      json['result'].forEach((v) {
        result?.add(Result.fromJson(v));
      });
    }
  }
  String? status;
  num? statusCode;
  String? message;
  List<Result>? result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    if (result != null) {
      map['result'] = result?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Result {
  Result({
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
    this.discountType,
    this.discount,
    this.discountStartDate,
    this.discountEndDate,
    this.hasDiscount,
    this.active,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.v,});

  Result.fromJson(dynamic json) {
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
    monthlyCharge = json['monthlyCharge'].toDouble();
    currency = json['currency'];
    currencySymbol = json['currencySymbol'];
    discountType = json['discountType'];
    discount = json['discount'];
    discountStartDate = json['discountStartDate'];
    discountEndDate = json['discountEndDate'];
    hasDiscount = json['hasDiscount'];
    active = json['active'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? name;
  String? role;
  List<String>? keys;
  List<Features>? features;
  int? order;
  num? maxJobPosts;
  int? planDuration;
  num? maxPaymentRetry;
  double? monthlyCharge;
  String? currency;
  String? currencySymbol;
  String? discountType;
  num? discount;
  String? discountStartDate;
  String? discountEndDate;
  bool? hasDiscount;
  bool? active;
  String? type;
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
    map['discountType'] = discountType;
    map['discount'] = discount;
    map['discountStartDate'] = discountStartDate;
    map['discountEndDate'] = discountEndDate;
    map['hasDiscount'] = hasDiscount;
    map['active'] = active;
    map['type'] = type;
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