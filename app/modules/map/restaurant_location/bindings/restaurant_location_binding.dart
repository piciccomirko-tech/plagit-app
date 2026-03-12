import 'package:get/get.dart';

import '../controllers/restaurant_location_controller.dart';

class RestaurantLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantLocationController>(
      () => RestaurantLocationController(),
    );
  }
}
