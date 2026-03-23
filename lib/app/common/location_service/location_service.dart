
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import '../values/my_strings.dart';
import '../widgets/custom_dialog.dart';

class LocationService extends GetxService {
  final currentLocation = const LatLng(0, 0).obs;
  bool _isCheckingPermission = false;

  @override
  void onInit() async {
    if (kDebugMode) {
      print('called');
    }
    await checkAndRequestPermission();
    super.onInit();
  }

  Future<void> checkAndRequestPermission() async {
    if (_isCheckingPermission) return;
    _isCheckingPermission = true;

    try {
      // Check location services
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationServicesDialog();
        _isCheckingPermission = false;
        return;
      }

      // Check permission
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();

      if (permission == geo.LocationPermission.whileInUse ||
          permission == geo.LocationPermission.always) {
        // Get location if permission is granted
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        currentLocation.value = LatLng(position.latitude, position.longitude);
      } else if (permission == geo.LocationPermission.denied) {
        // Request permission if denied
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          await _showPermissionDeniedDialog();
        }
      } else if (permission == geo.LocationPermission.deniedForever) {
        await _showPermissionPermanentlyDeniedDialog();
      }
    } finally {
      _isCheckingPermission = false;
    }
  }

  Future<void> _showLocationServicesDialog() async {
    if (Get.isDialogOpen ?? false) return;
    await CustomDialogue.information(
        context: Get.context!,
        title: MyStrings.warning.tr,
        description: MyStrings.enableDeviceLocation.tr,
        onTap: () async {
          Get.back();
          Platform.isIOS
              ? await openAppSettings()
              : await geo.Geolocator.openLocationSettings();
          await Future.delayed(const Duration(seconds: 3));
          // Check permission again after returning from settings
          await Future.delayed(const Duration(seconds: 1));
          await checkAndRequestPermission();
        });
    // await Get.dialog(
    //   WillPopScope(
    //     onWillPop: () async => false,
    //     child: AlertDialog(
    //       title: Text(MyStrings.locationServicesDisabled.tr),
    //       content: const Text(
    //           "This app requires location services to be enabled. Please enable location services to continue."),
    //       actions: [
    //         TextButton(
    //           child: const Text("Open Settings"),
    //           onPressed: () async {
    //             _isInSettings = true;
    //             Get.back();
    //             Platform.isIOS
    //                 ? await openAppSettings()
    //                 : await geo.Geolocator.openLocationSettings();
    //             await Future.delayed(const Duration(seconds: 5));
    //             _isInSettings = false;
    //             // Check permission again after returning from settings
    //             await Future.delayed(const Duration(seconds: 1));
    //             await checkAndRequestPermission();
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    //   barrierDismissible: false,
    // );
  }

  Future<void> _showPermissionDeniedDialog() async {
    if (Get.isDialogOpen ?? false) return;
    await CustomDialogue.information(
        context: Get.context!,
        title: MyStrings.warning.tr,
        description: MyStrings.enableDeviceLocation.tr,
        onTap: () async {
          Get.back();
          Platform.isIOS
              ? await openAppSettings()
              : await geo.Geolocator.openAppSettings();
          await Future.delayed(const Duration(seconds: 2));
          // Check permission again after returning from settings
          await Future.delayed(const Duration(seconds: 1));
          await checkAndRequestPermission();
        });
    // await Get.dialog(
    //   WillPopScope(
    //     onWillPop: () async => false,
    //     child: AlertDialog(
    //       title: const Text("Location Permission Required"),
    //       content: const Text(
    //           "This app requires location permission to function. Please grant the permission to continue."),
    //       actions: [
    //         TextButton(
    //           child: const Text("Open Settings"),
    //           onPressed: () async {
    //             _isInSettings = true;
    //             Get.back();
    //             Platform.isIOS
    //                 ? await openAppSettings()
    //                 : await geo.Geolocator.openAppSettings();
    //             await Future.delayed(const Duration(seconds: 5));
    //             _isInSettings = false;
    //             // Check permission again after returning from settings
    //             await Future.delayed(const Duration(seconds: 1));
    //             await checkAndRequestPermission();
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    //   barrierDismissible: false,
    // );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    if (Get.isDialogOpen ?? false) return;

    await CustomDialogue.information(
        context: Get.context!,
        title: MyStrings.warning.tr,
        description: MyStrings.enableDeviceLocation.tr,
        onTap: () async {
          Get.back();
          Platform.isIOS
              ? await openAppSettings()
              : await geo.Geolocator.openAppSettings();
          await Future.delayed(const Duration(seconds: 2));
          // Check permission again after returning from settings
          await Future.delayed(const Duration(seconds: 1));
          await checkAndRequestPermission();
        });

    // await Get.dialog(
    //   WillPopScope(
    //     onWillPop: () async => false,
    //     child: AlertDialog(
    //       title: const Text("Location Permission Required"),
    //       content: const Text(
    //           "Location permission is permanently denied. Please enable it in Settings to continue."),
    //       actions: [
    //         TextButton(
    //           child: const Text("Open Settings"),
    //           onPressed: () async {
    //             _isInSettings = true;
    //             Get.back();
    //             Platform.isIOS
    //                 ? await openAppSettings()
    //                 : await geo.Geolocator.openAppSettings();
    //             await Future.delayed(const Duration(seconds: 5));
    //             _isInSettings = false;
    //             // Check permission again after returning from settings
    //             await Future.delayed(const Duration(seconds: 1));
    //             await checkAndRequestPermission();
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    //   barrierDismissible: false,
    // );
  }
}

