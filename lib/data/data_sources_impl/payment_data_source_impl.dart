import 'package:get/get.dart';
import 'package:mh/core/api_client/api_client.dart';
import 'package:mh/data/data_sources/payment_data_source.dart';
import 'package:mh/data/response_models/payment_response_model.dart';

import '../../app/common/controller/app_controller.dart';
import '../../core/api_client/api_end_points.dart';

class PaymentDataSourceImpl implements PaymentDataSource {
  ApiClient apiClient;

  PaymentDataSourceImpl({required this.apiClient});

  @override
  Future<PaymentResponseModel> getPaymentDetails() async {
    var paymentBaseUrl = "${EndPoints.payment}?filterDate=null&status=&hiredBy=${Get.find<AppController>().user.value.client?.id}";

    final response = await apiClient.get(
      paymentBaseUrl,
    );

    return PaymentResponseModel.fromJson(response);
  }
}
