
import 'package:mh/core/api_client/api_client.dart';
import 'package:mh/core/api_client/api_end_points.dart';
import '../../domain/model/check_in_check_out_history_model.dart';
import '../data_sources/check_in_check_out_data_source.dart';

class CheckInCheckOutDataSourceImpl implements CheckInCheckOutDataSource {
  ApiClient apiClient;

  CheckInCheckOutDataSourceImpl({required this.apiClient});

  @override
  Future<CheckInCheckOutHistoryModel> getCheckInOutUpdateHistory({
    required String currentHiredEmployeeId,
  }) async {

    final response = await apiClient.get(
      EndPoints.checkInCheckOutUpdateHistory+currentHiredEmployeeId,
    );

    return CheckInCheckOutHistoryModel.fromJson(response);

    // Set options for the request
    // dio.Options options = dio.Options(
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Vary': 'Accept',
    //     'Authorization': 'Bearer ${StorageHelper.getToken}',
    //   },
    //   sendTimeout: const Duration(minutes: 20),
    //   followRedirects: false,
    // );

    // dio.Response response = await apiClient.get(
    //   "${apiClient.baseUrl}/${EndPoints.checkInCheckOutUpdateHistory}$currentHiredEmployeeId",
    // );
    //
    // final convertedModel = CheckInCheckOutHistory(
    //   status: response.data['status'],
    //   statusCode: response.data['statusCode'],
    //   message: response.data['message'],
    //   total: response.data['result']['total'],
    //   count: response.data['result']['count'],
    //   checkInCheckOutHistory:response.data['result']['result']
    // );
    //
    // return convertedModel;
  }
}
