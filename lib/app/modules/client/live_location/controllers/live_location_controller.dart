import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mh/app/common/app_info/app_credentials.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/controller/location_controller.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/modules/client/client_my_employee/controllers/client_my_employee_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:mh/app/routes/app_pages.dart';

class LiveLocationController extends GetxController {
  final AppController appController = Get.find<AppController>();
  final ClientMyEmployeeController clientMyEmployeeController = Get.find<ClientMyEmployeeController>();

  GoogleMapController? mapController;
  RxList<LatLng> polylineCoordinates = <LatLng>[].obs;
  RxBool mapLoaded = false.obs;
  RxSet<Marker> markersList = <Marker>{}.obs;
  Rx<Uint8List> locationIcon = Uint8List(1).obs;

  @override
  void onInit() async {
    Uint8List val = await LocationController.getBytesFromAsset(MyAssets.locationPin, Platform.isAndroid ? 80 : 85);
    locationIcon.value = val;
    await getPolyPoints();
    clientMyEmployeeController.socketLocationModel.listen((SocketLocationModel socket) async {
      await getPolyPoints();
    });
    super.onInit();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  Future<void> getPolyPoints() async {
    polylineCoordinates.clear();
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        AppCredentials.googleMapKey,
        PointLatLng(double.parse(appController.user.value.client?.lat ?? "0.0"),
            double.parse(appController.user.value.client?.long ?? "0.0")),
        PointLatLng(clientMyEmployeeController.socketLocationModel.value.cords?.latitude ?? 0.0,
            clientMyEmployeeController.socketLocationModel.value.cords?.longitude ?? 0.0));
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      polylineCoordinates.refresh();
      await calculateTotalEta();
      loadMarkers();
    }
  }

  void onMapCreated(GoogleMapController c) async {
    String value = await DefaultAssetBundle.of(Get.context!).loadString(MyAssets.customMapStyle);
    mapController = c;
    mapController?.setMapStyle(value);
  }

  void loadMarkers() async {
    Uint8List employeeProfilePicture =
        await _getImageBytes(imageUrl: clientMyEmployeeController.socketLocationModel.value.employeePicture ?? "");

    markersList.add(
      Marker(
        infoWindow: const InfoWindow(title: "Your Location", snippet: 'Keep patience until arriving the employee'),
        icon: BitmapDescriptor.fromBytes(locationIcon.value),
        markerId: const MarkerId('0'),
        position: LatLng(double.parse(appController.user.value.client?.lat ?? "0.0"),
            double.parse(appController.user.value.client?.long ?? "0.0")),
      ),
    );

    markersList.add(
      Marker(
        infoWindow: const InfoWindow(title: "Employee Location", snippet: 'Track his live location'),
        icon: await _resizeImage(employeeProfilePicture, 100, 100),
        markerId: const MarkerId('employeeLocation'),
        position: LatLng(clientMyEmployeeController.socketLocationModel.value.cords?.latitude ?? 0.0,
            clientMyEmployeeController.socketLocationModel.value.cords?.longitude ?? 0.0),
      ),
    );
    markersList.refresh();
    mapLoaded.value = true;
  }

  Future<Uint8List> _getImageBytes({required String imageUrl}) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      // Handle error, return a default image, or throw an exception
      return Uint8List(0); // Return an empty Uint8List for simplicity; you may handle errors differently
    }
  }

  Future<BitmapDescriptor> _resizeImage(Uint8List imageUrl, double width, double height) async {
    final Completer<BitmapDescriptor> completer = Completer();

    ui
        .instantiateImageCodec(Uint8List.view(imageUrl.buffer),
            targetWidth: width.toInt(), targetHeight: height.toInt())
        .then((ui.Codec codec) {
      codec.getNextFrame().then((ui.FrameInfo frameInfo) async {
        final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final Uint8List resizedBytes = byteData.buffer.asUint8List();
          completer.complete(BitmapDescriptor.fromBytes(resizedBytes));
        } else {
          // Handle the case when byteData is null (an error occurred)
          completer.completeError("Failed to resize image");
        }
      });
    });

    return completer.future;
  }

  Future<void> calculateTotalEta() async {
    clientMyEmployeeController.socketLocationModel.value.totalEta = await calculateETA();
    clientMyEmployeeController.socketLocationModel.refresh();
  }

  Future<int> calculateETA() async {
    const String apiKey = AppCredentials.googleMapKey; // Replace with your API key
    final String origin = "${polylineCoordinates.first.latitude},${polylineCoordinates.first.longitude}";
    final String destination = "${polylineCoordinates.last.latitude},${polylineCoordinates.last.longitude}";
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> routes = data['routes'];
      if (routes.isNotEmpty) {
        final Map<String, dynamic> route = routes[0];
        final Map<String, dynamic> leg = route['legs'][0];

        final int durationInSeconds = leg['duration']['value'];
        final int durationInMinutes = (durationInSeconds / 60).round();

        return durationInMinutes;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  }

  void onLiveChatPressed() => Get.toNamed(Routes.clientEmployeeChat, arguments: {
        MyStrings.arg.receiverName: clientMyEmployeeController.socketLocationModel.value.employeeName,
        MyStrings.arg.fromId: appController.user.value.client?.id,
        MyStrings.arg.toId: clientMyEmployeeController.socketLocationModel.value.sender,
        MyStrings.arg.clientId: appController.user.value.client?.id,
        MyStrings.arg.employeeId: clientMyEmployeeController.socketLocationModel.value.sender,
      });
}
