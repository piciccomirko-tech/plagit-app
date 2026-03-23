import '../../../../common/controller/app_controller.dart';
import '../../../../common/data/data.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../client_shortlisted/models/add_to_shortlist_request_model.dart';

class CustomMarkerInfoWindow extends StatelessWidget {
  final String employeeId;
  final String image;
  final String name;
  final String position;
  final String experience;
  final String distance;
  final String countryName;
  final double rate;

  const CustomMarkerInfoWindow({
    super.key,
    required this.employeeId,
    required this.image,
    required this.name,
    required this.position,
    required this.experience,
    required this.distance,
    required this.countryName,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final feedController = Get.put(
      CommonSocialFeedController(socialFeedRepository: Get.find()),
    );
    return InkWell(
      onTap: () => Get.toNamed(Routes.employeeDetails,
          arguments: {'employeeId': employeeId}),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isTab(Get.context) ? 4 : 8,
            vertical: ResponsiveHelper.isTab(Get.context) ? 6 : 10),
        decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          border: Border.all(color: MyColors.lightGrey, width: 0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: ResponsiveHelper.isTab(Get.context) ? 50.w : 100.w,
                  height: Get.find<AppController>()
                              .user
                              .value
                              .userCountry
                              .toLowerCase() !=
                          countryName.toLowerCase()
                      ? ResponsiveHelper.isTab(Get.context)
                          ? 43.w
                          : 95.w
                      : ResponsiveHelper.isTab(Get.context)
                          ? 30.w
                          : 65.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.withOpacity(.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: image.isEmpty
                        ? Image.asset(
                            MyAssets.employeeDefault,
                            fit: BoxFit.fill,
                          )
                        : CustomNetworkImage(
                            url: image.imageUrl,
                            fit: BoxFit.fill,
                            radius: 5,
                          ),
                  ),
                ),
                if (Get.find<AppController>()
                        .user
                        .value
                        .userCountry
                        .toLowerCase() ==
                    countryName.toLowerCase())
                  Padding(
                    padding: EdgeInsets.only(
                        top: ResponsiveHelper.isTab(Get.context) ? 4.h : 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => feedController.shortlistController.getIcon(
                            requestedDateList: <RequestDateModel>[],
                            employeeId: employeeId,
                            isFetching: feedController
                                .shortlistController.isFetching.value,
                            fromWhere: '',
                            uniformMandatory: false,
                            height:
                                ResponsiveHelper.isTab(Get.context) ? 20 : 20,
                            width:
                                ResponsiveHelper.isTab(Get.context) ? 20 : 20,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            feedController.onBookNowClick(employeeId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.isTab(Get.context)
                                    ? 6.w
                                    : 12.w,
                                vertical: ResponsiveHelper.isTab(Get.context)
                                    ? 2.w
                                    : 4.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                          child: Text(
                            'Book Now',
                            style: TextStyle(
                              fontFamily: MyAssets.fontMontserrat,
                              fontSize: ResponsiveHelper.isTab(Get.context)
                                  ? 5.sp
                                  : 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ),
            SizedBox(width: ResponsiveHelper.isTab(Get.context) ? 4.w : 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: TextStyle(
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize:
                              ResponsiveHelper.isTab(Get.context) ? 12 : 16,
                          fontWeight: FontWeight.bold,
                          color: MyColors.l111111_dwhite(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                      height: ResponsiveHelper.isTab(Get.context) ? 0 : 4.h),
                  const Divider(
                    // thickness: .5,
                    height: .5,
                    color: MyColors.c_D9D9D9,
                    // endIndent: 13,
                  ),
                  SizedBox(
                      height: ResponsiveHelper.isTab(Get.context) ? 2.h : 4.h),
                  WindowItemWidget(
                    image: Data.getPositionImageByName(position.toString()),
                    title: '',
                    subTitle: position,
                  ),
                  SizedBox(
                      height: ResponsiveHelper.isTab(Get.context) ? 2.h : 4.h),
                  WindowItemWidget(
                    image: MyAssets.rate,
                    title: "${MyStrings.rate.tr}: ",
                    subTitle:
                        "${Utils.getCurrencySymbolModified(countryName)} ${rate.round()}/hour",
                  ),
                  SizedBox(
                      height: ResponsiveHelper.isTab(Get.context) ? 2.h : 4.h),
                  WindowItemWidget(
                    image: MyAssets.exp,
                    title: MyStrings.exp.tr,
                    subTitle: "$experience Years",
                  ),
                  SizedBox(
                      height: ResponsiveHelper.isTab(Get.context) ? 2.h : 4.h),
                  WindowItemWidget(
                    image: MyAssets.distance,
                    title: "",
                    subTitle: "$distance km away",
                  ),
                ],
              ),
            )
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Flexible(
            //           child: Text(
            //             name.isNotEmpty &&
            //                     name.length > (Get.width > 600 ? 14 : 17)
            //                 ? Utils.truncateCharacters(
            //                     name, Get.width > 600 ? 14 : 17)
            //                 : name,
            //             style: TextStyle(
            //                 fontFamily: MyAssets.fontMontserrat,
            //                 fontSize: Get.width > 600 ? 12 : 16,
            //                 fontWeight: FontWeight.bold,
            //                 color: MyColors.l111111_dwhite(context)),
            //             maxLines: 1,
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ),
            //         Obx(
            //           () => feedController.shortlistController.getIcon(
            //               requestedDateList: <RequestDateModel>[],
            //               employeeId: employeeId,
            //               isFetching: feedController
            //                   .shortlistController.isFetching.value,
            //               fromWhere: '',
            //               uniformMandatory: false),
            //         ),
            //       ],
            //     ),
            //     SizedBox(height: Get.width > 600 ? 0 : 6.h),
            //     const Divider(
            //       // thickness: .5,
            //       height: .5,
            //       color: MyColors.c_D9D9D9,
            //       // endIndent: 13,
            //     ),
            //     SizedBox(height: Get.width > 600 ? 2.h : 8.h),
            //     Row(
            //       children: [
            //         Image.asset(
            //           Data.getPositionImageByName(position.toString()),
            //           width: Get.width > 600 ? 10.w : 14.w,
            //           height: Get.width > 600 ? 10.w : 14.w,
            //         ),
            //         Expanded(
            //           flex: 2,
            //           child: Padding(
            //             padding: EdgeInsets.only(left: Get.width > 600 ? 8 : 5),
            //             child: Text(
            //               position.isNotEmpty &&
            //                       position.length > (Get.width > 600 ? 6 : 8)
            //                   ? Utils.truncateCharacters(
            //                       position, Get.width > 600 ? 6 : 8)
            //                   : position,
            //               style: TextStyle(
            //                 fontFamily: MyAssets.fontMontserrat,
            //                 fontSize: Get.width > 600 ? 8 : 11,
            //                 fontWeight: FontWeight.w400,
            //                 color: MyColors.l111111_dwhite(context),
            //               ),
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //           ),
            //         ),
            //         SizedBox(width: 4.w),
            //         Image.asset(
            //           MyAssets.rate,
            //           width: Get.width > 600 ? 10.w : 14.w,
            //           height: Get.width > 600 ? 10.w : 14.w,
            //         ),
            //         Expanded(
            //           flex: 3,
            //           child: Padding(
            //             padding: EdgeInsets.only(left: Get.width > 600 ? 8 : 5),
            //             child: Text(
            //               ("${MyStrings.rate.tr}: ${Utils.getCurrencySymbol()} ${rate.round()}/hour"),
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //               style: TextStyle(
            //                   fontFamily: MyAssets.fontMontserrat,
            //                   fontSize: Get.width > 600 ? 8 : 11,
            //                   fontWeight: FontWeight.w500,
            //                   color: MyColors.l111111_dwhite(context)),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //     SizedBox(height: Get.width > 600 ? 2.h : 8.h),
            //     Row(
            //       children: [
            //         Image.asset(
            //           MyAssets.exp,
            //           width: Get.width > 600 ? 10.w : 14.w,
            //           height: Get.width > 600 ? 10.w : 14.w,
            //         ),
            //         SizedBox(width: 5),
            //         Expanded(
            //           child: Text(
            //             '${MyStrings.exp.tr} $experience Years',
            //             maxLines: 1,
            //             overflow: TextOverflow.ellipsis,
            //             style: TextStyle(
            //                 fontFamily: MyAssets.fontMontserrat,
            //                 fontSize: Get.width > 600 ? 8 : 11,
            //                 fontWeight: FontWeight.w500,
            //                 color: MyColors.l111111_dwhite(context)),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
      /*child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: Get.width > 600 ? 6 : 12,
                vertical: Get.width > 600 ? 4 : 10),
            decoration: BoxDecoration(
              color: MyColors.lightCard(context),
              border: Border.all(color: MyColors.lightGrey, width: 0.5),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        name.isNotEmpty &&
                                name.length > (Get.width > 600 ? 14 : 17)
                            ? Utils.truncateCharacters(
                                name, Get.width > 600 ? 14 : 17)
                            : name,
                        style: TextStyle(
                            fontFamily: MyAssets.fontMontserrat,
                            fontSize: Get.width > 600 ? 12 : 16,
                            fontWeight: FontWeight.bold,
                            color: MyColors.l111111_dwhite(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Obx(
                      () => feedController.shortlistController.getIcon(
                          requestedDateList: <RequestDateModel>[],
                          employeeId: employeeId,
                          isFetching: feedController
                              .shortlistController.isFetching.value,
                          fromWhere: '',
                          uniformMandatory: false),
                    ),
                  ],
                ),
                SizedBox(height: Get.width > 600 ? 0 : 6.h),
                const Divider(
                  // thickness: .5,
                  height: .5,
                  color: MyColors.c_D9D9D9,
                  // endIndent: 13,
                ),
                SizedBox(height: Get.width > 600 ? 2.h : 8.h),
                Row(
                  children: [
                    Image.asset(
                      Data.getPositionImageByName(position.toString()),
                      width: Get.width > 600 ? 10.w : 14.w,
                      height: Get.width > 600 ? 10.w : 14.w,
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: Get.width > 600 ? 8 : 5),
                        child: Text(
                          position.isNotEmpty &&
                              position.length > (Get.width > 600 ? 6 : 8)
                              ? Utils.truncateCharacters(
                              position, Get.width > 600 ? 6 : 8)
                              : position,
                          style: TextStyle(
                              fontFamily: MyAssets.fontMontserrat,
                              fontSize: Get.width > 600 ? 8 : 11,
                              fontWeight: FontWeight.w400,
                              color: MyColors.l111111_dwhite(context),),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Image.asset(
                      MyAssets.rate,
                      width: Get.width > 600 ? 10.w : 14.w,
                      height: Get.width > 600 ? 10.w : 14.w,
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(left: Get.width > 600 ? 8 : 5),
                        child: Text(
                          ("${MyStrings.rate.tr}: ${Utils.getCurrencySymbol()} ${rate.round()}/hour"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: MyAssets.fontMontserrat,
                              fontSize: Get.width > 600 ? 8 : 11,
                              fontWeight: FontWeight.w500,
                              color: MyColors.l111111_dwhite(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Get.width > 600 ? 2.h : 8.h),
                Row(
                  children: [
                    Image.asset(
                      MyAssets.exp,
                      width: Get.width > 600 ? 10.w : 14.w,
                      height: Get.width > 600 ? 10.w : 14.w,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${MyStrings.exp.tr} $experience Years',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: MyAssets.fontMontserrat,
                            fontSize: Get.width > 600 ? 8 : 11,
                            fontWeight: FontWeight.w500,
                            color: MyColors.l111111_dwhite(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                feedController.onBookNowClick(employeeId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Get.width > 600 ? 10.w : 20.w,
                    vertical: Get.width > 600 ? 4.h : 8.h),
                decoration: BoxDecoration(
                  color: MyColors.primaryDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                // onPressed: () {},
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: const Color(0xFF4FD2C2),
                //   foregroundColor: Colors.white,
                //   // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   // minimumSize: const Size(80, 32),
                //   elevation: 0,
                // ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),*/
    );
  }
}

class WindowItemWidget extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;

  const WindowItemWidget(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          image,
          width: ResponsiveHelper.isTab(Get.context) ? 7.w : 14.w,
          height: ResponsiveHelper.isTab(Get.context) ? 7.w : 14.w,
        ),
        SizedBox(width: ResponsiveHelper.isTab(Get.context) ? 2 : 5),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: ResponsiveHelper.isTab(Get.context) ? 6 : 11,
                      fontWeight: FontWeight.w400,
                      color: MyColors.lightGrey),
                ),
                TextSpan(
                  text: subTitle,
                  style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: ResponsiveHelper.isTab(Get.context) ? 6 : 11,
                      fontWeight: FontWeight.w600,
                      color: MyColors.l111111_dwhite(context)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
