import '../utils/exports.dart';

class Toast {
  Toast._();

  static void snackbar(String msg) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
