import 'dart:developer';

import 'package:flutter/foundation.dart';

class Logcat {
  Logcat._();

  static void msg(String msg, {bool printWithLog = false}) {
    if (kDebugMode) {
      if (printWithLog) {
        log(msg);
      } else {
        print(msg);
      }
    }
  }

  static void stack(StackTrace? stackTrace) {
    if (kDebugMode) {
      print(stackTrace);
    }
  }
}
