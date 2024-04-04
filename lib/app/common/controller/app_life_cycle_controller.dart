import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'app_controller.dart';

class AppLifecycleController extends GetxController with WidgetsBindingObserver {
  final AppController _appController = Get.find();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // priority 3
        if (kDebugMode) {
          print('App resumed');
        }
        break;

      case AppLifecycleState.paused:
        // priority 2
        if (kDebugMode) {
          print('App paused');
        }
        break;

      case AppLifecycleState.inactive:
        // priority 1 // call offline true
        if (kDebugMode) {
          print('App inactive');
        }
        break;

      case AppLifecycleState.detached:
        if (kDebugMode) {
          print('App detached');
        }
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }
}
