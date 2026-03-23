class ClientSubscriptionInvoiceDetailsResponseModel {
  ClientSubscriptionInvoiceDetailsResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.total, 
      this.count, 
      this.next, 
      this.subscriptions,});

  ClientSubscriptionInvoiceDetailsResponseModel.fromJson(dynamic json) {
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
      this.subscription, 
      this.user, 
      this.amount, 
      this.currency, 
      this.paymentDate, 
      this.paymentMethod, 
      this.status, 
      this.transactionId, 
      this.orderId, 
      this.createdAt, 
      this.updatedAt, 
      this.invoiceUrl,
      this.v,});

  Subscriptions.fromJson(dynamic json) {
    id = json['_id'];
    subscription = json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null;
    user = json['user'];
    amount = json['amount'];
    currency = json['currency'];
    paymentDate = json['paymentDate'];
    paymentMethod = json['paymentMethod'];
    status = json['status'];
    transactionId = json['transactionId'];
    orderId = json['orderId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    invoiceUrl = json['invoiceUrl'];
    v = json['__v'];
  }
  String? id;
  Subscription? subscription;
  String? user;
  num? amount;
  String? currency;
  String? paymentDate;
  String? paymentMethod;
  String? status;
  String? transactionId;
  String? orderId;
  String? createdAt;
  String? updatedAt;
  String? invoiceUrl;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    if (subscription != null) {
      map['subscription'] = subscription?.toJson();
    }
    map['user'] = user;
    map['amount'] = amount;
    map['currency'] = currency;
    map['paymentDate'] = paymentDate;
    map['paymentMethod'] = paymentMethod;
    map['status'] = status;
    map['transactionId'] = transactionId;
    map['orderId'] = orderId;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['invoiceUrl'] = invoiceUrl??"";
    map['__v'] = v;
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
    plan = json['plan'];
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
  String? plan;
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
    map['plan'] = plan;
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