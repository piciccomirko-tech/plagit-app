import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:http/http.dart' as http;
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

class NearbyCandidatesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  Rx<Completer<GoogleMapController>> mapController =
  Rx<Completer<GoogleMapController>>(Completer());
  final CustomInfoWindowController customInfoWindowController =
  CustomInfoWindowController();
  final currentRadius = 0.5.obs;
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

  @override
  Future<void> onInit() async {
    try {
      // Load all data first
      await Future.wait([
        _loadMapStyle(),
        _loadMapIcons(),
      ]);

      CustomLoader.show(Get.context!);
      await _startLocationPermissionCheck();
      // Set initial default location to prevent grey map
      currentLocation.value = const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;



      _shufflePositionList();
      await _getPositionWiseEmployees();
      await fetchSavedSearch();

      CustomLoader.hide(Get.context!);

      // Start permission check after data is loaded

    } catch (e) {
      CustomLoader.hide(Get.context!);
      debugPrint('Error in onInit: $e');
    }

    super.onInit();
  }

  void onMapCreated(GoogleMapController controller) async {
    try {
      _googleMapController = controller;
      mapController.value.complete(controller);
      customInfoWindowController.googleMapController = controller;

      if (mapStyle.value.isNotEmpty) {
        _googleMapController?.setMapStyle(mapStyle.value);
      }

      _isMapInitialized = true;
      isMapReady.value = true;

      // Move camera to current location
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation.value,
            zoom: 15,
          ),
        ),
      );

      // Update markers if we have any
      if (employees.value.users?.isNotEmpty ?? false) {
        await updateMarkersOnly();
      }
    } catch (e) {
      debugPrint('Error in onMapCreated: $e');
    } finally {
      isInitialDataLoading.value = false;
    }
  }

  void onTabEnter() async {
    if (_googleMapController != null) {
      try {
        // Reinitialize the map controller
        await _googleMapController?.setMapStyle(mapStyle.value);

        // Refresh location and markers
        if (currentLocation.value != const LatLng(0, 0)) {
          await _googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation.value,
                zoom: 15,
              ),
            ),
          );
        }

        // Force refresh markers
        await updateMarkersOnly();

        // Show info windows if any were visible
        customInfoWindowController.hideInfoWindow?.call();
      } catch (e) {
        debugPrint('Error in onTabEnter: $e');
        // If there's an error, try to recreate the map
        _recreateMap();
      }
    } else {
      // If controller is null, recreate the map
      _recreateMap();
    }
  }

  void _recreateMap() {
    _isMapInitialized = false;
    isMapReady.value = false;
    isInitialDataLoading.value = true; // Show loading when recreating map
    _googleMapController?.dispose();
    _googleMapController = null;

    mapController.value = Completer<GoogleMapController>();
    markers.clear();

    update();
  }

  void onTabExit() {
    customInfoWindowController.hideInfoWindow?.call();
    _googleMapController?.dispose();
    _googleMapController = null;
    _isMapInitialized = false;
    isMapReady.value = false;
  }

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
    showRadius.value=false;

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
    clearSearch();
    isInitialDataLoading.value = true;
    isPermissionGiven.value=true;

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
              zoom: 11,
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

    // Add professional markers
    if (employeeLocationIcon.value.isNotEmpty) {
      for (var employee in employees.value.users ?? []) {
        try {
          final position = LatLng(double.parse(employee.lat ?? "0"),
              double.parse(employee.long ?? "0"));

          newMarkers.add(
            Marker(
              markerId: MarkerId('professional_${employee.id}'),
              position: position,
              icon: BitmapDescriptor.fromBytes(employeeLocationIcon.value),
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

    markers.assignAll(newMarkers);
    markers.refresh();
  }


  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  Future<void> _startLocationPermissionCheck() async {
    try {
      // First check if we already have permission
      geo.LocationPermission currentPermission = await geo.Geolocator.checkPermission();
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
      currentLocation.value = const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;
    }
  }

  Future<void> _handleLocationPermissionGranted() async {
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
              target: currentLocation.value,
              zoom: 15,
            ),
          ),
        );
        await updateMarkersOnly();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      currentLocation.value = const LatLng(LocationController.mhLat, LocationController.mhLong);
      selectedLocation.value = currentLocation.value;
    }
  }

  Future<bool> _showLocationServicesDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(MyStrings.locationServicesDisabled.tr),
        content: const Text("Please enable location services to use map features"),
        actions: [
          TextButton(
            child: Text(MyStrings.cancel.tr),
            onPressed: () => Get.back(result: false),
          ),
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
                target: currentLocation.value,
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
              target: currentLocation.value,
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
    if (mapController.value.isCompleted) {
      final controller = await mapController.value.future;
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

  Future<void> _getPositionWiseEmployees() async {
    try {
      final response = await _apiHelper.getAllEmployees();

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (Employees employeesData) {
        employees.value = employeesData;
        employees.refresh();
        updateMarkersOnly();
      });
    } catch (e) {
      debugPrint('Error getting employees: $e');
    }
  }

  bool _isDuplicateSearch(String lat, String long, String? positionId,
      String? minRate, String? maxRate) {
    return savedSearchList.any((search) =>
    search.lat.toString() == lat &&
        search.lng.toString() == long &&
        search.position?.id == positionId &&
        search.minHourlyRate.toString() == minRate &&
        search.maxHourlyRate.toString() == maxRate);
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

    // Check for duplicate search
    if (_isDuplicateSearch(lat, long, positionId, minRate, maxRate)) {
      Utils.showSnackBar(
        message: "A search with these criteria already exists",
        isTrue: false,
      );
      return;
    }

    if(employees.value.users==null||employees.value.users!.isEmpty)
    {
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
        totalCount: employees.value.users!.length.toString(),
        minRate: minRate,
        maxRate: maxRate,
        positionId: positionId,radius: currentRadius.value.toString())
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
        if (minRate != null && maxRate != null) {
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

  // Future<void> _startLocationPermissionCheck() async {
  //   while (true) {
  //     bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       await Get.dialog(
  //         WillPopScope(
  //           onWillPop: () async => false,
  //           child: AlertDialog(
  //             title: Text(MyStrings.locationServicesDisabled.tr),
  //             content: const Text("Please enable location services to use map features"),
  //             actions: [
  //               TextButton(
  //                 child: Text(MyStrings.settings.tr),
  //                 onPressed: () async {
  //                   Get.back();
  //                   await geo.Geolocator.openLocationSettings();
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         barrierDismissible: false,
  //       );
  //       await Future.delayed(const Duration(seconds: 1));
  //       continue;
  //     }
  //
  //     geo.LocationPermission permission = await geo.Geolocator.checkPermission();
  //
  //     if (permission == geo.LocationPermission.denied) {
  //       permission = await geo.Geolocator.requestPermission();
  //
  //       if (permission == geo.LocationPermission.denied) {
  //         await Get.dialog(
  //           WillPopScope(
  //             onWillPop: () async => false,
  //             child: AlertDialog(
  //               title: const Text("Location Permission Required"),
  //               content: const Text("Please enable location permission to use map features"),
  //               actions: [
  //                 TextButton(
  //                   child: Text(MyStrings.settings.tr),
  //                   onPressed: () async {
  //                     Get.back();
  //                     if (Platform.isIOS) {
  //                       await openAppSettings();
  //                     } else {
  //                       await geo.Geolocator.openAppSettings();
  //                     }
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //           barrierDismissible: false,
  //         );
  //         await Future.delayed(const Duration(seconds: 1));
  //         continue;
  //       }
  //     }
  //
  //     if (permission == geo.LocationPermission.deniedForever) {
  //       await Get.dialog(
  //         WillPopScope(
  //           onWillPop: () async => false,
  //           child: AlertDialog(
  //             title: const Text("Location Permission Required"),
  //             content: const Text("Location permission is permanently denied. Please enable it from settings."),
  //             actions: [
  //               TextButton(
  //                 child: Text(MyStrings.settings.tr),
  //                 onPressed: () async {
  //                   Get.back();
  //                   if (Platform.isIOS) {
  //                     await openAppSettings();
  //                   } else {
  //                     await geo.Geolocator.openAppSettings();
  //                   }
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         barrierDismissible: false,
  //       );
  //       await Future.delayed(const Duration(seconds: 1));
  //       continue;
  //     }
  //
  //     try {
  //       final position = await geo.Geolocator.getCurrentPosition(
  //         desiredAccuracy: geo.LocationAccuracy.high,
  //         timeLimit: const Duration(seconds: 5),
  //       );
  //
  //       currentLocation.value = LatLng(position.latitude, position.longitude);
  //       selectedLocation.value = currentLocation.value;
  //
  //       if (_isMapInitialized && _googleMapController != null) {
  //         await _googleMapController?.animateCamera(
  //           CameraUpdate.newCameraPosition(
  //             CameraPosition(
  //               target: currentLocation.value,
  //               zoom: 15,
  //             ),
  //           ),
  //         );
  //         await updateMarkersOnly();
  //       }
  //       break;
  //     } catch (e) {
  //       debugPrint('Error getting position: $e');
  //       await Future.delayed(const Duration(seconds: 1));
  //     }
  //   }
  // }

  Future<bool> _showPermissionDeniedDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text("Please enable location permission to use map features. You can enable it in Settings."),
        actions: [
          TextButton(
            child: Text(MyStrings.cancel.tr),
            onPressed: () => Get.back(result: false),
          ),
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
        content: const Text("Location permission is permanently denied. Please enable it from Settings to use map features."),
        actions: [
          TextButton(
            child: Text(MyStrings.cancel.tr),
            onPressed: () => Get.back(result: false),
          ),
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

  @override
  void onClose() {
    _googleMapController?.dispose();
    customInfoWindowController.dispose();
    _debounce?.cancel();
    searchController.dispose();
    _positionStreamSubscription?.cancel();
    searchFocusNode.dispose();
    super.onClose();
  }
}
