import 'dart:async';
import 'dart:io';
import 'dart:math';
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
import '../../../../common/app_info/app_credentials.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/controller/location_controller.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_assets.dart';
import '../../../../common/values/my_strings.dart';
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

class NearbyEmployeeController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  Rx<Completer<GoogleMapController>> mapController =
      Rx<Completer<GoogleMapController>>(Completer());
  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();
  final currentRadius = 2.0.obs;
  final currentLocation = const LatLng(0, 0).obs;
  final selectedLocation = const LatLng(0, 0).obs;
  final selectedAddress = "".obs;
  final isLoading = true.obs;
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

  final showRadius = false.obs;

  Rx<Uint8List> locationIcon = Uint8List(1).obs;
  Rx<Uint8List> employeeLocationIcon = Uint8List(1).obs;

  // Add this property to store the original unfiltered data
  final allEmployees = Rx<Employees?>(null);

  final searchFocusNode = FocusNode();

  final isInitialDataLoading = true.obs;

  // Add these variables
  bool _isMapInitialized = false;
  GoogleMapController? _googleMapController;
  final isMapReady = false.obs;

  final isPermissionGiven = false.obs;

  // Add this variable to track if initial data is loaded
  final _isInitialDataLoaded = false.obs;

  // Add these variables
  final employeesInRadius = 0.obs;

  bool _isFirstInit = true;

  bool _wasInBackground = false;
  final isMapVisible = true.obs;

  @override
  Future<void> onInit() async {
    WidgetsBinding.instance.addObserver(this);
    print('NearbyEmployeeController.onInit');
    try {
      CustomLoader.show(Get.context!);

      // Initialize default location
      currentLocation.value =
          const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;

      // Load initial data in parallel
      await Future.wait([
        _loadMapStyle(),
        _loadMapIcons(),
        _getPositionWiseEmployees(),
        fetchSavedSearch(),
      ]);

      _shufflePositionList();
      // getAddressFromLatLng();
      await _initializeWithCurrentLocation();
      _isInitialDataLoaded.value = true;

      // Start location permission check after initial data is loaded
      await _startLocationPermissionCheck();

      // Force refresh after initial load
      await refreshMap();
    } catch (e) {
      debugPrint('Error in onInit: $e');
    } finally {
      CustomLoader.hide(Get.context!);
    }

    super.onInit();
  }

  void getAddressFromLatLng() {
    LocationController.getAddressFromLatLngForGoogle(
            lat: selectedLocation.value.latitude,
            lng: selectedLocation.value.longitude)
        .then((String responseData) {
      if (responseData.isNotEmpty) {
        selectedAddress.value = responseData;
      }
    });
  }

  Future<void> _initializeWithCurrentLocation() async {
    try {
      final permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.whileInUse ||
          permission == geo.LocationPermission.always) {
        final position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );

        currentLocation.value = LatLng(position.latitude, position.longitude);
        selectedLocation.value = currentLocation.value;

        // Get address from coordinates
        await _updateAddressFromCoordinates(
            position.latitude, position.longitude);
      } else {
        // If no permission, use default location and get its address
        await _updateAddressFromCoordinates(
          LocationController.mhLat,
          LocationController.mhLong,
        );
      }
    } catch (e) {
      debugPrint('Error getting initial location: $e');
      // If there's an error, use default location and get its address
      await _updateAddressFromCoordinates(
        LocationController.mhLat,
        LocationController.mhLong,
      );
    }
  }

  Future<void> _updateAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        // Build address string with available components
        // if (place.street?.isNotEmpty ?? false) address += place.street!;
        if (place.subLocality?.isNotEmpty ?? false) {
          if (address.isNotEmpty) address += ', ';
          address += place.subLocality!;
        }
        if (place.locality?.isNotEmpty ?? false) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.country?.isNotEmpty ?? false) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        // Update search controller and selected address
        searchQuery.value = "";
        searchController.text = "";
        selectedAddress.value = address;
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    try {
      _googleMapController = controller;
      mapController.value.complete(controller);
      customInfoWindowController.googleMapController = controller;

      if (mapStyle.value.isNotEmpty) {
        await _googleMapController?.setMapStyle(mapStyle.value);
      }

      _isMapInitialized = true;
      isMapReady.value = true;

      // If initial data is already loaded, refresh the map
      if (_isInitialDataLoaded.value) {
        await refreshMap();
      }
    } catch (e) {
      debugPrint('Error in onMapCreated: $e');
    } finally {
      isInitialDataLoading.value = false;
    }
  }

  // void onTabEnter() async {
  //   print('NearbyEmployeeController.onTabEnter 1');
  //   if (_googleMapController != null) {
  //     print('NearbyEmployeeController.onTabEnter');
  //     try {
  //       // Reinitialize the map controller
  //       await _googleMapController?.setMapStyle(mapStyle.value);
  //
  //       // Refresh location and markers
  //       if (currentLocation.value != const LatLng(0, 0)) {
  //         await _googleMapController?.animateCamera(
  //           CameraUpdate.newCameraPosition(
  //             CameraPosition(
  //               target: selectedLocation.value,
  //               // zoom: 15,
  //               zoom: log(100 * currentRadius.value) < 4
  //                   ? 17
  //                   : 17 - log(100 * currentRadius.value) + 0.5,
  //             ),
  //           ),
  //         );
  //       } else {
  //         _startLocationPermissionCheck();
  //       }
  //
  //       // Force refresh markers
  //       await updateMarkersOnly();
  //
  //       // Show info windows if any were visible
  //       customInfoWindowController.hideInfoWindow?.call();
  //     } catch (e) {
  //       debugPrint('Error in onTabEnter: $e');
  //       // If there's an error, try to recreate the map
  //       _recreateMap();
  //     }
  //   } else {
  //     // If controller is null, recreate the map
  //     _recreateMap();
  //   }
  // }

  void onTabEnter() async {
    print('NearbyEmployeeController.onTabEnter');
    try {
      // Show loading
      // isInitialDataLoading.value = true;
      CustomLoader.show(Get.context!);

      // If this is first init, skip (onInit will handle it)
      if (_isFirstInit) {
        _isFirstInit = false;
        return;
      }

      // Initialize everything again
      currentLocation.value =
          const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;

      // Load initial data in parallel
      await Future.wait([
        _loadMapStyle(),
        _loadMapIcons(),
        _getPositionWiseEmployees(),
        fetchSavedSearch(),
      ]);

      _shufflePositionList();
      await _initializeWithCurrentLocation();
      _isInitialDataLoaded.value = true;

      // Start location permission check
      await _startLocationPermissionCheck();

      // Force refresh
      await refreshMap();
    } catch (e) {
      debugPrint('Error in onTabEnter: $e');
    } finally {
      CustomLoader.hide(Get.context!);
      // isInitialDataLoading.value = false;
    }
  }

  void onTabExit() {
    try {
      // Clear all search-related data
      clearSearch();
      searchResults.clear();

      // Reset filter values
      selectedPosition.value = '';
      minRateController.text = '';
      maxRateController.text = '';

      // Reset map-related data
      markers.clear();
      currentRadius.value = 2.0;
      showRadius.value = false;
      isMapReady.value = false;
      _isMapInitialized = false;
      isInitialDataLoading.value = false;

      // Hide any open info windows
      customInfoWindowController.hideInfoWindow?.call();

      // Dispose of controllers
      _googleMapController?.dispose();
      _googleMapController = null;

      // Cancel any active subscriptions/timers
      _debounce?.cancel();
      _positionStreamSubscription?.cancel();

      // Clear the map controller completer
      mapController.value = Completer<GoogleMapController>();

      // Reset location data
      currentLocation.value = const LatLng(0, 0);
      selectedLocation.value = const LatLng(0, 0);
      selectedAddress.value = "";

      // Reset employee data
      employees.value = Employees();
      employeesInRadius.value = 0;

      update(['map_view']);
    } catch (e) {
      debugPrint('Error in onTabExit: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state: $state');
    switch (state) {
      case AppLifecycleState.paused:
        // App going to background
        _wasInBackground = true;
        isMapVisible.value = false;
        customInfoWindowController.hideInfoWindow?.call();
        break;

      case AppLifecycleState.resumed:
        // App coming back to foreground
        if (_wasInBackground&& !_isMapInitialized && isMapReady.isFalse) {
          _wasInBackground = false;
          onTabEnter();
        }
        break;

      case AppLifecycleState.inactive:
        isMapVisible.value = false;
        break;

      case AppLifecycleState.detached:
        isMapVisible.value = false;
        break;

      default:
        break;
    }
  }

  Future<void> _recreateMap() async {
    _isMapInitialized = false;
    isMapReady.value = false;
    isInitialDataLoading.value = true; // Show loading when recreating map
    _googleMapController?.dispose();
    _googleMapController = null;

    mapController.value = Completer<GoogleMapController>();
    markers.clear();
    _startLocationPermissionCheck();
    update();
  }

  // void onTabExit() {
  //   customInfoWindowController.hideInfoWindow?.call();
  //   _googleMapController?.dispose();
  //   _googleMapController = null;
  //   _isMapInitialized = false;
  //   isMapReady.value = false;
  // }

  Future<void> _loadMapStyle() async {
    try {
      final style = await rootBundle.loadString(MyAssets.nearbyMapStyle);
      mapStyle.value = style;
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  Future<void> _loadMapIcons() async {
    final locationIconFuture = LocationController.getBytesFromAsset(
        MyAssets.locationPin, Platform.isAndroid ? 80 : 85);

    final employeeLocationIconFuture = LocationController.getBytesFromAsset(
        MyAssets.employeeLocationPin, Platform.isAndroid ? 80 : 85);

    final icons = await Future.wait([
      locationIconFuture,
      employeeLocationIconFuture,
    ]);

    locationIcon.value = icons[0];
    employeeLocationIcon.value = icons[1];
  }

  void onSearchChanged(String query) {
    showRadius.value = false;

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
          '&key=${AppCredentials.googleMapKey}';

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
    searchFocusNode.unfocus();
    searchController.text = '${place.mainText}, ${place.secondaryText}';
    searchResults.clear();
    isInitialDataLoading.value = true;
    isPermissionGiven.value = true;

    try {
      // Get place details to get coordinates
      final locationResults = await locationFromAddress(
        '${place.mainText}, ${place.secondaryText}',
      );

      if (locationResults.isNotEmpty) {
        final location = locationResults.first;
        selectedLocation.value = LatLng(location.latitude, location.longitude);
        selectedAddress.value = '${place.mainText}, ${place.secondaryText}';

        // First update user location marker immediately
        final newMarkers = <Marker>{};

        // Add user location marker
        if (locationIcon.value.isNotEmpty) {
          newMarkers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: selectedLocation.value,
              icon: BitmapDescriptor.fromBytes(locationIcon.value),
              infoWindow: const InfoWindow(title: 'Selected Location'),
            ),
          );
        }

        // Keep existing professional markers
        newMarkers.addAll(markers
            .where((marker) => marker.markerId.value != 'user_location'));

        // Update markers
        markers.assignAll(newMarkers);
        markers.refresh();

        // Animate camera to new location
        final controller = await mapController.value.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedLocation.value,
              // zoom: 11,
              zoom: log(100 * currentRadius.value) < 4
                  ? 17
                  : 17 - log(100 * currentRadius.value),
            ),
          ),
        );

        // Then update all markers
        await updateMarkersOnly();
      }
    } catch (e) {
      debugPrint('Error selecting place: $e');
      Utils.showSnackBar(
        message: "Error selecting location. Please try again.",
        isTrue: false,
      );
    } finally {
      isInitialDataLoading.value = false;
    }
  }

  Future<void> updateMarkersOnly() async {
    if (!_isMapInitialized) return;
    if (selectedLocation.value == const LatLng(0, 0)) return;

    final newMarkers = <Marker>{};
    int countInRadius = 0; // Counter for employees within radius

    // Add user location marker first (but don't count it)
    if (locationIcon.value.isNotEmpty) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: selectedLocation.value,
          icon: BitmapDescriptor.fromBytes(locationIcon.value),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add all employee markers and count those within radius
    if (employeeLocationIcon.value.isNotEmpty) {
      for (var employee in employees.value.users ?? []) {
        try {
          // Skip if employee data is invalid
          if (employee.lat == null || employee.long == null) continue;

          final position = LatLng(double.parse(employee.lat ?? "0"),
              double.parse(employee.long ?? "0"));

          // Calculate distance
          double distanceInMeters =
              calculateDistance(selectedLocation.value, position);
          double distanceInKilometers = distanceInMeters / 1000;

          // Count employees within the radius
          if (distanceInKilometers <= currentRadius.value) {
            countInRadius++; // Increment counter only for employees within radius
          }

          // Add marker for all employees regardless of radius
          newMarkers.add(
            Marker(
              markerId: MarkerId('professional_${employee.id}'),
              position: position,
              icon: BitmapDescriptor.fromBytes(employeeLocationIcon.value),
              onTap: () {
                customInfoWindowController.addInfoWindow!(
                  CustomMarkerInfoWindow(
                    employeeId: employee.id,
                    image: employee.profilePicture ?? "",
                    name:
                        "${employee.firstName ?? ""} ${employee.lastName ?? ""}",
                    position: employee.positionName ?? "",
                    experience: "${employee.employeeExperience ?? 0}",
                    distance: distanceInKilometers.toStringAsFixed(2),
                    countryName: employee.countryName ?? "",
                    rate: employee.hourlyRate ?? 0,
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

    // Update the observable counter (now only includes employees within radius)
    employeesInRadius.value = countInRadius;

    markers.assignAll(newMarkers);
    markers.refresh();
  }

  double calculateDistance(LatLng start, LatLng end) {
    return geo.Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
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

  Future<void> _startLocationPermissionCheck() async {
    try {
      // First check if we already have permission
      geo.LocationPermission currentPermission =
          await geo.Geolocator.checkPermission();
      if (currentPermission == geo.LocationPermission.whileInUse ||
          currentPermission == geo.LocationPermission.always) {
        await _handleLocationPermissionGranted();
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool shouldContinue = await _showLocationServicesDialog();
        if (!shouldContinue) return;
        // Recheck service status after returning from settings
        serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return;
      }

      // Request permission if not already granted
      currentPermission = await geo.Geolocator.checkPermission();
      if (currentPermission == geo.LocationPermission.denied) {
        currentPermission = await geo.Geolocator.requestPermission();
        if (currentPermission == geo.LocationPermission.denied) {
          bool shouldContinue = await _showPermissionDeniedDialog();
          if (!shouldContinue) return;
        }
      }

      if (currentPermission == geo.LocationPermission.deniedForever) {
        bool shouldContinue = await _showPermissionPermanentlyDeniedDialog();
        if (!shouldContinue) return;
      }

      // Final permission check
      currentPermission = await geo.Geolocator.checkPermission();
      if (currentPermission == geo.LocationPermission.whileInUse ||
          currentPermission == geo.LocationPermission.always) {
        await _handleLocationPermissionGranted();
      }
    } catch (e) {
      debugPrint('Error in permission check: $e');
      currentLocation.value =
          const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;
    }
  }

  Future<void> _handleLocationPermissionGranted() async {
    print('NearbyEmployeeController._handleLocationPermissionGranted');
    isPermissionGiven.value = true;

    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentLocation.value;

      if (_isMapInitialized && _googleMapController != null) {
        _googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedLocation.value,
              // zoom: 15,
              zoom: log(100 * currentRadius.value) < 4
                  ? 17
                  : 17 - log(100 * currentRadius.value),
            ),
          ),
        );
        await updateMarkersOnly();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      currentLocation.value =
          const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;
    }
  }

  Future<bool> _showLocationServicesDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(MyStrings.locationServicesDisabled.tr),
        content:
            const Text("Please enable location services to use map features"),
        actions: [
          // TextButton(
          //   child: Text(MyStrings.cancel.tr),
          //   onPressed: () => Get.back(result: false),
          // ),
          TextButton(
            child: Text(MyStrings.settings.tr),
            onPressed: () async {
              Get.back(result: true);
              await geo.Geolocator.openLocationSettings();
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;

      // Get last known position first for quick display
      final lastPosition = await geo.Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        currentLocation.value =
            LatLng(lastPosition.latitude, lastPosition.longitude);
        selectedLocation.value = currentLocation.value;

        if (_googleMapController != null) {
          await _googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: selectedLocation.value,
                zoom: 15,
              ),
            ),
          );
          _updateUserLocationMarker();
        }
      }

      // Get current position
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentLocation.value;

      if (_googleMapController != null) {
        await _googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedLocation.value,
              zoom: 15,
            ),
          ),
        );
      }

      await updateMarkersOnly();
      await _getPositionWiseEmployees();
    } catch (e) {
      debugPrint('Error initializing location: $e');
      // Set default location if there's an error
      currentLocation.value =
          const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to update user location marker
  void _updateUserLocationMarker() {
    if (locationIcon.value.isEmpty) return;

    markers.assign(Marker(
      markerId: const MarkerId('user_location'),
      position: currentLocation.value,
      icon: BitmapDescriptor.fromBytes(locationIcon.value),
      infoWindow: const InfoWindow(title: 'Your Location'),
    ));

    markers.refresh();
  }

  void onRadiusChanged(double value) async {
    try {
      currentRadius.value = value;
      showRadius.value = true;

      // Get appropriate zoom level based on radius
      double zoomLevel;
      if (value <= 0.5) {
        zoomLevel = 15.0;
      } else if (value <= 1) {
        zoomLevel = 14.5;
      } else if (value <= 2) {
        zoomLevel = 14.0;
      } else if (value <= 5) {
        zoomLevel = 13.0;
      } else if (value <= 10) {
        zoomLevel = 12.0;
      } else if (value <= 20) {
        zoomLevel = 11.0;
      } else if (value <= 30) {
        zoomLevel = 10.0;
      } else if (value <= 40) {
        zoomLevel = 9.5;
      } else {
        zoomLevel = 9.0; // For radius 40-50km
      }
      // if (value <= 0.5) {
      //   zoomLevel = 15.0;
      // } else if (value <= 1) {
      //   zoomLevel = 14.5;
      // } else if (value <= 2) {
      //   zoomLevel = 14.0;
      // } else if (value <= 3) {
      //   zoomLevel = 13.5;
      // } else if (value <= 4) {
      //   zoomLevel = 13.0;
      // } else if (value <= 5) {
      //   zoomLevel = 12.5;
      // } else if (value <= 7) {
      //   zoomLevel = 12.0;
      // } else if (value <= 8) {
      //   zoomLevel = 11.5;
      // } else {
      //   zoomLevel = 11.0;
      // }

      // Create new marker set
      final newMarkers = <Marker>{};

      // Add user location marker
      if (locationIcon.value.isNotEmpty) {
        newMarkers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: selectedLocation.value,
            icon: BitmapDescriptor.fromBytes(locationIcon.value),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      }

      // Update markers collection
      markers.assignAll(newMarkers);
      markers.refresh();

      // Update camera position with new zoom level
      if (_isMapInitialized && _googleMapController != null) {
        await _googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedLocation.value,
              zoom: zoomLevel,
            ),
          ),
        );
      }

      // Force refresh of markers and circles
      await updateMarkersOnly();
      update(['map_view']);
    } catch (e) {
      debugPrint('Error updating radius: $e');
    }
  }

  Future<void> _getPositionWiseEmployees() async {
    try {
      final response = await _apiHelper.getAllEmployees();

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (Employees employeesData) async {
        employees.value = employeesData;
        employees.refresh();
        await updateMarkersOnly();
      });
    } catch (e) {
      debugPrint('Error getting employees: $e');
    }
  }

  bool _isDuplicateSearch(String lat, String long, String? positionId,
      String? minRate, String? maxRate, String? radius) {
    return savedSearchList.any((search) =>
        search.lat.toString() == lat &&
        search.lng.toString() == long &&
        search.position?.id == positionId &&
        search.minHourlyRate.toString() == minRate &&
        search.maxHourlyRate.toString() == maxRate &&
        search.radius.toString() == radius);
  }

  void mapSearch() {
    final lat = selectedLocation.value.latitude != 0
        ? selectedLocation.value.latitude.toString()
        : currentLocation.value.latitude.toString();
    final long = selectedLocation.value.longitude != 0
        ? selectedLocation.value.longitude.toString()
        : currentLocation.value.longitude.toString();
    final minRate = minRateController.text.trim();
    final maxRate = maxRateController.text.trim();
    final positionId = selectedPosition.value;
    final radius = (currentRadius.value * 1000).toString();

    // Check for duplicate search
    if (_isDuplicateSearch(lat, long, positionId, minRate, maxRate, radius)) {
      Utils.showSnackBar(
        message: "A search with these criteria already exists",
        isTrue: false,
      );
      return;
    }

    if (employees.value.users == null || employees.value.users!.isEmpty) {
      Utils.showSnackBar(
        message: "You have to search before saving it",
        isTrue: false,
      );
      return;
    }

    CustomLoader.show(Get.context!);
    _apiHelper
        .mapSearch(
            address: selectedAddress.value,
            lat: lat,
            lang: long,
            totalCount: employeesInRadius.value.toString(),
            minRate: minRate,
            maxRate: maxRate,
            positionId: positionId,
            radius: radius)
        .then((Either<CustomError, MapSearchResponseModel> responseData) {
      CustomLoader.hide(Get.context!);
      responseData.fold((CustomError customError) {},
          (MapSearchResponseModel r) {
        if (r.status == "success" && r.statusCode == 201 && r.details != null) {
          Utils.showSnackBar(message: r.message ?? "", isTrue: true);
          fetchSavedSearch();
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

  void mapFilter() {
    try {
      isInitialDataLoading.value = true;

      // If allEmployees is not set, store the current employees as the full list
      allEmployees.value ??= employees.value;

      // Get and validate filter values
      final selectedPositionId = selectedPosition.value;
      final minRate = double.tryParse(minRateController.text.trim());
      final maxRate = double.tryParse(maxRateController.text.trim());

      // Filter from allEmployees instead of employees
      final filteredEmployees = allEmployees.value?.users?.where((employee) {
        final employeeRate =
            double.tryParse(employee.hourlyRate?.toString() ?? '0') ?? 0;

        // Position filter
        if (selectedPositionId.isNotEmpty &&
            employee.positionId != selectedPositionId) {
          return false;
        }

        // Rate filter - only apply if both min and max are provided
        if (minRate != null && maxRate != null && maxRate > 0) {
          return employeeRate >= minRate && employeeRate <= maxRate;
        } else if (minRate != null) {
          return employeeRate >= minRate;
        } else if (maxRate != null) {
          return employeeRate <= maxRate;
        }

        return true; // Include if no filters are applied
      }).toList();

      // Update the displayed employees list
      if (filteredEmployees != null) {
        employees.value = Employees(users: filteredEmployees);
        employees.refresh();

        // Immediately update markers with filtered data
        updateMarkersOnly();
      }

      Get.back(); // Close filter dialog
    } catch (e) {
      debugPrint('Error applying filters: $e');
      Utils.showSnackBar(
        message: "Error applying filters. Please check your inputs.",
        isTrue: false,
      );
    } finally {
      isInitialDataLoading.value = false;
    }
  }

  Future<bool> _showPermissionDeniedDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text(
            "Please enable location permission to use map features. You can enable it in Settings."),
        actions: [
          // TextButton(
          //   child: Text(MyStrings.cancel.tr),
          //   onPressed: () => Get.back(result: false),
          // ),
          TextButton(
            child: Text(MyStrings.settings.tr),
            onPressed: () async {
              Get.back(result: true);
              if (Platform.isIOS) {
                await openAppSettings();
              } else {
                await geo.Geolocator.openAppSettings();
              }
              // Let the app lifecycle handle permission changes
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  Future<bool> _showPermissionPermanentlyDeniedDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text(
            "Location permission is permanently denied. Please enable it from Settings to use map features."),
        actions: [
          // TextButton(
          //   child: Text(MyStrings.cancel.tr),
          //   onPressed: () => Get.back(result: false),
          // ),
          TextButton(
            child: Text(MyStrings.settings.tr),
            onPressed: () async {
              Get.back(result: true);
              if (Platform.isIOS) {
                await openAppSettings();
              } else {
                await geo.Geolocator.openAppSettings();
              }
              // Let the app lifecycle handle permission changes
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  // Add this method to refresh the map programmatically
  Future<void> refreshMap() async {
    if (!_isMapInitialized || _googleMapController == null) return;

    try {
      // Clear existing markers
      markers.clear();

      // Ensure we have the latest employee data
      await _getPositionWiseEmployees();

      // Move camera to current location with proper zoom
      await _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: selectedLocation.value,
            zoom: 15,
            // zoom: log(100 * currentRadius.value) < 4 ? 17 : 17 - log(100 * currentRadius.value),
          ),
        ),
      );

      // Force update all markers
      await updateMarkersOnly();

      // Trigger a rebuild
      update(['map_view']);
    } catch (e) {
      debugPrint('Error refreshing map: $e');
    }
  }

  void centerOnUserLocation() async {
    if (isPermissionGiven.isTrue) {
      try {
        isInitialDataLoading.value = true; // Show loading state

        // Get current position
        final position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );

        // Update current location
        currentLocation.value = LatLng(position.latitude, position.longitude);
        selectedLocation.value = currentLocation.value;

        // Use the helper method to update address
        await _updateAddressFromCoordinates(
            position.latitude, position.longitude);

        // Create new marker set to avoid mutation issues
        final newMarkers = <Marker>{};

        // Add user location marker
        if (locationIcon.value.isNotEmpty) {
          newMarkers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: currentLocation.value,
              icon: BitmapDescriptor.fromBytes(locationIcon.value),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
        }

        // Keep existing professional markers
        newMarkers.addAll(markers
            .where((marker) => marker.markerId.value != 'user_location'));

        // Update markers collection
        markers.assignAll(newMarkers);
        markers.refresh();

        // Animate camera to new location
        if (_isMapInitialized && _googleMapController != null) {
          await _googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation.value,
                zoom: log(100 * currentRadius.value) < 4
                    ? 17
                    : 17 - log(100 * currentRadius.value),
              ),
            ),
          );
        }

        // Update all markers with professionals
        await updateMarkersOnly();
      } catch (e) {
        debugPrint('Error getting current location: $e');
        Utils.showSnackBar(
          message: "Could not get current location. Please try again.",
          isTrue: false,
        );
      } finally {
        isInitialDataLoading.value = false; // Hide loading state
      }
    } else {
      await _startLocationPermissionCheck();
    }
  }

  // Add this method to check if an employee is within radius
  bool isWithinRadius(LatLng employeePosition) {
    double distance =
        calculateDistance(selectedLocation.value, employeePosition);
    // Convert radius from km to meters for comparison
    return distance <= (currentRadius.value * 1000);
  }

  void onSavedSearchSelected(SavedSearchModel search) async {
    try {
      // Close the dialog
      Get.back();

      isInitialDataLoading.value = true;

      // Update selected location and address
      selectedLocation.value = LatLng(search.lat ?? 0, search.lng ?? 0
          // double.parse(search.lat ?? "0"),
          // double.parse(search.lng ?? "0")
          );
      selectedAddress.value = search.address ?? "";
      searchController.text = search.address ?? "";

      // Update position if available
      if (search.position?.id != null) {
        selectedPosition.value = search.position!.id!;
      }

      // Update rate filters if available
      minRateController.text = search.minHourlyRate?.toString() ?? "";
      maxRateController.text = search.maxHourlyRate?.toString() ?? "";

      // First update user location marker immediately
      final newMarkers = <Marker>{};

      // Add user location marker
      if (locationIcon.value.isNotEmpty) {
        newMarkers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: selectedLocation.value,
            icon: BitmapDescriptor.fromBytes(locationIcon.value),
            infoWindow: const InfoWindow(title: 'Selected Location'),
          ),
        );
      }

      // Update markers
      markers.assignAll(newMarkers);
      markers.refresh();

      // Update radius using existing method
      if (search.radius != null && search.radius! > 0) {
        onRadiusChanged(search.radius! / 1000);
      } else {
        onRadiusChanged(2.0); // default radius
      }

      // Apply filters and update markers
      mapFilter();
      await updateMarkersOnly();
    } catch (e) {
      debugPrint('Error selecting saved search: $e');
      Utils.showSnackBar(
        message: "Error loading saved search. Please try again.",
        isTrue: false,
      );
    } finally {
      isInitialDataLoading.value = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _googleMapController?.dispose();
    customInfoWindowController.dispose();
    _debounce?.cancel();
    searchController.dispose();
    _positionStreamSubscription?.cancel();
    searchFocusNode.dispose();
    super.onClose();
  }
}
