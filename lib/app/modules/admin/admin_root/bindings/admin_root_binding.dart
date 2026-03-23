import 'package:get/get.dart';
import 'package:mh/app/modules/admin/admin_client_request/controllers/admin_client_request_controller.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/admin/admin_root/controllers/admin_root_controller.dart';
import 'package:mh/app/modules/admin/admin_search/controllers/admin_search_controller.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';

import '../../../../../core/api_client/api_client.dart';
import '../../../../../core/api_client/plag_it_api_client.dart';
import '../../../../../data/data_sources/social_feed_data_source.dart';
import '../../../../../data/data_sources_impl/social_feed_data_source_impl.dart';
import '../../../../../data/repositories_impl/social_feed_repository_impl.dart';
import '../../../../../domain/repositories/social_feed_repository.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../../employee/employee_payment_history/controllers/employee_payment_history_controller.dart';
import '../../chat_it/controllers/chat_it_controller.dart';

class AdminRootBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => PlagITApiClient());

    Get.lazyPut<CommonSocialFeedController>(
          () => CommonSocialFeedController(socialFeedRepository:  Get.find(),),
    );
    Get.lazyPut<SocialFeedDataSource>(
          () => SocialFeedDataSourceImpl(apiClient: Get.find()),
    );
    Get.lazyPut<SocialFeedRepository>(
          () => SocialFeedRepositoryImpl(
        socialFeedDataSource: Get.find(),
      ),
    );
   Get.lazyPut(()=>AdminRootController());
   Get.lazyPut(()=>AdminHomeController());
   Get.lazyPut(()=>AdminSearchController());
   Get.lazyPut(()=>AdminClientRequestController());
   Get.lazyPut(()=>NotificationsController());
   Get.lazyPut(()=>EmployeePaymentHistoryController());
   Get.lazyPut<ChatItController>(() => ChatItController());
  //  Get.lazyPut(()=>CommonSearchController());
  }

}