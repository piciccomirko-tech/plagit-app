import 'package:get/get.dart';
import 'package:mh/app/modules/client/client_search/controllers/client_search_controller.dart';

class ClientSearchBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>ClientSearchController());
  }

}