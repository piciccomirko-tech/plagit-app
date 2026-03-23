import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:http/http.dart' as http;
import 'package:mh/app/common/extensions/extensions.dart';
import 'dart:convert';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_assets.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/dropdown_item.dart';
import '../../../../models/employees_by_id.dart';
import '../../../../repository/api_helper.dart';
import '../../../employee/employee_home/models/common_response_model.dart';
import '../models/auto_complete_search_model.dart';
import '../models/map_search_model.dart';
import '../models/saved_search_model.dart';
import '../widgets/custom_info_window.dart';
import 'package:permission_handler/permission_handler.dart';

class PlaceResult {
  final String name;
  final String address;
  final LatLng location;

  PlaceResult({
    required this.name,
    required this.address,
    required this.location,
  });
}

class LocationController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  final Completer<GoogleMapController> mapController = Completer();
  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();
  final currentRadius = 0.5.obs;
  final currentLocation = const LatLng(0, 0).obs;
  final selectedLocation = const LatLng(0, 0).obs;
  final isLoading = true.obs;
  final isDataLoading = false.obs;
  final mapStyle = ''.obs;
  final markers = <Marker>{}.obs;
  final searchQuery = ''.obs;
  final searchResults = <AutoCompleteSearchModel>[].obs;
  Timer? _debounce;
  final searchController = TextEditingController();

  Rx<Employees> employees = Employees().obs;
  RxList<SavedSearchModel> savedSearchList = <SavedSearchModel>[].obs;

  RxList<DropdownItem> positionList = <DropdownItem>[].obs;
  final selectedPosition = "".obs;

  final TextEditingController minRateController = TextEditingController();
  final TextEditingController maxRateController = TextEditingController();

  StreamSubscription<geo.Position>? _positionStreamSubscription;

  @override
  Future<void> onInit() async {
    await _getPositionWiseEmployees();
    await _loadMapStyle();
    await fetchSavedSearch();
    _shufflePositionList();
    checkLocationPermission();
    super.onInit();
  }

  // @override
  // void onReady() async {
  //   await _getPositionWiseEmployees();
  //   await _loadMapStyle();
  //   checkLocationPermission();
  //   super.onReady();
  // }

  Future<void> _loadMapStyle() async {
    try {
      final style = await rootBundle.loadString(MyAssets.nearbyMapStyle);
      mapStyle.value = style;
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchPlaces(query);
      } else {
        searchResults.clear();
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&key=AIzaSyDj8C1VcZWPlnRrHMc_2VjMLVZ3HmVxdWw'
          '&components=country:ae';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List;
        final results = <AutoCompleteSearchModel>[];

        for (var prediction in predictions) {
          results.add(
            AutoCompleteSearchModel.fromJson(
                prediction['structured_formatting']),
          );
        }

        searchResults.value = results;
      } else {
        searchResults.clear();
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      searchResults.clear();
    }
  }

  Future<void> onPlaceSelected(AutoCompleteSearchModel place) async {
    clearSearch();

    try {
      // Get place details to get coordinates
      final locationResults = await locationFromAddress(
        '${place.mainText}, ${place.secondaryText}',
      );

      if (locationResults.isNotEmpty) {
        final location = locationResults.first;
        selectedLocation.value = LatLng(location.latitude, location.longitude);

        final controller = await mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedLocation.value,
              zoom: 11,
            ),
          ),
        );

        // Update markers without clearing the circle
        await updateMarkersOnly();
      }
    } catch (e) {
      debugPrint('Error moving to selected place: $e');
    }
  }

  Future<void> updateMarkersOnly() async {
    if (selectedLocation.value == const LatLng(0, 0)) return;

    final newMarkers = <Marker>{};

    // Add user location marker
    newMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: selectedLocation.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    // Add professional markers within radius
    for (var employee in employees.value.users ?? []) {
      final position = LatLng(double.parse(employee.lat ?? "0"),
          double.parse(employee.long ?? "0"));
      if (_isWithinRadius(position)) {
        try {
          final markerIcon =
              await _createCustomMarkerFromUrl(employee.profilePicture ?? "");
          newMarkers.add(
            Marker(
              markerId: MarkerId('professional_${employee.id}'),
              position: position,
              icon: markerIcon,
              onTap: () {
                customInfoWindowController.addInfoWindow!(
                  CustomMarkerInfoWindow(
                    employeeId: employee.id,
                    image: "",
                    name: "${employee.firstName} ${employee.lastName}",
                    position: employee.positionName ?? "",
                    experience: "${employee.employeeExperience ?? 0}",
                    distance: "",
                    countryName: "",
                    rate: 0,
                  ),
                  position,
                );
              },
            ),
          );
        } catch (e) {
          debugPrint('Error creating marker: $e');
        }
      }
    }

    markers.value = newMarkers;
  }

  Future<BitmapDescriptor> _createCustomMarkerFromUrl(String imageUrl) async {
    try {
      // Use CachedNetworkImageProvider to load and cache the image
      final imageProvider = CachedNetworkImageProvider(imageUrl.imageUrl);

      // Obtain the image stream
      final imageStream = imageProvider.resolve(ImageConfiguration());

      // Wait until the image is loaded
      final completer = Completer<ui.Image>();
      imageStream.addListener(
          ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
        completer.complete(imageInfo.image); // Extract ui.Image from ImageInfo
      }));

      final image = await completer.future; // This will be the ui.Image

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(120, 180);
      const circleRadius = 35.0;
      final centerX = size.width / 2;
      const centerY = 50.0;
      const tailHeight = 30.0;
      const tailWidth = 25.0;
      const tailY = centerY + circleRadius;

      // Draw marker background
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX, centerY), circleRadius, markerPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = const Color(0xFF4FD2C2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;
      canvas.drawCircle(Offset(centerX, centerY), circleRadius, borderPaint);

      // Draw pointer tail
      final tailPath = Path()
        ..moveTo(centerX - tailWidth / 2, tailY)
        ..lineTo(centerX, tailY + tailHeight)
        ..lineTo(centerX + tailWidth / 2, tailY)
        ..close();
      final tailPaint = Paint()
        ..color = const Color(0xFF4FD2C2)
        ..style = PaintingStyle.fill;
      canvas.drawPath(tailPath, tailPaint);

      // Draw profile image
      final clipPath = Path()
        ..addOval(Rect.fromCircle(
            center: Offset(centerX, centerY), radius: circleRadius));
      canvas.clipPath(clipPath);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromCircle(center: Offset(centerX, centerY), radius: circleRadius),
        Paint(),
      );

      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final data = await img.toByteData(format: ui.ImageByteFormat.png);

      if (data == null) throw Exception('Failed to create marker image');
      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error creating custom marker: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  Future<void> checkLocationPermission() async {
    try {
      // First request the location permission directly
      var status = await Permission.location.status;

      if (status.isDenied) {
        // Request permission first
        status = await Permission.location.request();
        if (status.isDenied) {
          await _showPermissionDeniedDialog();
          return;
        }
      }

      if (status.isPermanentlyDenied) {
        await _showPermissionPermanentlyDeniedDialog();
        return;
      }

      // Then check if location service is enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationServiceDialog();
        return;
      }

      // Double check Geolocator permission
      geo.LocationPermission geoPermission =
          await geo.Geolocator.checkPermission();

      switch (geoPermission) {
        case geo.LocationPermission.denied:
          geoPermission = await geo.Geolocator.requestPermission();
          if (geoPermission == geo.LocationPermission.denied) {
            await _showPermissionDeniedDialog();
            return;
          }
          break;

        case geo.LocationPermission.deniedForever:
          await _showPermissionPermanentlyDeniedDialog();
          return;

        case geo.LocationPermission.unableToDetermine:
          await _showPermissionDeniedDialog();
          return;

        case geo.LocationPermission.whileInUse:
        case geo.LocationPermission.always:
          // Permission granted, proceed with location initialization
          break;
      }

      // If we reach here, we have both service enabled and permission granted
      await _initializeLocation();

      // Add location service status listener
      geo.Geolocator.getServiceStatusStream().listen((status) {
        if (status == geo.ServiceStatus.disabled) {
          _showLocationServiceDialog();
        } else if (status == geo.ServiceStatus.enabled) {
          _initializeLocation();
        }
      });
    } catch (e) {
      debugPrint('Error in checkLocationPermission: $e');
      Get.snackbar(
        'Error',
        'Unable to access location services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _showLocationServiceDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled. Please enable location services in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await geo.Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs access to location to show nearby professionals. '
          'Please grant location permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              // Open app settings if permission is permanently denied
              if (await Permission.location.isPermanentlyDenied) {
                await openAppSettings();
              } else {
                // Otherwise, try requesting permission again
                final status = await Permission.location.request();
                if (status.isGranted) {
                  checkLocationPermission();
                }
              }
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is permanently denied. '
          'Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;

      // Double check location service and permission before getting position
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied');
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentLocation.value;

      if (mapController.isCompleted) {
        final GoogleMapController controller = await mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation.value,
              zoom: 15,
            ),
          ),
        );
      }

      await updateMarkersOnly();
    } catch (e) {
      print('Error initializing location: $e');
      Get.snackbar(
        'Error',
        'Unable to get current location. Please check your location settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // void onRadiusChanged(double value) {
  //   currentRadius.value = value;
  //   // Only update markers, keep the circle
  //   updateMarkersOnly();
  // }

  void onRadiusChanged(double value) async {
    currentRadius.value = value;

    // Get appropriate zoom level based on radius
    // Smaller radius = higher zoom level (closer view)
    double zoomLevel;
    if (value <= 0.5) {
      zoomLevel = 15.0;
    } else if (value <= 1) {
      zoomLevel = 14.5;
    } else if (value <= 2) {
      zoomLevel = 14.0;
    } else if (value <= 3) {
      zoomLevel = 13.5;
    } else if (value <= 4) {
      zoomLevel = 13.0;
    } else if (value <= 5) {
      zoomLevel = 12.5;
    } else if (value <= 7) {
      zoomLevel = 12.0;
    } else if (value <= 8) {
      zoomLevel = 11.5;
    } else {
      zoomLevel = 11.0; // For radius 9-10km
    }

    // Update camera position with new zoom level
    if (mapController.isCompleted) {
      final controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: selectedLocation.value,
            zoom: zoomLevel,
          ),
        ),
      );
    }

    updateMarkersOnly();
  }

  bool _isWithinRadius(LatLng position) {
    if (selectedLocation.value == const LatLng(0, 0)) return false;

    final distance = geo.Geolocator.distanceBetween(
      selectedLocation.value.latitude,
      selectedLocation.value.longitude,
      position.latitude,
      position.longitude,
    );

    // Convert radius to meters (multiply by 1000 since radius is in km)
    return distance <= (currentRadius.value * 1000);
  }

  @override
  void onClose() {
    customInfoWindowController.dispose();
    _debounce?.cancel();
    searchController.dispose();
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _getPositionWiseEmployees() async {
    if (isDataLoading.value) return;

    isDataLoading.value = true;

    await _apiHelper
        .getAllEmployees()
        .then((Either<CustomError, Employees> response) {
      isDataLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (Employees employees) {
        this.employees.value = employees;
        this.employees.refresh();
      });
    });
  }

  void mapSearch() {
    CustomLoader.show(Get.context!);
    _apiHelper
        .mapSearch(
            address: "",
            lat: selectedLocation.value.latitude != 0
                ? selectedLocation.value.latitude.toString()
                : currentLocation.value.latitude.toString(),
            lang: selectedLocation.value.longitude != 0
                ? selectedLocation.value.longitude.toString()
                : currentLocation.value.longitude.toString(),
            totalCount: "",
            minRate: minRateController.text.trim(),
            maxRate: maxRateController.text.trim(),
            positionId: selectedPosition.value,
            radius: currentRadius.value.toString())
        .then((Either<CustomError, MapSearchResponseModel> responseData) {
      Get.back();
      CustomLoader.hide(Get.context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (MapSearchResponseModel r) {
        if (r.status == "success" && r.statusCode == 201 && r.details != null) {
          fetchSavedSearch();
          // loadWebView(sessionId: r.details?.id ?? "");
        }
      });
    });
  }

  Future<void> fetchSavedSearch() async {
    var result = await _apiHelper.getSavedSearch();
    result.fold(
      (failure) {
        print("Failed to fetch skills: $failure");
      },
      (List<SavedSearchModel> savedSearch) {
        // Assuming skills is a list of SkillModel
        savedSearchList.value = savedSearch;
      },
    );
  }

  void _shufflePositionList() {
    positionList = appController.allActivePositions;
  }

  void deleteMapSearch({required String searchId}) {
    CustomLoader.show(Get.context!);
    _apiHelper
        .deleteMapSearch(searchId: searchId)
        .then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(Get.context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(Get.context!, customError);
      }, (CommonResponseModel responseModel) {
        if (responseModel.status == 'success') {
          fetchSavedSearch();
          Utils.showSnackBar(
              message: responseModel.message ?? "", isTrue: true);
        } else {
          Utils.showSnackBar(
              message: responseModel.message ?? "Failed to delete notification",
              isTrue: false);
        }
      });
    });
  }

  void deleteAllMapSearch() {
    CustomLoader.show(Get.context!);
    _apiHelper
        .deleteAllMapSearch(userId: appController.user.value.userId)
        .then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(Get.context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(Get.context!, customError);
      }, (CommonResponseModel responseModel) {
        if (responseModel.status == 'success') {
          fetchSavedSearch();
          Utils.showSnackBar(
              message: responseModel.message ?? "", isTrue: true);
        } else {
          Utils.showSnackBar(
              message: responseModel.message ?? "Failed to delete notification",
              isTrue: false);
        }
      });
    });
  }
}
