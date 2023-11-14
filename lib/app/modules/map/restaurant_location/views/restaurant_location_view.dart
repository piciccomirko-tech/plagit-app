import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:mh/app/modules/map/restaurant_location/widgets/address_search_field_widget.dart';
import 'package:mh/app/modules/map/restaurant_location/widgets/auto_complete_search_widget.dart';
import '../../../../common/utils/exports.dart';
import '../controllers/restaurant_location_controller.dart';

class RestaurantLocationView extends GetView<RestaurantLocationController> {
  const RestaurantLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      body: Obx(
        () => controller.mapLoaded.value == false
            ? _loading
            : controller.locationFetchError.value.isNotEmpty
                ? _locationFetchError
                : Stack(
                    children: [
                      GoogleMap(
                        zoomGesturesEnabled: true, //enable Zoom in, out on map
                        myLocationEnabled: true,
                        markers: controller.markersList,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: controller.latLng.value,
                          zoom: 14.4746,
                        ),
                        onTap: controller.onMapTap,
                        onMapCreated: controller.onMapCreated,
                        onCameraMove: controller.onCameraMove,
                        onCameraIdle: controller.onCameraIdle,
                      ),
                      /* Transform.translate(
                        offset: const Offset(0, -10),
                        child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 35),
                              child: Image.asset(
                                MyAssets.locationPin,
                                width: 50,
                                height: 50,
                              ),
                            )),
                      ),*/
                      Positioned.fill(
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.18,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: MyColors.c_C6A34F,
                                          child: Icon(CupertinoIcons.location_solid, color: Colors.white, size: 15),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Flexible(
                                          flex: 10,
                                          child: Obx(() => Text(controller.locationText.value,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: MyColors.white.semiBold15)))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Obx(() => CustomButtons.button(
                                            padding:  EdgeInsets.symmetric(horizontal: 10.0.w),
                                            margin: EdgeInsets.zero,
                                            fontSize: 13,
                                            height: 40.h,
                                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                            onTap: controller.onSearchLocationClick,
                                            backgroundColor: Colors.teal,
                                            text: controller.showAutoCompleteSearchWidget.value == false
                                                ? 'Search Location'.toUpperCase()
                                                : 'Close Search'.toUpperCase(),
                                          )),
                                      Obx(() => CustomButtons.button(
                                            margin: EdgeInsets.zero,
                                            padding:  EdgeInsets.symmetric(horizontal: 10.0.w),
                                            fontSize: 13,
                                            height: 40.h,
                                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                            onTap: controller.confirmButtonDisable.value == true
                                                ? null
                                                : controller.onConfirmPressed,
                                            text: 'Confirm Location'.toUpperCase(),
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            )),
                      ),
                      Positioned.fill(
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50.0, left: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: InkResponse(
                                      onTap: () => Get.back(),
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                            color: MyColors.c_C6A34F, borderRadius: BorderRadius.circular(5.0)),
                                        child: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 25),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 18,
                                    child: Obx(() => Visibility(
                                        visible: controller.showAutoCompleteSearchWidget.value,
                                        child: const AddressSearchFieldWidget())),
                                  ),
                                  const SizedBox(width: 10)
                                ],
                              ),
                            )),
                      ),
                      const Positioned.fill(
                        child: Align(alignment: Alignment.center, child: AutoCompleteSearchWidget()),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget get _loading => Center(
    child: SizedBox(
          width: double.infinity,
          child: Lottie.asset(MyAssets.lottie.mapLoading),
        ),
  );

  Widget get _locationFetchError => Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_off,
                  size: 50,
                  color: MyColors.c_C6A34F,
                ),
                const SizedBox(height: 15),
                Text(
                  controller.locationFetchError.value,
                  style: MyColors.l111111_dwhite(controller.context!).semiBold15,
                ),
                const SizedBox(height: 15),
                Text(
                  "Please turn on you location and try again",
                  style: MyColors.l111111_dwhite(controller.context!).regular12,
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: 50,
            child: GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.c_C6A34F,
                ),
                child: Transform.translate(
                  offset: const Offset(2, 0),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
