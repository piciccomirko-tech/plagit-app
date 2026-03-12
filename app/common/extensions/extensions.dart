// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/modules/calender/models/calender_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

import '../../enums/selected_payment_method.dart';
import '../utils/exports.dart';

extension EitherX<L, R> on Either<L, R> {
  // success
  R get asRight => (this as Right).value;

  // fail
  L get asLeft => (this as Left).value;
}

extension CompactShort on num {
  String get compactShort {
    if (this < 1000) return toString();

    return "${(this / 1000).toStringAsFixed(1)}k";
  }
}

extension BoolApiFormat on bool {
  String get toApiFormat => this ? "YES" : "NO";
}

extension DatetimeFormat on DateTime {
  String get EdMMMy => DateFormat('E, d MMM y').format(this).toString();

  String get dMMMy => DateFormat('d MMM yy').format(this).toString();

  String differenceInDays(DateTime endDate) {
    int difference = endDate.difference(this).inDays + 1;

    return "$difference day${difference > 1 ? 's' : ''}";
  }
}

extension ImageUrl on String {
  String get imageUrl {
    if (isEmpty) return "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png";

    return "https://mh-user-bucket.s3.amazonaws.com/public/users/profile/$this";
  }
}

extension UniformImageUrl on String {
  String get uniformImageUrl {
    return "https://mh-user-bucket.s3.amazonaws.com/public/$this";
  }
}

extension PaymentMethods on SelectedPaymentMethod {
  bool get isCard => this == SelectedPaymentMethod.card;

  bool get isBank => this == SelectedPaymentMethod.bank;
}

extension TextColor on Color {
  TextStyle get regular9 => _textStyle(FontWeight.w400, 9);
  TextStyle get regular10 => _textStyle(FontWeight.w400, 10);
  TextStyle get regular11 => _textStyle(FontWeight.w400, 11);
  TextStyle get regular12 => _textStyle(FontWeight.w400, 12);
  TextStyle get regular13 => _textStyle(FontWeight.w400, 13);
  TextStyle get regular14 => _textStyle(FontWeight.w400, 14);
  TextStyle get regular15 => _textStyle(FontWeight.w400, 15);
  TextStyle get regular16 => _textStyle(FontWeight.w400, 16);
  TextStyle get regular16_5 => _textStyle(FontWeight.w400, 16.5);
  TextStyle get regular17 => _textStyle(FontWeight.w400, 17);
  TextStyle get regular18 => _textStyle(FontWeight.w400, 18);
  TextStyle get regular19 => _textStyle(FontWeight.w400, 19);
  TextStyle get regular20 => _textStyle(FontWeight.w400, 20);
  TextStyle get regular21 => _textStyle(FontWeight.w400, 21);
  TextStyle get regular22 => _textStyle(FontWeight.w400, 22);
  TextStyle get regular23 => _textStyle(FontWeight.w400, 23);
  TextStyle get regular24 => _textStyle(FontWeight.w400, 24);

  TextStyle get medium9 => _textStyle(FontWeight.w500, 9);
  TextStyle get medium10 => _textStyle(FontWeight.w500, 10);
  TextStyle get medium11 => _textStyle(FontWeight.w500, 11);
  TextStyle get medium12 => _textStyle(FontWeight.w500, 12);
  TextStyle get medium13 => _textStyle(FontWeight.w500, 13);
  TextStyle get medium14 => _textStyle(FontWeight.w500, 14);
  TextStyle get medium15 => _textStyle(FontWeight.w500, 15);
  TextStyle get medium16 => _textStyle(FontWeight.w500, 16);
  TextStyle get medium17 => _textStyle(FontWeight.w500, 17);
  TextStyle get medium18 => _textStyle(FontWeight.w500, 18);
  TextStyle get medium19 => _textStyle(FontWeight.w500, 19);
  TextStyle get medium20 => _textStyle(FontWeight.w500, 20);
  TextStyle get medium21 => _textStyle(FontWeight.w500, 21);
  TextStyle get medium22 => _textStyle(FontWeight.w500, 22);
  TextStyle get medium23 => _textStyle(FontWeight.w500, 23);
  TextStyle get medium24 => _textStyle(FontWeight.w500, 24);

