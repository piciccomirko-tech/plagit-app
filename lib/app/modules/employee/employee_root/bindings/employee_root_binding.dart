import 'package:get/get.dart';
import 'package:mh/app/modules/admin/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/employee/employee_edit_profile/controllers/employee_profile_picture_upload_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_payment_history/controllers/employee_payment_history_controller.dart';
import 'package:mh/app/modules/employee/employee_root/controllers/employee_root_controller.dart';
import 'package:mh/app/modules/employee/employee_search/controllers/employee_search_controller.dart';
import 'package:mh/data/data_sources/social_feed_data_source.dart';
import 'package:mh/data/repositories_impl/social_feed_repository_impl.dart';

import '../../../../../core/api_client/api_client.dart';
import '../../../../../core/api_client/plag_it_api_client.dart';
import '../../../../../data/data_sources_impl/social_feed_data_source_impl.dart';
import '../../../../../domain/repositories/social_feed_repository.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';

class EmployeeRootBinding extends Bindings {
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
    Get.lazyPut<EmployeeRootController>(() => EmployeeRootController());
    Get.lazyPut<EmployeeHomeController>(() => EmployeeHomeController());
    Get.lazyPut<EmployeeSearchController>(() => EmployeeSearchController());
    Get.lazyPut<EmployeePaymentHistoryController>(() => EmployeePaymentHistoryController());
    Get.lazyPut<ChatItController>(() => ChatItController());
    Get.lazyPut<NotificationsController>(() => NotificationsController());
    Get.lazyPut(()=>CandidateProfilePictureController());
  }
}
