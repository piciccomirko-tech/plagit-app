import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import '../controllers/live_location_controller.dart';

class LiveLocationView extends GetView<LiveLocationController> {
  const LiveLocationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      if (controller.mapLoaded.value == false) {
        return Center(child: lottie.Lottie.asset(MyAssets.lottie.mapLoading));
      } else {
        return Stack(
          children: [
            Obx(() => GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    controller.locationData.value.clientLat ?? 0.0, controller.locationData.value.clientLng ?? 0.0),
                zoom: 15.0,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: MyColors.c_C6A34F,
                  points: controller.polylineCoordinates)
              },
              markers: controller.markersList,
              onMapCreated: controller.onMapCreated,
            )),
            Positioned.fill(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 10.0),
                    child: InkResponse(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 35,
                        width: 35,
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(color: MyColors.c_C6A34F, borderRadius: BorderRadius.circular(5.0)),
                        child: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 25),
                      ),
                    ),
                  )),
            ),
          ],
        );
      }
    }));
  }
}
