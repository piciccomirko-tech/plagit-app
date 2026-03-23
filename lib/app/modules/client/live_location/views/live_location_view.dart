import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/modules/client/live_location/widgets/location_info_widget.dart';
import '../controllers/live_location_controller.dart';
import '../widgets/location_back_button_widget.dart';

class LiveLocationView extends GetView<LiveLocationController> {
  const LiveLocationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(() => controller.mapLoaded.value == false
            ? Center(child: lottie.Lottie.asset(MyAssets.lottie.mapLoading))
            : Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      tilt: 50.0,
                      bearing: 0,
                      target: LatLng(
                        double.parse(controller.employeeInfo.employeeDetails?.lat ?? "0.0"),
                        double.parse(controller.employeeInfo.employeeDetails?.long ?? "0.0"),
                      ),
                      zoom: 14.50,
                    ),
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        color: Colors.white,
                        width: 10,
                        points: controller.polylineCoordinates,
                      ),
                    },
                    markers: controller.markersList,
                    onMapCreated: controller.onMapCreated,
                  ),
                  const Positioned.fill(
                    child: Align(alignment: Alignment.topLeft, child: LocationBackButtonWidget()),
                  ),
                  const Positioned.fill(child: Align(alignment: Alignment.bottomCenter, child: LocationInfoWidget()))
                ],
              )));
  }
}
