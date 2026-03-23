import '../local_storage/storage_helper.dart';
import '../utils/exports.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  void updateThemeMode(ThemeMode mode) {
    isDarkMode.value = mode == ThemeMode.dark;
  }

   // Observable theme mode
  Rx<ThemeMode> themeMode = StorageHelper.themeMode.obs;


  // Toggle between dark and light mode
  void switchTheme(String theme) {
    if (theme == "dark") {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }

    // Save the user preference and update immediately
    StorageHelper.setPlagitTheme(theme);
    Get.changeThemeMode(themeMode.value); // Update the app theme mode
    update();
  }

  // Reset to system default theme
  void resetToSystemDefault() {
    themeMode.value = ThemeMode.system;
    StorageHelper.setPlagitTheme("system");
    Get.changeThemeMode(ThemeMode.system);
    update();
  }
  // // Switch theme between system, light, and dark
  // void switchTheme(String theme) {
  //   switch (theme) {
  //     case "dark":
  //       themeMode.value = ThemeMode.dark;
  //       break;
  //     case "light":
  //       themeMode.value = ThemeMode.light;
  //       break;
  //     default:
  //       themeMode.value = ThemeMode.system;
  //   }

  //   // Save to local storage
  //   StorageHelper.setPlagitTheme(theme);
  //   update();
  // }
}
