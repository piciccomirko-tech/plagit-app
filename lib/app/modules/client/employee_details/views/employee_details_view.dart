import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar_back_button.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../controllers/employee_details_controller.dart';

class EmployeeDetailsView extends GetView<EmployeeDetailsController> {
  const EmployeeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      bottomNavigationBar: _bottomBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(21, 0, 21, 20),
          child: Column(
            children: [
              SizedBox(height: 60.h),

              _backButtonImageBookmark,

              SizedBox(height: 20.h),

              _basicInfo,

              // SizedBox(height: 12.h),

              // _location,

              SizedBox(height: 12.h),

              _skill,
              SizedBox(height: 12.h),
              _education,

              SizedBox(height: 12.h),

              _certificate,

              SizedBox(height: 12.h),

              language,

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _backButtonImageBookmark => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppbarBackButton(),
          const Spacer(),
          Container(
            width: 210.w,
            height: 218.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomNetworkImage(
              url: (controller.employee.profilePicture ?? "").imageUrl,
              radius: 20,
              fit: BoxFit.fill,
            ),
          ),
          const Spacer(),
          /* Obx(
            () => Visibility(c
              visible: !controller.showAsAdmin,
              child: Visibility(
                visible: !(controller.employee.isHired ?? false),
                child: controller.shortlistController.getIcon(
                    employeeId: controller.employee.id!,
                    isFetching: controller.shortlistController.isFetching.value,
                    fromWhere: ''),
              ),
            ),
          ),*/
        ],
      );