///Old
/*class LocationService extends GetxService {
  final currentLocation = const LatLng(0, 0).obs;

  @override
  void onInit() async {
    print('called');
    await _startLocationPermissionCheck();
    super.onInit();
  }

  Future<void> _startLocationPermissionCheck() async {
    try {
      while (true) {
        // Keep looping until permission is granted
        geo.LocationPermission currentPermission =
            await geo.Geolocator.checkPermission();

        if (currentPermission == geo.LocationPermission.whileInUse ||
            currentPermission == geo.LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);
          currentLocation.value = LatLng(position.latitude, position.longitude);
          return; // Exit loop if permission is granted
        }

// Ensure location services are enabled
        bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          bool shouldContinue = await _showLocationServicesDialog();
          if (!shouldContinue) return;
          await Future.delayed(
              Duration(seconds: 1)); // Small delay before rechecking
          continue;
        }

// Request permission if not granted
        if (currentPermission == geo.LocationPermission.denied) {
          currentPermission = await geo.Geolocator.requestPermission();
          if (currentPermission == geo.LocationPermission.denied) {
            await _showPermissionDeniedDialog();
            await Future.delayed(Duration(seconds: 1));
            continue; // Repeat the loop
          }
        }

        if (currentPermission == geo.LocationPermission.deniedForever) {
          bool result = await _showPermissionPermanentlyDeniedDialog();

          await Future.delayed(Duration(seconds: 3));
          continue; // Repeat the loop
        }
      }
    } catch (e) {
      debugPrint('Error in permission check: $e');
      currentLocation.value =
          const LatLng(LocationController.mhLat, LocationController.mhLong);
    }
  }

  Future<bool> _showPermissionDeniedDialog() async {
    print('LocationService._showPermissionDeniedDialog');
    final result = await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
              "Please enable location permission to use map features. You can enable it in Settings."),
          actions: [
            TextButton(
              child: Text(MyStrings.settings.tr),
              onPressed: () async {
                Get.back(result: true);
                if (Platform.isIOS) {
                  await openAppSettings();
// Wait for the user to return from the settings screen
                  await Future.delayed(Duration(
                      seconds: 2)); // Give time for settings to take effect
                } else {
                  await geo.Geolocator.openAppSettings();
                }
              },
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  Future<bool> _showPermissionPermanentlyDeniedDialog() async {
    print('LocationService._showPermissionPermanentlyDeniedDialog');
    final result = await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
              "Location permission is permanently denied. Please enable it from Settings to use map features."),
          actions: [
            TextButton(
              child: Text(MyStrings.settings.tr),
              onPressed: () async {
                Get.back(result: true);
                if (Platform.isIOS) {
                  await openAppSettings();
// Wait for the user to return from the settings screen
                  await Future.delayed(Duration(
                      seconds: 2)); // Give time for settings to take effect
                } else {
                  await geo.Geolocator.openAppSettings();
                }
              },
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  Future<bool> _showLocationServicesDialog() async {
    print('LocationService._showLocationServicesDialog');
    final result = await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: AlertDialog(
          title: Text(MyStrings.locationServicesDisabled.tr),
          content:
              const Text("Please enable location services to use map features"),
          actions: [
            TextButton(
              child: Text(MyStrings.settings.tr),
              onPressed: () async {
                Get.back(result: true);
                await geo.Geolocator.openLocationSettings();
              },
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}*/
