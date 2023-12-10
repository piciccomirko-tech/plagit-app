import 'dart:async';
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
import 'package:mh/app/modules/client/live_location/models/location_argument_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class LiveLocationController extends GetxController {
  Rx<LocationArgumentModel> locationData = LocationArgumentModel().obs;
  Rx<SocketLocationModel> socketLocationData = SocketLocationModel().obs;
  AppController appController = Get.find<AppController>();

  late io.Socket socket;
  GoogleMapController? mapController;
  RxList<LatLng> polylineCoordinates = <LatLng>[].obs;
  RxBool mapLoaded = false.obs;
  RxSet<Marker> markersList = <Marker>{}.obs;
  Rx<Uint8List> locationIcon = Uint8List(1).obs;

  @override
  void onInit() async {
    locationData.value = Get.arguments;
    Uint8List val = await LocationController.getBytesFromAsset(MyAssets.locationPin, Platform.isAndroid ? 80 : 85);
    locationIcon.value = val;
    await getPolyPoints();
    connectWithSocket();
    super.onInit();
  }

  @override
  void onClose() {
    socket.disconnect();
    socket.dispose();
    mapController?.dispose();
    super.onClose();
  }

  Future<void> getPolyPoints() async {
    polylineCoordinates.clear();
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        AppCredentials.googleMapKey,
        PointLatLng(locationData.value.clientLat ?? 0.0, locationData.value.clientLng ?? 0.0),
        PointLatLng(locationData.value.employeeLat ?? 0.0, locationData.value.employeeLng ?? 0.0));
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      polylineCoordinates.refresh();
      loadMarkers();
    }
  }

  void onMapCreated(GoogleMapController c) async {
    String value = await DefaultAssetBundle.of(Get.context!).loadString(MyAssets.customMapStyle);
    mapController = c;
    mapController?.setMapStyle(value);
  }

  void connectWithSocket() {
    try {
      socket = io.io("wss://server.mhpremierstaffingsolutions.com", <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": false,
      });
      socket.connect();
      socket.onConnect((_) {
        socket.on('location:move', (data) async {
          socketLocationData.value = SocketLocationModel.fromJson(data);
          if (locationData.value.clientId == socketLocationData.value.receiver) {
            locationData.value.employeeLat = socketLocationData.value.cords?.latitude ?? 0.0;
            locationData.value.employeeLng = socketLocationData.value.cords?.longitude ?? 0.0;
            locationData.refresh();
            await getPolyPoints();
          }
        });
      });
    } catch (_) {}
  }

  void loadMarkers() async {
    Uint8List employeeProfilePicture = await _getImageBytes(imageUrl: locationData.value.employeePicture ?? "");

    markersList.add(
      Marker(
        infoWindow: const InfoWindow(title: "Welcome Back!", snippet: 'Move this marker to your desired location'),
        icon: BitmapDescriptor.fromBytes(locationIcon.value),
        markerId: const MarkerId('0'),
        position: LatLng(locationData.value.clientLat ?? 0.0, locationData.value.clientLng ?? 0.0),
      ),
    );

    markersList.add(
      Marker(
        infoWindow: const InfoWindow(title: "Employee Location", snippet: 'Move this marker to your desired location'),
        icon: await _resizeImage(employeeProfilePicture, 100, 100),
        markerId: const MarkerId('employeeLocation'),
        position: LatLng(locationData.value.employeeLat ?? 0.0, locationData.value.employeeLng ?? 0.0),
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

    ui.instantiateImageCodec(Uint8List.view(imageUrl.buffer), targetWidth: width.toInt(), targetHeight: height.toInt())
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
}