  Widget _base(
          {required Widget child,
          required String title,
          String? position,
          String? age,
          double? rating,
          int? totalRating,
          String? nationality,
          bool? certified,
          String? phone}) =>
      Container(
        padding: EdgeInsets.fromLTRB(35.w, 13.h, 35.w, 13.h),
        decoration: BoxDecoration(
          color: MyColors.lightCard(controller.context!),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: .5,
            color: MyColors.c_A6A6A6,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: MyColors.l111111_dwhite(controller.context!).medium16,
                ),
                if (certified != null && certified == true) Image.asset(MyAssets.certified, height: 35, width: 35)
              ],
            ),
            SizedBox(height: 10.h),
            if (phone != null && phone.isNotEmpty && controller.fromWhere == "admin_home_view")
              InkResponse(
                onTap: () => launchUrl(Uri.parse("tel:$phone")),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.phone_solid, color: MyColors.c_C6A34F, size: 20),
                    Text(
                      phone,
                      textAlign: TextAlign.center,
                      style: MyColors.l111111_dwhite(controller.context!).medium15,
                    ),
                  ],
                ),
              ),
            if (phone != null && phone.isNotEmpty && controller.fromWhere == "admin_home_view") SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (position != null && position.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(5.0), bottomRight: Radius.circular(5.0))),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline, size: 15, color: MyColors.white),
                        SizedBox(width: 5.w),
                        Text(
                          position,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: MyColors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 10.w),
                if (nationality != null && nationality.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    decoration: const BoxDecoration(
                        color: Colors.teal,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(5.0), bottomRight: Radius.circular(5.0))),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.flag, size: 15, color: MyColors.white),
                        SizedBox(width: 5.w),
                        Text(
                          nationality,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: MyColors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (position != null && position.isNotEmpty) SizedBox(height: 10.h),
            Visibility(
              visible: age != null,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        age ?? "",
                        textAlign: TextAlign.center,
                        style: MyColors.l7B7B7B_dtext(controller.context!).medium12,
                      ),
                      SizedBox(width: 10.w),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: MyColors.c_FFA800,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "${rating ?? 0.0} (${totalRating ?? 0})",
                        style: MyColors.l111111_dwhite(controller.context!).medium12,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: .5,
              color: MyColors.lD9D9D9_dstock(controller.context!),
            ),
            SizedBox(height: 12.h),
            child,
            SizedBox(height: 5.h),
          ],
        ),
      );

  Widget _data(String icon, String? text) => text == null
      ? Text(
          "No Data Found",
          style: MyColors.l7B7B7B_dtext(controller.context!).regular12,
        )
      : Row(
          children: [
            Image.asset(
              icon,
              width: 14.w,
              height: 14.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                text,
                style: MyColors.l7B7B7B_dtext(controller.context!).regular12,
              ),
            ),
          ],
        );

  Widget _detailsItem(String icon, String title, String value) => Row(
        children: [
          Image.asset(
            icon,
            width: 14.w,
            height: 14.w,
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: MyColors.l7B7B7B_dtext(controller.context!).medium11,
          ),
          SizedBox(width: 3.w),
          Text(
            value,
            style: MyColors.l111111_dwhite(controller.context!).medium11,
          ),
        ],
      );

  Widget get _basicInfo => _base(
        phone: controller.employee.phoneNumber ?? '',
        position: controller.employee.positionName ?? "-",
        title: "${controller.employee.firstName ?? "-"} ${controller.employee.lastName ?? ""}",
        age: 'Age: ${controller.employee.dateOfBirth?.calculateAge() ?? 0.0}',
        rating: controller.employee.rating ?? 0.0,
        totalRating: controller.employee.totalRating ?? 0,
        nationality: controller.employee.nationality ?? '',
        certified: controller.employee.certified,
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Row(
              children: [
                _detailsItem(MyAssets.rate, '${MyStrings.rate.tr}:',
                    "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(controller.employee.hourlyRate?.toStringAsFixed(2) ?? 0)}/hour"),
                const Spacer(),
                _detailsItem(MyAssets.exp, MyStrings.exp.tr, "${(controller.employee.employeeExperience ?? 0)} years"),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _detailsItem(MyAssets.totalHour, '${MyStrings.totalHour.tr}:',
                    "${(controller.employee.totalWorkingHour?.toStringAsFixed(2) ?? 0)}h"),
                const Spacer(),
                _detailsItem(MyAssets.review, MyStrings.review.tr, "1 time"),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _detailsItem(MyAssets.license, MyStrings.licenseNo.tr, controller.employee.licensesNo ?? "-"),
                const Spacer(),
                _detailsItem(MyAssets.calender2, 'Free: ', controller.employee.available ?? "-"),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                _detailsItem(MyAssets.height, 'Height:', controller.employee.height ?? "-"),
                const Spacer(),
                _detailsItem(MyAssets.dressSize, 'Dress Size: ', controller.employee.dressSize ?? "-"),
              ],
            ),
            SizedBox(height: 18.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _detailsItem(
                    MyAssets.organization, 'Current Organization:', controller.employee.currentOrganisation ?? "-"),
              ],
            ),

            SizedBox(height: 5.h),
          ],
        ),
      );

  Widget get _location => _base(
        title: MyStrings.location.tr,
        child: _data(
          MyAssets.location,
          controller.employee.presentAddress ?? "-",
        ),
      );

  Widget get _skill => _base(
        title: 'Skills',
        child: Column(
          children: [
            if ((controller.employee.skills ?? []).isEmpty)
              Text(
                "No Data Found",
                style: MyColors.l7B7B7B_dtext(controller.context!).regular12,
              )
            else
              ...(controller.employee.skills ?? []).map((e) {
                return _data(
                  MyAssets.skill,
                  e.skillName ?? "",
                );
              }),
          ],
        ),
      );
  Widget get _education => _base(
        title: MyStrings.education.tr,
        child: _data(
          MyAssets.education,
          controller.employee.higherEducation,
        ),
      );

  Widget get _certificate => _base(
        title: MyStrings.certificate.tr,
        child: _data(
          MyAssets.education,
          null,
        ),
      );

  Widget get language => _base(
        title: MyStrings.language.tr,
        child: Column(
          children: [
            if ((controller.employee.languages ?? []).isEmpty)
              Text(
                "No Data Found",
                style: MyColors.l7B7B7B_dtext(controller.context!).regular12,
              )
            else
              ...(controller.employee.languages ?? []).map((e) {
                return _data(
                  MyAssets.language,
                  e.capitalize ?? "",
                );
              }),
          ],
        ),
      );

  Widget _bottomBar(BuildContext context) {
    return controller.fromWhere == MyStrings.arg.mhEmployeeViewByIdText
        ? CustomBottomBar(
            child: CustomButtons.button(
              onTap: (controller.employee.available == null ||
                      int.parse(controller.employee.available!.split(' ').first) <= 0)
                  ? null
                  : controller.onBookNowClick,
              text: (controller.employee.available == null ||
                      int.parse(controller.employee.available!.split(' ').first) <= 0)
                  ? "Booked"
                  : "Book Now",
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            ),
          )
        : CustomBottomBar(
            child: CustomButtons.button(
                onTap: controller.onViewCalenderClick,
                text: 'View Calender',
                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner));
  }
}
