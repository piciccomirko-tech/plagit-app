import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/map/restaurant_location/models/google_auto_complete_search_model.dart';
import 'package:mh/app/modules/map/restaurant_location/models/lat_lng_model.dart';

import '../../../../common/controller/location_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../auth/register/controllers/register_controller.dart';
import '../../../client/client_self_profile/controllers/client_self_profile_controller.dart';

class RestaurantLocationController extends GetxController {
  BuildContext? context;

  // current location
  Position? location;

  Set<Marker> markersList = {};

  GoogleMapController? mapController;

  RxBool mapLoaded = false.obs;
  RxString locationFetchError = "".obs;

  RxBool showAutoCompleteSearchWidget = false.obs;

  /// default mh lat long
  Rx<LatLng> latLng = const LatLng(
    LocationController.mhLat,
    LocationController.mhLong,
  ).obs;

  RxList<GoogleAutoCompleteSearchModel> googleAutoCompleteSearchList = <GoogleAutoCompleteSearchModel>[].obs;
  RxBool autoCompleteDataLoaded = false.obs;
  RxString locationText = ''.obs;
  RxBool confirmButtonDisable = false.obs;
  Timer? _debounce;

  TextEditingController tecAutoCompleteSearch = TextEditingController();
  RxString autoCompleteSearchQuery = ''.obs;
  Rx<Uint8List> locationIcon = Uint8List(1).obs;
  bool goToOnMapIdle = true;

  @override
  void onInit() {
    LocationController.getBytesFromAsset(MyAssets.locationPin, Platform.isAndroid ? 80 : 85).then((Uint8List val) {
      locationIcon.value = val;
      _getCurrentLocation();
    });
    super.onInit();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    mapController?.dispose();
    tecAutoCompleteSearch.dispose();
    super.onClose();
  }

  void onAddressSearch(String query) {
    autoCompleteSearchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        LocationController.autoCompleteSearchForGoogle(input: query)
            .then((List<GoogleAutoCompleteSearchModel> responseData) {
          googleAutoCompleteSearchList.value = responseData;
          autoCompleteDataLoaded.value = true;
        });
      } else {
        googleAutoCompleteSearchList.clear();
      }
    });
  }

  void onConfirmPressed() {
    if (Get.isRegistered<RegisterController>()) {
      final RegisterController registerController = Get.find();

      registerController.restaurantLat = latLng.value.latitude;
      registerController.restaurantLong = latLng.value.longitude;
      registerController.restaurantAddressFromMap.value = locationText.value.trim();
      registerController.tecClientAddress.text = locationText.value.trim();
    } else if (Get.isRegistered<ClientSelfProfileController>()) {
      final ClientSelfProfileController profileController = Get.find();

      profileController.restaurantLat = latLng.value.latitude;
      profileController.restaurantLong = latLng.value.longitude;
      profileController.restaurantAddressFromMap.value = locationText.value.trim();
      profileController.tecRestaurantAddress.text = locationText.value.trim();
    }

    Get.back();
  }

  void onCameraMove(CameraPosition position) {
    confirmButtonDisable.value = true;
    latLng.value = position.target;
    latLng.refresh();
    loadMarker(latLng: latLng.value);
  }

  void onMapTap(LatLng l) {
    latLng.value = l;
    latLng.refresh();
    loadMarker(latLng: latLng.value);
    getAddressFromLatLng();
  }

  void onCameraIdle() {
    confirmButtonDisable.value = false;
    if (goToOnMapIdle == true) {
      locationText.value = "Fetching address...";
      getAddressFromLatLng();
    }
  }

  void _getCurrentLocation() {
    LocationController.determinePosition().then((Either<CustomError, Position> value) {
      value.fold((CustomError l) {
        locationFetchError.value = l.msg;
      }, (Position position) {
        location = position;
        latLng.value = LatLng(location!.latitude, location!.longitude);
        loadMarker(latLng: latLng.value);
        getAddressFromLatLng();
      });
    });
  }

  void onSearchLocationClick() {
    showAutoCompleteSearchWidget.value = !showAutoCompleteSearchWidget.value;
  }

  void onAddressClick({required String addressText}) {
    getLatLngFromAddress(addressText: addressText);
  }

  void onClearClick() {
    autoCompleteSearchQuery.value = '';
    tecAutoCompleteSearch.clear();
    googleAutoCompleteSearchList.clear();
  }

  void loadMarker({required LatLng latLng}) {
    markersList.add(
      Marker(
        infoWindow: const InfoWindow(title: "Welcome Back!", snippet: 'Move this marker to your desired location'),
        icon: BitmapDescriptor.fromBytes(locationIcon.value),
        markerId: const MarkerId('0'),
        position: latLng,
      ),
    );
  }

  void onMapCreated(GoogleMapController c) async {
    String value = await DefaultAssetBundle.of(Get.context!).loadString(MyAssets.customMapStyle);
    mapController = c;
    mapController?.setMapStyle(value);
  }

  void getAddressFromLatLng() {
    LocationController.getAddressFromLatLngForGoogle(lat: latLng.value.latitude, lng: latLng.value.longitude)
        .then((String responseData) {
      if (responseData.isNotEmpty) {
        locationText.value = responseData;
        mapLoaded.value = true;
      }
    });
  }

  void getLatLngFromAddress({required String addressText}) {
    Utils.unFocus();
    goToOnMapIdle = false;
    LocationController.getLatLngFromAddressForGoogle(address: addressText).then((LatLngModel? responseData) {
      if (responseData != null) {
        latLng.value = LatLng(responseData.lat!, responseData.lng!);

        final CameraPosition newCameraPosition = CameraPosition(
          target: LatLng(latLng.value.latitude, latLng.value.longitude),
          zoom: 17.50,
        );
        mapController?.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
        loadMarker(latLng: latLng.value);
        locationText.value = addressText;
        onClearClick();
      }
    });
  }
}
