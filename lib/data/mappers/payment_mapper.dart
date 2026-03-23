import 'package:mh/data/response_models/payment_response_model.dart';
import 'package:mh/domain/model/payment_model.dart';

class PaymentMapper {
  static PaymentModel? mapResponseToDomain(PaymentResponseModel? response) {
    if (response == null ||
        response.result == null ||
        response.result!.isEmpty) {
      return null;
    }

    final List<PaymentResult> results = response.result!.map((result) {
      return PaymentResult(
        id: result.sId ?? '',
        employeeId: result.employeeId ?? '',
        hiredBy: result.hiredBy ?? '',
        employeeDetails: result.employeeDetails != null
            ? EmployeeDetails(
                employeeId: result.employeeDetails!.employeeId ?? '',
                name: result.employeeDetails!.name ?? '',
                positionId: result.employeeDetails!.positionId ?? '',
                positionName: result.employeeDetails!.positionName ?? '',
                presentAddress: result.employeeDetails!.presentAddress ?? '',
                permanentAddress:
                    result.employeeDetails!.permanentAddress ?? '',
                employeeExperience:
                    result.employeeDetails!.employeeExperience ?? '',
                totalWorkingHour:
                    result.employeeDetails!.totalWorkingHour ?? '',
                hourlyRate: result.employeeDetails!.hourlyRate ?? 0,
                contractorHourlyRate:
                    result.employeeDetails!.contractorHourlyRate ?? 0,
                profilePicture: result.employeeDetails!.profilePicture ?? '',
                countryName: result.employeeDetails!.countryName ?? '',
                certified: result.employeeDetails!.certified ?? false,
                sId: result.employeeDetails!.sId ?? '',
                lat: result.employeeDetails!.lat ?? '',
                long: result.employeeDetails!.long ?? '',
              )
            : null,
        restaurantDetails: result.restaurantDetails != null
            ? RestaurantDetails(
                hiredBy: result.restaurantDetails!.hiredBy ?? '',
                restaurantName: result.restaurantDetails!.restaurantName ?? '',
                restaurantAddress:
                    result.restaurantDetails!.restaurantAddress ?? '',
                lat: result.restaurantDetails!.lat ?? '',
                long: result.restaurantDetails!.long ?? '',
                countryName: result.restaurantDetails!.countryName ?? '',
                profilePicture: result.restaurantDetails!.profilePicture ?? '',
                sId: result.restaurantDetails!.sId ?? '',
              )
            : null,
        invoiceUrl: result.invoiceUrl ?? '',
        bookedDates: result.bookedDate?.map((bookedDate) {
          return BookedDate(
            startDate: bookedDate.startDate ?? '',
            endDate: bookedDate.endDate ?? '',
            startTime: bookedDate.startTime ?? '',
            endTime: bookedDate.endTime ?? '',
            perDayPlatformFee: bookedDate.perDayPlatformFee ?? 0.0,
            totalPlatformFee: bookedDate.totalPlatformFee ?? 0.0,
            totalHours: bookedDate.totalHours ?? '',
            amount: bookedDate.amount ?? 0,
          );
        }).toList(),
        endHiredDate: result.endHiredDate ?? '',
        uniformMandatory: result.uniformMandatory ?? false,
        clientReview: result.clientReview ?? false,
        employeeReview: result.employeeReview ?? false,
        paymentResponse: result.paymentResponse ?? '',
        paymentStatus: result.paymentStatus ?? '',
        totalPlatformFee: result.totalPlatformFee ?? 0.0,
        status: result.status ?? false,
        createdAt: result.createdAt ?? '',
        updatedAt: result.updatedAt ?? '',
      );
    }).toList();

    return PaymentModel(
      status: response.status ?? '',
      statusCode: response.statusCode ?? 0,
      message: response.message ?? '',
      total: response.total ?? 0,
      count: response.count ?? 0,
      next: response.next,
      results: results,
    );
  }
}