  TextStyle get semiBold9 => _textStyle(FontWeight.w600, 9);
  TextStyle get semiBold10 => _textStyle(FontWeight.w600, 10);
  TextStyle get semiBold11 => _textStyle(FontWeight.w600, 11);
  TextStyle get semiBold12 => _textStyle(FontWeight.w600, 12);
  TextStyle get semiBold13 => _textStyle(FontWeight.w600, 13);
  TextStyle get semiBold14 => _textStyle(FontWeight.w600, 14);
  TextStyle get semiBold15 => _textStyle(FontWeight.w600, 15);
  TextStyle get semiBold16 => _textStyle(FontWeight.w600, 16);
  TextStyle get semiBold17 => _textStyle(FontWeight.w600, 17);
  TextStyle get semiBold18 => _textStyle(FontWeight.w600, 18);
  TextStyle get semiBold19 => _textStyle(FontWeight.w600, 19);
  TextStyle get semiBold20 => _textStyle(FontWeight.w600, 20);
  TextStyle get semiBold21 => _textStyle(FontWeight.w600, 21);
  TextStyle get semiBold22 => _textStyle(FontWeight.w600, 22);
  TextStyle get semiBold23 => _textStyle(FontWeight.w600, 23);
  TextStyle get semiBold24 => _textStyle(FontWeight.w600, 24);
  TextStyle get semiBold26 => _textStyle(FontWeight.w600, 26);

  TextStyle _textStyle(FontWeight fontWeight, double size) => TextStyle(
        fontFamily: MyAssets.fontMontserrat,
        fontWeight: fontWeight,
        fontSize: size.sp,
        decoration: TextDecoration.none,
        color: this,
      );
}

