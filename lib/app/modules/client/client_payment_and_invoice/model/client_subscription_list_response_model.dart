class ClientSubscriptionListResponseModel {
  ClientSubscriptionListResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.total, 
      this.count, 
      this.next, 
      this.subscriptions,});

  ClientSubscriptionListResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    total = json['total'];
    count = json['count'];
    next = json['next'];
    if (json['subscriptions'] != null) {
      subscriptions = [];
      json['subscriptions'].forEach((v) {
        subscriptions?.add(Subscriptions.fromJson(v));
      });
    }
  }
  String? status;
  num? statusCode;
  String? message;
  num? total;
  num? count;
  dynamic next;
  List<Subscriptions>? subscriptions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    map['total'] = total;
    map['count'] = count;
    map['next'] = next;
    if (subscriptions != null) {
      map['subscriptions'] = subscriptions?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Subscriptions {
  Subscriptions({
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

  Subscriptions.fromJson(dynamic json) {
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
    discount = json['discount']??0;
    currencySymbol = json['currencySymbol'];
    discountType = json['discountType'];
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
  num? discount;
  String? discountType;
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
    map['discount'] = discount;
    map['currencySymbol'] = currencySymbol;
    map['hasDiscount'] = hasDiscount;
    map['discountType'] = discountType;
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