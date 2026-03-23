import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mh/app/common/utils/exports.dart';
import '../../../client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class JobDetailsMonthsWidget extends StatelessWidget {
  final List<RequestDateModel> requestDateList;

  const JobDetailsMonthsWidget({Key? key, required this.requestDateList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the unique months and calculate the total number of months
    final months = _getUniqueMonths();
    final totalMonths = months.length;

    return Container(
      height: Get.height * 0.7, // Set the height of the bottom sheet
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
    decoration: BoxDecoration(
            color: MyColors.lightCard(Get.context!),
            borderRadius: BorderRadius.circular(10.0),
          ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0.sp, vertical: 4.0.sp),
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
                                  text: '${totalMonths}',
                                  style: Get.width > 600
                                      ? MyColors.white.semiBold16
                                      : MyColors.white.semiBold24,
                                ),
                                TextSpan(
                                  text: totalMonths > 1
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
                ),
            
              SizedBox(height: 10.h),
          
              // List of months with details
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final requestDate = requestDateList.firstWhere((item) =>
                        DateFormat('MMM yyyy').format(DateTime.parse(item.startDate ?? '')) == month);
                    
                    // Calculate the total days between start and end date
                    final startDate = DateTime.parse(requestDate.startDate ?? '');
                    final endDate = DateTime.parse(requestDate.endDate ?? '');
                    final daysCount = endDate.difference(startDate).inDays;
          
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      elevation: 2,
                      color: MyColors.primaryDark,
                      shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                 ),
                      child: ListTile(
                        title: Text(
                          month,
                          style:  MyColors.white.semiBold14,
                          
                        ),
                        subtitle: Row(
                          children: [
                            // Display start and end dates
                            Text(
                              "Start: ${DateFormat('dd MMM yyyy').format(startDate)}",
                              style: MyColors.white.semiBold11
                            ),
                            SizedBox(width: 10),
                            Text(
                              "End: ${DateFormat('dd MMM yyyy').format(endDate)}",
                              style: MyColors.white.semiBold11,
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          radius: 18.sp,
                          
                          backgroundColor: MyColors.primaryLight,
                          child: Text(
                            "$daysCount",
                            style: TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        ),
                        onTap: () {
                          // You can perform actions when a month is tapped
                          Get.back(); // Close the bottom sheet
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
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
      ),
    );
  }

  // Helper method to extract unique months from the requestDateList
  List<String> _getUniqueMonths() {
    Set<String> monthsSet = {}; // Use a Set to ensure uniqueness

    for (var requestDate in requestDateList) {
      // Parse startDate as a DateTime object
      DateTime startDate = DateTime.parse(requestDate.startDate ?? DateTime.now().toString());
      String formattedMonth = DateFormat('MMM yyyy').format(startDate); // Format as "Month Year"
      monthsSet.add(formattedMonth);
    }

    return monthsSet.toList(); // Convert the Set back to a List
  }
}
