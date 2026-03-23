import 'package:mh/data/response_models/payment_response_model.dart';

class PaymentModel {
  final String? status;
  final int? statusCode;
  final String? message;
  final int? total;
  final int? count;
  final String? next;
  final List<PaymentResult>? results;

  PaymentModel({
    this.status,
    this.statusCode,
    this.message,
    this.total,
    this.count,
    this.next,
    this.results,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      status: json['status'],
      statusCode: json['statusCode'],
      message: json['message'],
      total: json['total'],
      count: json['count'],
      next: json['next'],
      results: json['result'] != null
          ? List<PaymentResult>.from(
              json['result'].map((item) => PaymentResult.fromJson(item)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'statusCode': statusCode,
      'message': message,
      'total': total,
      'count': count,
      'next': next,
      'result': results?.map((item) => item.toJson()).toList(),
    };
  }
}

class PaymentResult {
  final String? id;
  final String? employeeId;
  final String? hiredBy;
  final EmployeeDetails? employeeDetails;
  final RestaurantDetails? restaurantDetails;
  final String? invoiceUrl;
  final List<BookedDate>? bookedDates;
  final String? endHiredDate;
  final bool? uniformMandatory;
  final bool? clientReview;
  final bool? employeeReview;
  final String? paymentResponse;
  final String? paymentStatus;
  final double? totalPlatformFee;
  final bool? status;
  final String? createdAt;
  final String? updatedAt;

  PaymentResult({
    this.id,
    this.employeeId,
    this.hiredBy,
    this.employeeDetails,
    this.restaurantDetails,
    this.invoiceUrl,
    this.bookedDates,
    this.endHiredDate,
    this.uniformMandatory,
    this.clientReview,
    this.employeeReview,
    this.paymentResponse,
    this.paymentStatus,
    this.totalPlatformFee,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      id: json['_id'],
      employeeId: json['employeeId'],
      hiredBy: json['hiredBy'],
      employeeDetails: json['employeeDetails'] != null
          ? EmployeeDetails.fromJson(json['employeeDetails'])
          : null,
      restaurantDetails: json['restaurantDetails'] != null
          ? RestaurantDetails.fromJson(json['restaurantDetails'])
          : null,
      invoiceUrl: json['invoiceUrl'],
      bookedDates: json['bookedDate'] != null
          ? List<BookedDate>.from(
              json['bookedDate'].map((item) => BookedDate.fromJson(item)),
            )
          : null,
      endHiredDate: json['endHiredDate'],
      uniformMandatory: json['uniformMandatory'],
      clientReview: json['clientReview'],
      employeeReview: json['employeeReview'],
      paymentResponse: json['paymentResponse'],
      paymentStatus: json['paymentStatus'],
      totalPlatformFee: (json['totalPlatformFee'] as num?)?.toDouble(),
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeId': employeeId,
      'hiredBy': hiredBy,
      'employeeDetails': employeeDetails?.toJson(),
      'restaurantDetails': restaurantDetails?.toJson(),
      'invoiceUrl': invoiceUrl,
      'bookedDate': bookedDates?.map((item) => item.toJson()).toList(),
      'endHiredDate': endHiredDate,
      'uniformMandatory': uniformMandatory,
      'clientReview': clientReview,
      'employeeReview': employeeReview,
      'paymentResponse': paymentResponse,
      'paymentStatus': paymentStatus,
      'totalPlatformFee': totalPlatformFee,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
