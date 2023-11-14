import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../modules/chat/client_employee_chat/controllers/client_employee_chat_controller.dart';
import '../../modules/chat/support_chat/controllers/support_chat_controller.dart';
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

        if(Get.isRegistered<ClientEmployeeChatController>()) {
          _updateActiveStatus(true);
        }
        else if(Get.isRegistered<SupportChatController>()) {
          _updateActiveStatus(true);
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

        _updateActiveStatus(false);
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

  void _updateActiveStatus(bool active) {
    if((_appController.user.value.userId).isNotEmpty) {
      FirebaseFirestore.instance.collection('onChatScreen').doc(_appController.user.value.userId).set({
        "active" : active,
      });
    }
  }
}