extension DateRangeExtension on List<CalenderDataModel> {
  bool containsDate(DateTime date) {
    for (final CalenderDataModel range in this) {
      final fromDate = DateTime.parse(range.startDate ?? '');
      final toDate = DateTime.parse(range.endDate ?? '');

      if (date.isAfter(fromDate.subtract(const Duration(days: 1))) &&
          date.isBefore(toDate.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }
}

extension DateRangeExtensionForCreateJob on List<RequestDateModel> {
  bool containsThisDate(DateTime date) {
    for (final RequestDateModel range in this) {
      final fromDate = DateTime.parse(range.startDate ?? '');
      final toDate = DateTime.parse(range.endDate ?? '');

      if (date.isAfter(fromDate.subtract(const Duration(days: 1))) &&
          date.isBefore(toDate.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }
}

extension DateExtension on DateTime {
  int daysUntil(DateTime other) {
    // Calculate the difference in days
    Duration difference = other.difference(this);

    // Add 1 to include both start and end dates in the count
    int count = difference.inDays + 1;

    return count;
  }
}

extension DateListExtension on List<CalenderDataModel> {
  bool anyDatesExistInRange({required String rangeStart, required String rangeEnd}) {
    DateTime startDate = DateTime.parse(rangeStart);
    DateTime endDate = DateTime.parse(rangeEnd);
    return any((CalenderDataModel dateModel) {
      DateTime modelStartDate = DateTime.parse(dateModel.startDate!);
      DateTime modelEndDate = DateTime.parse(dateModel.endDate!);

      return (modelStartDate.isAfter(startDate) && modelStartDate.isBefore(endDate)) ||
          (modelEndDate.isAfter(startDate) && modelEndDate.isBefore(endDate)) ||
          (modelStartDate.isBefore(startDate) && modelEndDate.isAfter(endDate));
    });
  }
}

extension DateTimeExtensions on DateTime {
  String calculateAge() {
    final DateTime currentDate = DateTime.now();
    final double age = currentDate.year - year + (currentDate.month - month) / 12;
    return '${age.round()} years';
  }
}

extension DateTimeWithAMPMExtensions on DateTime {
  String formatTimeWithAMPM() {
    DateFormat dateFormat = DateFormat('h:mm a');
    return dateFormat.format(this);
  }
}

extension DateTimeWithExactDateYearWeekdayExtensions on DateTime {
  String formatDateWithWeekday() {
    DateFormat dateFormat = DateFormat('E, d MMM, y');
    return dateFormat.format(this);
  }
}

extension DateTimeWithMonthYearExtensions on DateTime {
  String formatMonthYear() {
    DateFormat dateFormat = DateFormat('MMMM y');
    return dateFormat.format(this);
  }
}

extension RequestDateListExtension on List<RequestDateModel?> {
  int calculateTotalDays() {
    int totalDays = 0;
    for (var requestDate in this) {
      if (requestDate != null && requestDate.startDate != null && requestDate.endDate != null) {
        DateTime? startDate = DateTime.tryParse(requestDate.startDate!);
        DateTime? endDate = DateTime.tryParse(requestDate.endDate!);

        if (startDate != null && endDate != null) {
          int daysDifference = endDate.difference(startDate).inDays + 1;
          totalDays += daysDifference;
        }
      }
    }
    return totalDays;
  }
}

extension RequestDateListExtensions on List<RequestDateModel> {
  bool hasNullAttributes() {
    if (isEmpty) {
      return true;
    } else {
      for (var request in this) {
        if (request.startDate == null ||
            request.endDate == null ||
            request.startTime == null ||
            request.endTime == null) {
          return true;
        }
      }
    }
    return false;
  }
}

extension RequestDateExtensions on List<RequestDateModel> {
  double calculateTotalHourlyRate({required double hourlyRate}) {
    double totalRate = 0.0;
    try {
      for (var requestDate in this) {
        final startParts = requestDate.startTime?.split(':');
        final endParts = requestDate.endTime?.split(':');

        final startHour = int.parse(startParts![0]);
        final startMinute = int.parse(startParts[1].split(' ')[0]);
        final startAMPM = startParts[1].split(' ')[1];

        final endHour = int.parse(endParts![0]);
        final endMinute = int.parse(endParts[1].split(' ')[0]);
        final endAMPM = endParts[1].split(' ')[1];

        final totalStartHour = (startAMPM == 'PM' && startHour != 12) ? startHour + 12 : startHour;
        final totalEndHour = (endAMPM == 'PM' && endHour != 12) ? endHour + 12 : endHour;

        double durationInHours = (totalEndHour - totalStartHour) + (endMinute - startMinute) / 60.0;

        // Extra
        if (durationInHours.isNegative) {
          durationInHours = 24 + durationInHours;
        }

        // Calculate the total days in the date range
        final startDateParts = requestDate.startDate?.split('-');
        final toDateParts = requestDate.endDate?.split('-');

        final startDateTime = DateTime(
          int.parse(startDateParts![0]),
          int.parse(startDateParts[1]),
          int.parse(startDateParts[2]),
          totalStartHour,
          startMinute,
        );

        final endDateTime = DateTime(
          int.parse(toDateParts![0]),
          int.parse(toDateParts[1]),
          int.parse(toDateParts[2]),
          totalEndHour,
          endMinute,
        );

        final int daysInDateRange = endDateTime.difference(startDateTime).inDays + 1;

        totalRate += durationInHours * hourlyRate * daysInDateRange;
      }

      return totalRate.abs();
    } catch (_) {
      return totalRate;
    }
  }
}

extension TimeDifference on String {
  int hoursDifference(String otherTime) {
    int diff = 0;
    final timeFormat = DateFormat('hh:mm a');
    final thisTime = timeFormat.parse(this);
    final other = timeFormat.parse(otherTime);
    final difference = other.difference(thisTime);
    if (difference.inHours.isNegative) {
      diff = 24 + difference.inHours;
    } else {
      diff = difference.inHours;
    }
    return diff;
  }
}
