import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mh/app/common/app_info/app_credentials.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/controller/location_controller.dart';
import 'package:mh/app/common/controller/socket_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:http/http.dart' as http;
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/live_location/models/travel_mode_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'dart:ui' as ui;

import 'package:mh/app/routes/app_pages.dart';

class LiveLocationController extends GetxController {
  final AppController appController = Get.find<AppController>();
  final SocketController socketController = Get.find<SocketController>();
  Rx<SocketLocationModel> socketLocationModel = SocketLocationModel().obs;
  RxList<LatLng> polylineCoordinates = <LatLng>[].obs;

  GoogleMapController? mapController;
  RxBool mapLoaded = false.obs;
  RxSet<Marker> markersList = <Marker>{}.obs;
  Rx<Uint8List> locationIcon = Uint8List(1).obs;
  late EmployeeModel employeeInfo;

  @override
  void onInit() async {
    employeeInfo = Get.arguments;
    calculateInitialPolyline(travelMode: TravelMode.driving);
    Uint8List val = await LocationController.getBytesFromAsset(MyAssets.locationPin, Platform.isAndroid ? 80 : 85);
    locationIcon.value = val;
    super.onInit();
  }

  @override
  void onReady() {
    getDataFromSocket();
    super.onReady();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  void getDataFromSocket() {
    try {
      socketController.socket?.on('location:move', (data) async {
        socketLocationModel.value = SocketLocationModel.fromJson(data);
        calculatePolylinePoints(
            origin: PointLatLng(
                socketLocationModel.value.cords?.latitude ?? 0.0, socketLocationModel.value.cords?.longitude ?? 0.0),
            destination: PointLatLng(double.parse(appController.user.value.client?.lat ?? "0.0"),
                double.parse(appController.user.value.client?.long ?? "0.0")),
            travelMode: TravelMode.driving);
        socketLocationModel.value.distance = (LocationController.calculateDistance(
                    targetLat: socketLocationModel.value.cords?.latitude ?? 0.0,
                    targetLong: socketLocationModel.value.cords?.longitude ?? 0.0,
                    currentLat: double.parse(appController.user.value.client?.lat ?? "0.0"),
                    //23.795455885215837,
                    currentLong: double.parse(appController.user.value.client?.long ?? "0.0")
                    //90.40503904223443
                    ) /
                1609.34)
            .toStringAsFixed(2);
        employeeInfo.employeeDetails?.lat = (socketLocationModel.value.cords?.latitude ?? 0.0).toString();
        employeeInfo.employeeDetails?.long = (socketLocationModel.value.cords?.longitude ?? 0.0).toString();
        loadMarkers(
            employeePosition: LatLng(
                socketLocationModel.value.cords?.latitude ?? 0.0, socketLocationModel.value.cords?.longitude ?? 0.0));
      });
    } catch (_) {}
  }

  void onMapCreated(GoogleMapController c) async {
    String value = await DefaultAssetBundle.of(Get.context!).loadString(MyAssets.customMapStyle);
    mapController = c;
    mapController?.setMapStyle(value);
  }

  void loadMarkers({required LatLng employeePosition}) async {
    Uint8List employeeProfilePicture =
        await _getImageBytes(imageUrl: (employeeInfo.employeeDetails?.profilePicture ?? "").imageUrl);

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
        position: employeePosition,
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
      return Uint8List(0);
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
          completer.completeError("Failed to resize image");
        }
      });
    });

    return completer.future;
  }

  void onLiveChatPressed() {

    Get.toNamed(Routes.liveChat,
        arguments: LiveChatDataTransferModel(
            toName: employeeInfo.employeeDetails?.name ?? "",
            toId: employeeInfo.employeeId ?? "",
            toProfilePicture: (employeeInfo.employeeDetails?.profilePicture ?? "").imageUrl,
            senderId: Get.find<AppController>().user.value.userId,
            bookedId: employeeInfo.id ?? ""));
  }

  void onTravelModeTap({required String mode}) {
    // Define the travel mode dynamically
    TravelMode travelMode;
    switch (mode.toLowerCase()) {
      case 'driving':
        travelMode = TravelMode.driving;
        break;
      case 'walking':
        travelMode = TravelMode.walking;
        break;
      case 'bicycling':
        travelMode = TravelMode.bicycling;
        break;
      case 'transit':
        travelMode = TravelMode.transit;
        break;
      default:
        travelMode = TravelMode.driving;
    }
    calculateInitialPolyline(travelMode: travelMode);
    for (var i in travelModeList) {
      if (i.title == mode) {
        i.isSelected = true;
      } else {
        i.isSelected = false;
      }
    }
    // Refresh the UI to reflect the changes
    travelModeList.refresh();
  }

  int parseDurationInMinutes({required String durationText}) {
    if (durationText.isNotEmpty) {
      List<String> parts = durationText.split(' ');

      int hours = 0;
      int minutes = 0;

      for (int i = 0; i < parts.length; i += 2) {
        int value = int.parse(parts[i]);
        String unit = parts[i + 1].toLowerCase();

        if (unit == 'hour' || unit == 'hours') {
          hours += value;
        } else if (unit == 'min' || unit == 'mins' || unit == 'minute' || unit == 'minutes') {
          minutes += value;
        }
      }

      return hours * 60 + minutes;
    } else {
      return 0;
    }
  }

  void calculatePolylinePoints(
      {required PointLatLng origin, required PointLatLng destination, required TravelMode travelMode}) async {
    try {
      polylineCoordinates.clear();

      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints
          .getRouteBetweenCoordinates(AppCredentials.googleMapKey, origin, destination, travelMode: travelMode);
      socketLocationModel.value.currentPosition = result.startAddress;
      socketLocationModel.value.totalEta = parseDurationInMinutes(durationText: result.duration ?? "");

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
      socketLocationModel.refresh();
      polylineCoordinates.refresh();
    } catch (_) {
      Utils.showSnackBar(
          message: "No route for ${travelMode.toString().split('.').last} between these points", isTrue: false);
    }
  }

  void calculateInitialPolyline({required TravelMode travelMode}) {
    calculatePolylinePoints(
        origin: PointLatLng(double.parse(employeeInfo.employeeDetails?.lat ?? "0.0"),
            double.parse(employeeInfo.employeeDetails?.long ?? "0.0")),
        destination: PointLatLng(double.parse(appController.user.value.client?.lat ?? "0.0"),
            double.parse(appController.user.value.client?.long ?? "0.0")),
        travelMode: travelMode);

    socketLocationModel.value.distance = (LocationController.calculateDistance(
                targetLat: double.parse(employeeInfo.employeeDetails?.lat ?? "0.0"),
                targetLong: double.parse(employeeInfo.employeeDetails?.long ?? "0.0"),
                currentLat: double.parse(appController.user.value.client?.lat ?? "0.0"),
                //23.795455885215837,
                currentLong: double.parse(appController.user.value.client?.long ?? "0.0")
                //90.40503904223443
                ) /
            1609.34)
        .toStringAsFixed(2);
    loadMarkers(
        employeePosition: LatLng(double.parse(employeeInfo.employeeDetails?.lat ?? "0.0"),
            double.parse(employeeInfo.employeeDetails?.long ?? "0.0")));
  }
}
