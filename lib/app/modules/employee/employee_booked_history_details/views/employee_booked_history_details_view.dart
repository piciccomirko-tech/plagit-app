import 'package:carousel_slider/carousel_slider.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/common/widgets/time_range_widget.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import '../controllers/employee_booked_history_details_controller.dart';

class EmployeeBookedHistoryDetailsView extends GetView<EmployeeBookedHistoryDetailsController> {
  const EmployeeBookedHistoryDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Container(
        color: context.theme.scaffoldBackgroundColor,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                    stretch: true,
                    iconTheme: const IconThemeData(
                      color: MyColors.white, //change your color here
                    ),
                    pinned: true,
                    floating: false,
                    leading: const Padding(
                      padding: EdgeInsets.all(13.0),
                      child: CustomAppbarBackButton(),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    expandedHeight: MediaQuery.of(context).size.height * 0.3,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: ClipPath(
                          clipper: MyClipper(),
                          child: Image.asset(MyAssets.restaurant,
                              fit: BoxFit.cover,
                              colorBlendMode: BlendMode.darken,
                              color: MyColors.black.withOpacity(0.6))),
                    )),
                SliverToBoxAdapter(
                    child: Obx(() => controller.bookingDetailsDataLoading.value == true
                        ? Center(child: ShimmerWidget.bookingDetailsShimmerWidget())
                        : SingleChildScrollView(
                          child: Column(
                              children: [
                                Container(
                                    width: Get.width * 0.8,
                                    padding:  EdgeInsets.all(10.0.sp),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30.0), color: MyColors.c_C6A34F),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${MyStrings.bookedFor.tr} ', style: Get.width>600?MyColors.white.semiBold10:MyColors.white.semiBold15),
                                        Text('${controller.bookingDetails.value.requestDateList?.calculateTotalDays()}',
                                            style: Get.width>600?MyColors.white.semiBold15:MyColors.white.semiBold24),
                                        Text(' ${MyStrings.days.tr}', style: Get.width>600?MyColors.white.semiBold10:MyColors.white.semiBold15),
                                      ],
                                    )),
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: Get.width>600?200:120,
                                    autoPlay: controller.bookingDetails.value.requestDateList!.length > 1 ? true : false,
                                    viewportFraction: 1.0,
                                  ),
                                  items: controller.bookingDetails.value.requestDateList!.map((RequestDateModel url) {
                                    return Padding(
                                      padding:  EdgeInsets.symmetric(horizontal: 20.0.sp),
                                      child: TimeRangeWidget(
                                          requestDate: url,
                                          hasDeleteOption: true,
                                          onTap: () => controller.updateRequestDate(rejectedDate: url)),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    minVerticalPadding: 0.0,
                                    minLeadingWidth: 0.0,
                                    isThreeLine: true,
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: Icon(Icons.notifications_active_outlined, color: MyColors.white),
                                    ),
                                    title: Text('${controller.bookingDetails.value.text}',
                                        style: Get.width>600?MyColors.l111111_dwhite(context).semiBold12:MyColors.l111111_dwhite(context).semiBold15),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(controller.bookingDetails.value.restaurantAddress ?? '',
                                          style: Get.width>600?MyColors.c_A6A6A6.semiBold12:MyColors.c_A6A6A6.semiBold13),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                      minVerticalPadding: 0.0,
                                      minLeadingWidth: 0.0,
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.teal,
                                        child: Icon(Icons.location_city, color: MyColors.white),
                                      ),
                                      title: Text(
                                          '${MyStrings.restaurantDistance.tr} ${(Get.find<EmployeeHomeController>().restaurantDistanceFromEmployee(targetLat: double.parse(controller.bookingDetails.value.hiredByLat.toString()), targetLng: double.parse(controller.bookingDetails.value.hiredByLong.toString())) / 1609.34).toStringAsFixed(2)} ${MyStrings.milesLocation.tr}',
                                          style: Get.width>600?MyColors.l111111_dwhite(context).semiBold12:MyColors.l111111_dwhite(context).semiBold15)),
                                ),
                                const SizedBox(height: 10),
                                if(controller.bookingDetails.value.uniformMandatory == true)
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                      minVerticalPadding: 0.0,
                                      minLeadingWidth: 0.0,
                                      trailing: InkWell(
                                        onTap: controller.onViewUniformClick,
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          child: Icon(Icons.remove_red_eye, color: MyColors.c_C6A34F),
                                        ),
                                      ),
                                      leading:  CircleAvatar(
                                        backgroundColor: Colors.purple,
                                        child: Image.asset(MyAssets.uniform, color: Colors.white, height: 22, width: 22),
                                      ),
                                      title: Text(
                                        MyStrings.provideUniform.tr,
                                          style: Get.width>600?MyColors.l111111_dwhite(context).semiBold12:MyColors.l111111_dwhite(context).semiBold15)),
                                )
                                else
                                  Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                        minVerticalPadding: 0.0,
                                        minLeadingWidth: 0.0,
                                        leading:  CircleAvatar(
                                          backgroundColor: Colors.purple,
                                          child: Image.asset(MyAssets.uniform, color: Colors.white, height: 22, width: 22),
                                        ),
                                        title: Text(
                                            MyStrings.noUniform.tr,
                                            style: Get.width>600?MyColors.l111111_dwhite(context).semiBold12:MyColors.l111111_dwhite(context).semiBold15)),
                                  ),
                                SizedBox(height: MediaQuery.sizeOf(context).width*0.2)
                              ],
                            ),
                        )))
              ],
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 50,
                // child: Row(
                //   children: [
                //     Expanded(
                //       child: Material(
                //         child: InkWell(
                //           onTap: () => Get.find<EmployeeHomeController>()
                //               .updateNotification(id: controller.bookingDetails.value.id ?? '', hiredStatus: "ALLOW"),
                //           child: Container(
                //             color: MyColors.c_C6A34F,
                //             height: 60.h,
                //             child: Center(child: Text(MyStrings.allowAll.tr.toUpperCase(), style: Get.width>600?MyColors.white.semiBold10:MyColors.white.semiBold15)),
                //           ),
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: Material(
                //         child: InkWell(
                //           onTap: () => Get.find<EmployeeHomeController>()
                //               .updateNotification(id: controller.bookingDetails.value.id ?? '', hiredStatus: "DENY"),
                //           child: Container(
                //             color: Colors.red,
                //             height: 60.h,
                //             child: Center(child: Text(MyStrings.denyAll.tr.toUpperCase(), style: Get.width>600?MyColors.white.semiBold10:MyColors.white.semiBold15)),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
             
             
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                         onTap: () => Get.find<EmployeeHomeController>()
                            .updateNotification(id: controller.bookingDetails.value.id ?? '', hiredStatus: "ALLOW"),
                        child: Container(
                          color: MyColors.c_C6A34F,
                          height: 60.h,
                          child: Center(child: Text(MyStrings.allowAll.tr.toUpperCase(), style: Get.width>600?MyColors.white.semiBold10:MyColors.white.semiBold15)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.find<EmployeeHomeController>()
                              .updateNotification(id: controller.bookingDetails.value.id ?? '', hiredStatus: "DENY"),
                        child: Container(
                          color: Colors.red,
                          height: 60.h,
                          child: Center(child: Text(MyStrings.denyAll.tr.toUpperCase(), style: Get.width>600?MyColors.white.semiBold10:MyColors.white.semiBold15)),
                        ),
                      ),
                    ),
                  ],
                ),
             
             
              ),
            ))
          ],
        ));
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(Get.width / 2, size.height, Get.width, size.height - 40);
    path.lineTo(Get.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
