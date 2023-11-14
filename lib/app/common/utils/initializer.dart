import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mh/app/common/controller/app_error_controller.dart';
import '../../repository/api_helper.dart';
import '../../repository/api_helper_impl.dart';
import '../controller/app_controller.dart';
import '../controller/app_life_cycle_controller.dart';
import '../widgets/custom_error_widget.dart';
import 'logcat.dart';

class Initializer {
  static const Initializer instance = Initializer._internal();

  factory Initializer() => instance;

  const Initializer._internal();

  Future<void> init() async {
    await runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details);
        Logcat.msg(details.stack.toString());
        AppErrorController.submitAutomaticError(
          errorName: "From: initializer.dart > FlutterError.onError",
          description: details.stack.toString(),
        );
      };

      ErrorWidget.builder = (errorDetails) {
        AppErrorController.submitAutomaticError(
          errorName: "From: initializer.dart > ErrorWidget.builder",
          description: errorDetails.exceptionAsString(),
        );
        return CustomErrorWidget(
          error: errorDetails.exceptionAsString(),
        );
      };

      await _initServices();
    }, (error, StackTrace stackTrace) {
      Logcat.msg('runZonedGuarded: $error');
      Logcat.stack(stackTrace);
    });
  }

  Future<void> _initServices() async {
    try {
      _initScreenPreference();
      _initStorage();

      Get.put(AppController());
      Get.put(AppLifecycleController());

    } catch (err) {
      rethrow;
    }
  }

  void _initScreenPreference() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initStorage() async {
    await GetStorage.init();
  }

}

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiHelper>(ApiHelperImpl());
  }
}
