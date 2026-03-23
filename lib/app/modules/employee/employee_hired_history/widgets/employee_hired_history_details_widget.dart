// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:mh/app/common/extensions/extensions.dart';
// import 'package:mh/app/common/values/my_assets.dart';
// import 'package:mh/app/common/values/my_color.dart';
// import 'package:mh/app/common/values/my_strings.dart';
// import 'package:mh/app/common/widgets/time_range_widget.dart';
// import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

// class EmployeeHiredHistoryDetailsWidget extends StatelessWidget {
//   final List<RequestDateModel> requestDateList;
//   const EmployeeHiredHistoryDetailsWidget({super.key, required this.requestDateList});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           height: Get.width,
//           decoration: BoxDecoration(color: MyColors.lightCard(Get.context!), borderRadius: BorderRadius.circular(10.0)),
//           child: SingleChildScrollView(
//             child: Padding(
//               padding:  EdgeInsets.symmetric(horizontal: 20.0.sp, vertical: 10.0.sp),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding:  EdgeInsets.symmetric(horizontal: 15.0.sp, vertical: 2.0.sp),
//                     decoration: const BoxDecoration(
//                         borderRadius:
//                             BorderRadius.only(topRight: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
//                         color: MyColors.c_C6A34F),
//                     child: RichText(
//                         text: TextSpan(children: [
//                       TextSpan(text: '${MyStrings.totalWorkSchedule.tr} ', style: Get.width>600?MyColors.white.semiBold12:MyColors.white.semiBold15),
//                       TextSpan(text: '${requestDateList.calculateTotalDays()}', style: Get.width>600?MyColors.white.semiBold16:MyColors.white.semiBold24),
//                       TextSpan(text: ' ${MyStrings.days.tr}', style: Get.width>600?MyColors.white.semiBold11:MyColors.white.semiBold15),
//                     ])),
//                   ),
//                   SizedBox(
//                     height: Get.width * 0.9,
//                     child: ListView.builder(
//                         itemCount: requestDateList.length,
//                         shrinkWrap: true,
//                         primary: true,
//                         physics: const BouncingScrollPhysics(),
//                         padding: EdgeInsets.zero,
//                         itemBuilder: (context, index) {
//                           return Stack(
//                             children: [
//                               TimeRangeWidget(
//                                   requestDate: requestDateList[index], hasDeleteOption: false, onTap: () {}),
//                               if (requestDateList[index].status != null && requestDateList[index].status!.isNotEmpty)
//                                 Positioned.fill(
//                                     child: Align(
//                                   alignment: Alignment.center,
//                                   child: Lottie.asset(MyAssets.lottie.doneLottie),
//                                 ))
//                             ],
//                           );
//                         }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Positioned.fill(
//             child: Align(
//           alignment: Alignment.topRight,
//           child: Padding(
//             padding: const EdgeInsets.all(3.0),
//             child: InkWell(
//               onTap: () => Get.back(),
//               child:  CircleAvatar(
//                 radius: 12.sp,
//                 backgroundColor: Colors.red,
//                 child: Icon(CupertinoIcons.clear, color: MyColors.white, size: 15),
//               ),
//             ),
//           ),
//         ))
//       ],
//     );
//   }
// }

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

import '../controllers/employee_hired_history_controller.dart';

class EmployeeHiredHistoryDetailsWidget extends GetWidget {
  final List<RequestDateModel> requestDateList;

  // Preprocess to get unique month-year values

  const EmployeeHiredHistoryDetailsWidget(
      {super.key, required this.requestDateList});

  @override
  Widget build(BuildContext context) {
    log("widget rendered!!!!!! ${requestDateList.length}");
    log("widget rendered!!!!!! start date ${requestDateList.first.startDate}");
    log("widget rendered!!!!!! end date ${requestDateList.first.endDate}");

    // Access the controller using Get.find() inside the widget
    // final controller = Get.find<EmployeeHiredHistoryController>();
  final controller =  Get.put(EmployeeHiredHistoryController());
    return Stack(
      children: [
        Container(
          height: Get.height * 0.7,
          decoration: BoxDecoration(
            color: MyColors.lightCard(Get.context!),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.0.sp, vertical: 10.0.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Total Work Schedule with calculated months
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 15.0.sp, vertical: 2.0.sp),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      color: MyColors.c_C6A34F,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${MyStrings.totalWorkSchedule.tr} ',
                            style: Get.width > 600
                                ? MyColors.white.semiBold12
                                : MyColors.white.semiBold15,
                          ),
                          TextSpan(
                            text: '${requestDateList.length}',
                            style: Get.width > 600
                                ? MyColors.white.semiBold16
                                : MyColors.white.semiBold24,
                          ),
                          TextSpan(
                            text: requestDateList.length > 1
                                ? ' Times'
                                : ' Time',
                            style: Get.width > 600
                                ? MyColors.white.semiBold11
                                : MyColors.white.semiBold15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  // Text("prev date"),
                  // Grid view of the selected months
                  if (requestDateList.isEmpty)
                    Text("No dates found for this employee", style: Get.width > 600
                                ? MyColors.white.semiBold11:MyColors.white.semiBold15),
                  if (requestDateList.isNotEmpty)
                    GridView.builder(
                      itemCount: requestDateList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Adjust the number of items per row
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio:
                            3 / 1, // Control the height/width ratio
                      ),
                      itemBuilder: (context, index) {
                        // var requestDate = uniqueRequestDates[index];
                        final requestDate = requestDateList[index];
                        // final monthYear = DateFormat.yMMM().format(
                        //   DateTime.tryParse(requestDate.startDate ?? '') ??
                        //       DateTime.now(),
                        // );
                        String formattedDateRange =
                            // Get.find<EmployeeHiredHistoryController>()
                            controller
                                .formatDateRangeWithTime(
                                    requestDate.startDate,
                                    requestDate.startTime,
                                    requestDate.endDate,
                                    requestDate.endTime);

                        return Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0.sp),
                              decoration: BoxDecoration(
                                color: MyColors.c_C6A34F.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: MyColors.c_C6A34F.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  // Display month in 'MMM yyyy' format
                                  // DateFormat.yMMM().format(
                                  //   DateTime.tryParse(requestDate. ?? '') ??
                                  //       DateTime.now(),
                                  // ),
                                  // style: Get.width > 600
                                  //     ? MyColors.darkText.semiBold12
                                  //     : MyColors.darkText.semiBold16,
                                  formattedDateRange,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: Get.width*.03),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (requestDate.status != null &&
                                requestDate.status!.isNotEmpty)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child:
                                      Lottie.asset(MyAssets.lottie.doneLottie),
                                ),
                              )
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: InkWell(
                onTap: () => Get.back(),
                child: CircleAvatar(
                  radius: 12.sp,
                  backgroundColor: Colors.red,
                  child: Icon(
                    CupertinoIcons.clear,
                    color: MyColors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
