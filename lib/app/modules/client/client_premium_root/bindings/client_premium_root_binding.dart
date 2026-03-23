import 'package:get/get.dart';
import 'package:mh/app/modules/admin/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/controllers/client_payment_and_invoice_controller.dart';
import 'package:mh/app/modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import 'package:mh/app/modules/client/client_search/controllers/client_search_controller.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/common_modules/search/controllers/common_search_controller.dart';
import 'package:mh/data/data_sources/check_in_check_out_data_source.dart';
import 'package:mh/data/data_sources/payment_data_source.dart';
import 'package:mh/data/data_sources_impl/check_in_check_out_data_source_impl.dart';
import 'package:mh/data/data_sources_impl/payment_data_source_impl.dart';
import 'package:mh/data/repositories_impl/check_in_check_out_impl.dart';
import 'package:mh/data/repositories_impl/payment_repository_impl.dart';
import 'package:mh/domain/repositories/payment_repository.dart';

import '../../../../../core/api_client/api_client.dart';
import '../../../../../core/api_client/plag_it_api_client.dart';
import '../../../../../data/data_sources/social_feed_data_source.dart';
import '../../../../../data/data_sources_impl/social_feed_data_source_impl.dart';
import '../../../../../data/repositories_impl/social_feed_repository_impl.dart';
import '../../../../../domain/repositories/check_in_check_out_repository.dart';
import '../../../../../domain/repositories/social_feed_repository.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../location/controllers/nearby_employee_controller.dart';

class ClientPremiumRootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientPremiumRootController());
    Get.lazyPut(() => ClientSearchController());
    Get.lazyPut(() => ClientHomePremiumController());

    Get.lazyPut(() => ChatItController());
    Get.lazyPut(() => NotificationsController());
    Get.lazyPut(() => ClientHomeController());
    Get.lazyPut(() => CommonSearchController());
    Get.lazyPut<ApiClient>(() => PlagITApiClient());

    Get.lazyPut<CommonSocialFeedController>(
      () => CommonSocialFeedController(
        socialFeedRepository: Get.find(),
      ),
    );
    Get.lazyPut<SocialFeedDataSource>(
      () => SocialFeedDataSourceImpl(apiClient: Get.find()),
    );
    Get.lazyPut<SocialFeedRepository>(
      () => SocialFeedRepositoryImpl(
        socialFeedDataSource: Get.find(),
      ),
    );

    Get.lazyPut<NearbyEmployeeController>(
          () => NearbyEmployeeController(),
      fenix: true
    );

    Get.lazyPut(
      () => ClientPaymentAndInvoiceController(
        paymentRepository: Get.find(),
      ),
    );
    Get.lazyPut<PaymentDataSource>(
      () => PaymentDataSourceImpl(apiClient: Get.find()),
    );
    Get.lazyPut<PaymentRepository>(
      () => PaymentRepositoryImpl(
        paymentDataSource: Get.find(),
      ),
    );
    Get.lazyPut<CheckInCheckOutRepository>(
      () => CheckInCheckOutImpl(checkInCheckOutDataSource:Get.find()),
    );
    Get.lazyPut<CheckInCheckOutDataSource>(
      () => CheckInCheckOutDataSourceImpl(apiClient:Get.find()),
    );
  }
}
