import 'package:get/get.dart';
import 'package:mh/app/modules/common_modules/create_post/controllers/create_post_controller.dart';
import 'package:mh/core/api_client/api_client.dart';
import 'package:mh/core/api_client/plag_it_api_client.dart';
import 'package:mh/data/data_sources/social_post_data_source.dart';
import 'package:mh/data/data_sources_impl/social_post_data_source_impl.dart';
import 'package:mh/data/repositories_impl/social_post_repository_impl.dart';
import 'package:mh/domain/repositories/social_post_repository.dart';

import '../controllers/new_create_post_controller.dart';
import '../controllers/update_post_controller.dart';

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => PlagITApiClient());

    Get.lazyPut<SocialPostDataSource>(
      () => SocialPostDataSourceImpl(apiClient: Get.find()),
    );

    Get.lazyPut<SocialPostRepository>(
      () => SocialPostRepositoryImpl(
        socialPostDataSource: Get.find(),
      ),
    );

    Get.lazyPut<CreatePostController>(
      () => CreatePostController(
        socialPostRepository: Get.find(),
      ),
    );

    ///todo
    Get.lazyPut<NewCreatePostController>(
      () => NewCreatePostController(
        socialPostRepository: Get.find(),
      ),
    );
    Get.lazyPut<UpdatePostController>(
      () => UpdatePostController(
        socialPostRepository: Get.find(),
      ),
    );
  }
}
