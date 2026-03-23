import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import 'package:mh/app/enums/custom_button_style.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/client_dashboard_controller.dart';
import '../models/confirm_employee_task.dart';

class TodayMyEmployeeConfirmModal extends StatelessWidget {
  final ClientDashboardController controller =
      Get.find<ClientDashboardController>();

  TodayMyEmployeeConfirmModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Wrap(
          children: [
            Container(
              width: Get.width * 0.95,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              child: controller.loading.value
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: Colors.lightBlue[50],
                          child: Icon(
                            Icons.check_outlined,
                            color: Colors.teal,
                            size: 30.r,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        controller.candidateCount.value > 1
                            ? Text(
                                "${controller.candidateCount.value} candidates have checked out",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: MyAssets.fontMontserrat,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : Text(
                                "${controller.candidateCount.value} candidate has checked out",
                                
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: MyAssets.fontMontserrat,
                                ),
                                textAlign: TextAlign.center,
                              ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Display up to 4 candidate profile pictures
                                for (int i = 0;
                                    i < controller.candidates.length && i < 4;
                                    i++)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    child: CircleAvatar(
                                      radius: 20.r,
                                      backgroundImage: controller.candidates[i].profilePicture!=null && controller.candidates[i].profilePicture!.isNotEmpty
                                          ? NetworkImage(
                                              controller.candidates[i].profilePicture!.imageUrl,
                                            )
                                          : AssetImage(MyAssets.employeeDefault),
                                    
                                      backgroundColor: Colors
                                          .grey[200], // Optional: Placeholder color
                                      // onBackgroundImageError: (_, __) {
                                      //   // Handle the case when image loading fails
                                      //   return Image.asset('assets/images/placeholder.png'); // Optional placeholder image
                                      // },
                                    ),
                                  ),
                          
                                // Display a "more" indicator if there are more than 4 candidates
                                if (controller.candidateCount.value > 4)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    child: CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        "+${controller.candidateCount.value - 4}",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Please check the details properly.\nAfter 12 hours these candidates checkouts will be automatically confirmed",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFFFF5029),
                            fontFamily: MyAssets.fontMontserrat,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: null,
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButtons.button(
                              backgroundColor: Colors.transparent,
                              margin: EdgeInsets.symmetric(horizontal: 5.w),
                              height: 48,
                              context: Get.context!,
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              customButtonStyle:
                                  CustomButtonStyle.radiusTopBottomCorner,
                              text: "View Details",
                          
                              onTap: () {
                                controller.isCheckOutHide.value=true;
                                if (Get.isDialogOpen == true) {Get.back();
                                }
                                Get.toNamed(Routes.clientDashboard);
                              },
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            CustomButtons.button(
                                margin: EdgeInsets.symmetric(horizontal: 5.w),
                                context: Get.context!,
                                height: 48,
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                customButtonStyle:
                                    CustomButtonStyle.radiusTopBottomCorner,
                                text: "Confirm",
                                onTap: () async {
                                  Get.back();
                                  List<String> candidateKeys = controller.candidates.map((employee) => employee.currentHiredEmployeeId!).toList();
                                  final confirmEmployeeTask =
                                        ConfirmEmployeeTaskModel(
                                      currentHiredEmployeeIds: candidateKeys,
                                      hasReview: true,
                                    );
                          
                                    // Call the onConfirmTask for each candidate
                                    await controller
                                        .onConfirmTask(confirmEmployeeTask);
                                })
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    });
  }
}
