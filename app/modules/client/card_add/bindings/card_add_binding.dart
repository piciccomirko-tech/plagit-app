import 'package:get/get.dart';

import '../controllers/card_add_controller.dart';

class CardAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CardAddController>(
      () => CardAddController(),
    );
  }
}
