import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mh/app/common/app_info/app_credentials.dart';
import 'package:mh/app/modules/map/restaurant_location/models/google_auto_complete_search_model.dart';
import 'package:mh/app/modules/map/restaurant_location/models/lat_lng_model.dart';
import '../../enums/error_from.dart';
import '../../models/custom_error.dart';
import '../utils/type_def.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class LocationController {
  static const String address = "48 Warwick St Regent Street W1B 5AW London";
  static const double mhLat = 51.510680;
  static const double mhLong = -0.137810;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static EitherModel<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return left(CustomError(
        errorCode: 1002,
        errorFrom: ErrorFrom.location,
        msg: "Location services are disabled",
      ));
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        return left(CustomError(
          errorCode: 1002,
          errorFrom: ErrorFrom.location,
          msg: "Location permissions are denied",
        ));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return left(CustomError(
        errorCode: 1002,
        errorFrom: ErrorFrom.location,
        msg: "Location permissions are permanently denied, we cannot request permissions",
      ));
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return right(position);
  }

  static double calculateDistance({
    required double targetLat,
    required double targetLong,
    required double currentLat,
    required double currentLong,
  }) =>
      Geolocator.distanceBetween(
        currentLat,
        currentLong,
        targetLat,
        targetLong,
      );

/*  static Future<GeoData> getAddressFromLatLong({
    required double lat,
    required double long,
  }) async {
    GeoData data = await Geocoder2.getDataFromCoordinates(
      latitude: lat,
      longitude: long,
      googleMapApiKey: AppCredentials.googleMapKey,
    );

    return data;
  }

  static Future<GeoData> getLatLongFromAddress({
    required String address,
  }) async {
    GeoData data = await Geocoder2.getDataFromAddress(
      address: address,
      googleMapApiKey: AppCredentials.googleMapKey,
    );

    return data;
  }

  static Future<GBData> getAddressFromLatLongFree({
    required double lat,
    required double long,
  }) async =>
      await GeocoderBuddy.findDetails(GBLatLng(
        lat: lat,
        lng: long,
      ));

  static Future<GBData> getLatLongFromAddressFree({
    required String address,
  }) async {
    List<GBSearchData> data = await GeocoderBuddy.query(address);
    return await GeocoderBuddy.searchToGBData(data.first);
  }*/

  static Future<List<GoogleAutoCompleteSearchModel>> autoCompleteSearchForGoogle({required String input}) async {
    try {
      List<GoogleAutoCompleteSearchModel> placeList = <GoogleAutoCompleteSearchModel>[];
      final String googleAutoCompleteSearch =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${AppCredentials.googleMapKey}';
      Uri url = Uri.parse(googleAutoCompleteSearch);
      final http.Response response = await http.get(url);
      if (jsonDecode(response.body)['status'] == 'OK') {
        for (var i in jsonDecode(response.body)['predictions']) {
          placeList.add(GoogleAutoCompleteSearchModel.fromJson(i['structured_formatting']));
        }
        return placeList;
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  static Future<LatLngModel?> getLatLngFromAddressForGoogle({required String address}) async {
    try {
      LatLngModel latLngModel = LatLngModel();
      String url =
          "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=${AppCredentials.googleMapKey}";
      Uri apiUrl = Uri.parse(url);
      http.Response response = await http.get(apiUrl);
      if (jsonDecode(response.body)['status'] == 'OK') {
        var jsonMap = jsonDecode(response.body)['results'][0]['geometry']['location'];
        latLngModel = LatLngModel.fromJson(jsonMap);
        return latLngModel;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  static Future<String> getAddressFromLatLngForGoogle({required double lat, required double lng}) async {
    try {
      String fullAddress = '';
      String url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${AppCredentials.googleMapKey}';
      Uri apiUrl = Uri.parse(url);
      var response = await http.get(apiUrl);
      if (jsonDecode(response.body)['status'] == 'OK') {
        fullAddress = jsonDecode(response.body)['results'][0]['formatted_address'].toString();
        return fullAddress;
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}
