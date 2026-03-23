import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../client_home/controllers/client_home_controller.dart';
import '../controllers/nearby_employee_controller.dart';
import '../widgets/custom_thumb_shape.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/saved_searches_dialog.dart';

class LocationView extends GetView<NearbyEmployeeController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    print('LocationView.build:${controller.isPermissionGiven}');
    if (controller.currentLocation.value == const LatLng(0, 0)) {
      NearbyEmployeeController controller = Get.put(NearbyEmployeeController());
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppbar.appbar(
          title: MyStrings.nearBy.tr,
          context: context,
          isPlagItPlus: false,
          centerTitle: false,
          visibleBack: false,
          actions: [
            SizedBox(width: 10.w),
            InkResponse(
              onTap: () => Get.toNamed(Routes.commonSearch),
              child: Image.asset(MyAssets.search,
                  height: ResponsiveHelper.isTab(Get.context) ? 15.w :25.w,
                  width: ResponsiveHelper.isTab(Get.context) ? 15.w :25.w,
                  color: MyColors.l111111_dwhite(context)),
            ),
            SizedBox(width: ResponsiveHelper.isTab(Get.context) ? 10.w :30.w),
            Obx(() {
              int count = Get.find<ClientHomeController>()
                  .notificationsController
                  .unreadCount
                  .value;
              return GestureDetector(
                onTap: () => Get.toNamed(Routes.notifications),
                child: Badge(
                  isLabelVisible: count > 0,
                  backgroundColor: MyColors.c_C6A34F,
                  label: Text(
                    count >= 20
                        ? '20+'
                        : count == 0
                            ? ''
                            : count.toString(),
                    style: TextStyle(
                        fontSize: Get.width > 600 ? 13 : 12,
                        color: MyColors.white,
                        fontFamily: MyAssets.fontKlavika),
                  ),
                  child: Image.asset(MyAssets.bell,
                      height: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                      width: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                      color: MyColors.l111111_dwhite(context)),
                ),
              );
            }),
            SizedBox(width: ResponsiveHelper.isTab(Get.context) ? 10.w : 30.w),
            Obx(() {
              int msgCount =
                  Get.find<ClientHomeController>().unreadMessages.value;
              return InkResponse(
                onTap: () => Get.toNamed(Routes.chatIt),
                child: Badge(
                  isLabelVisible: msgCount > 0,
                  backgroundColor: MyColors.c_C6A34F,
                  label: Text(msgCount > 0 ? msgCount.toString() : '',
                      style: TextStyle(
                          fontSize: Get.width > 600 ? 13 : 12,
                          color: MyColors.white,
                          fontFamily: MyAssets.fontKlavika)),
                  child: Image.asset(MyAssets.chat,
                      height: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                      width: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                      color: MyColors.l111111_dwhite(context)),
                ),
              );
            }),
            SizedBox(width: ResponsiveHelper.isTab(Get.context) ? 10.w : 20.w),
          ],
        ),
        body: Obx(
          () => AbsorbPointer(
              absorbing: controller.isInitialDataLoading.value,
              child: Stack(
                children: [
                  // Map
                  GetBuilder<NearbyEmployeeController>(
                    id: 'map_view',
                    builder: (controller) => GoogleMap(
                      style: controller.mapStyle.value,
                      onMapCreated: controller.onMapCreated,
                      onCameraMove: (position) {
                        controller.customInfoWindowController.onCameraMove!();
                      },
                      onTap: (position) {
                        controller.customInfoWindowController.hideInfoWindow!();
                      },
                      markers: controller.markers,
                      initialCameraPosition: CameraPosition(
                        target: controller.currentLocation.value,
                        // zoom: 15,
                        zoom: log(100 * controller.currentRadius.value) < 4
                            ? 17
                            : 17 - log(100 * controller.currentRadius.value),
                      ),
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      circles: controller.isPermissionGiven.isTrue
                          ? {
                              Circle(
                                circleId: const CircleId('radius'),
                                center: controller.selectedLocation.value,
                                radius: controller.currentRadius.value * 1000,
                                fillColor:
                                    MyColors.primaryDark.withOpacity(0.1),
                                strokeColor: MyColors.primaryDark,
                                strokeWidth: 1,
                              ),
                            }
                          : {},
                    ),
                  ),

                  // Loading overlay
                  if (controller.isInitialDataLoading.value)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomLoader.loading(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading nearby candidates...',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontFamily: MyAssets.fontMontserrat,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Rest of your UI components
                  CustomInfoWindow(
                    controller: controller.customInfoWindowController,
                    height: 120,
                    width: 250,
                    offset: 30,
                  ),
                  // Search Bar and Radius Slider Container
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 5,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const FilterDialog(),
                                ).then((result) {
                                  if (result != null) {
                                    // Handle filter results
                                    final position =
                                        result['position'] as String?;
                                    final minRate = result['minRate'] as double;
                                    final maxRate = result['maxRate'] as double;

                                    // TODO: Apply filters to markers
                                    print('Position: $position');
                                    print('Rate range: €$minRate - €$maxRate');
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: MyColors.lightCard(context),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  child: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Image.asset(
                                          MyAssets.nearByFilter,
                                          height: 60,
                                          width: 60,
                                        )
                                      : Image.asset(
                                          MyAssets.nearByFilter,
                                          height: 60,
                                          width: 60,
                                          color:
                                              MyColors.l7B7B7B_dicon(context),
                                        ),
                                ),
                              ),
                              // child: Container(
                              //   height: 40,
                              //   width: 40,
                              //   decoration: BoxDecoration(
                              //     color: MyColors.lightCard(context),
                              //     shape: BoxShape.circle,
                              //     border: Border.all(
                              //         color: Colors.grey.shade300, width: 1),
                              //   ),
                              //   child: Icon(
                              //     Icons.tune,
                              //     size: 20,
                              //     color: MyColors.l111111_dwhite(context),
                              //   ),
                              // ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                    color: MyColors.lightCard(context),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1)),
                                child: Row(
                                  children: [
                                    Transform.flip(
                                      flipX: true,
                                      child: Icon(
                                        CupertinoIcons.search,
                                        color: MyColors.lightGrey,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        focusNode: controller.searchFocusNode,
                                        controller: controller.searchController,
                                        onChanged: controller.onSearchChanged,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                          hintText: 'Search location',
                                          hintStyle: TextStyle(
                                            color: MyColors.lightGrey,
                                            fontFamily: MyAssets.fontMontserrat,
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true, // Add this line
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 1),
                                        ),
                                      ),
                                    ),
                                    Obx(() => controller
                                            .searchQuery.value.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close,
                                                size: 20),
                                            color: MyColors.lightGrey,
                                            onPressed: controller.clearSearch,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          )
                                        : const SizedBox()),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                controller.showRadius.value = true;
                                // controller.clearSearch();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: MyColors.lightCard(context),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  child: Image.asset(
                                    "assets/icons/distance2.png",
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? MyColors.black
                                        : MyColors.l7B7B7B_dicon(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Location Suggestions
                        Obx(() {
                          if (controller.searchResults.isEmpty ||
                              controller.searchQuery.value.isEmpty) {
                            return const SizedBox();
                          }
                          return Container(
                            margin: EdgeInsets.only(left: 70, right: 55),
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            ),
                            decoration: BoxDecoration(
                              color: MyColors.lightCard(context),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: controller.searchResults.length,
                              itemBuilder: (context, index) {
                                final place = controller.searchResults[index];
                                return ListTile(
                                  leading: Icon(
                                    Icons.location_on,
                                    color: MyColors.lightGrey,
                                    size: 24.r,
                                  ),
                                  title: Text(
                                    "${place.mainText}, ${place.secondaryText}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: MyAssets.fontMontserrat,
                                      color: MyColors.l111111_dwhite(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // subtitle: Text(
                                  //   place.secondaryText, // This will show the other field (address or position)
                                  //   style: const TextStyle(
                                  //     fontSize: 12,
                                  //     color: Colors.grey,
                                  //   ),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  onTap: () {
                                    controller.onPlaceSelected(place);
                                    // controller.mapSearch();
                                  },
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) => Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 4.h),
                                child: Divider(
                                  height: .5.h,
                                  color: MyColors.lightGrey,
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 5),
                        // Radius Slider
                        Obx(() => controller.showRadius.value
                            ? Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                decoration: BoxDecoration(
                                  color: MyColors.lightCard(context),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Radius',
                                      style: TextStyle(
                                        color: MyColors.lightGrey,
                                        fontFamily: MyAssets.fontMontserrat,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 3,
                                          thumbShape: CustomThumbShape(
                                            thumbRadius: 6,
                                            borderWidth: 3,
                                            showValue: true,
                                          ),
                                          overlayShape:
                                              SliderComponentShape.noOverlay,
                                          valueIndicatorShape:
                                              SliderComponentShape.noOverlay,
                                          activeTrackColor:
                                              const Color(0xFF4FD2C2),
                                          inactiveTrackColor:
                                              Colors.grey.withOpacity(0.2),
                                          thumbColor: Colors.white,
                                        ),
                                        child: Obx(
                                          () => Slider(
                                            value:
                                                controller.currentRadius.value,
                                            min: 0.5,
                                            max: 50.0,
                                            onChanged:
                                                controller.onRadiusChanged,
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.showRadius.value = false;
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: MyColors.lightGrey,
                                      ),
                                    ),
                                  ],
                                ))
                            : Wrap()),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () => controller.centerOnUserLocation(),
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 80.h,
                          left: 16,
                          right: 16,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MyColors.lightCard(context),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Icon(
                          Icons.my_location,
                          size: 20,
                          color: MyColors.l111111_dwhite(context),
                        ),
                      ),
                    ),
                  ),
                  // Bottom buttons container
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                        left: 16,
                        right: 16,
                      ),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Saved Search Button
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                useSafeArea: true,
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => SavedSearchesDialog(),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: MyColors.lightCard(context),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                              child: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Image.asset(
                                      MyAssets.savedSearch,
                                      height: 20,
                                      width: 20,
                                    )
                                  : Image.asset(
                                      MyAssets.savedSearch,
                                      height: 20,
                                      width: 20,
                                      color: MyColors.l7B7B7B_dicon(context),
                                    ),
                            ),
                          ),
                          // Save Search Button
                          GestureDetector(
                            onTap: () {
                              if (controller.selectedPosition.isNotEmpty) {
                                controller.mapSearch();
                              } else {
                                Utils.showSnackBar(
                                  message:
                                      "Start by searching using position to save the search",
                                  isTrue: false,
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: MyColors.primaryDark,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Save Search",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: MyAssets.fontMontserrat,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}
