import 'package:mh/app/common/utils/exports.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget {
  static Widget employeeHomeShimmerWidget() {
    return Shimmer.fromColors(
      baseColor: MyColors.shimmerColor,
      highlightColor: Get.context!.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _customFeatureBoxShimmerWidget()),
                SizedBox(width: 24.w),
                Expanded(child: _customFeatureBoxShimmerWidget())
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(child: _customFeatureBoxShimmerWidget()),
                SizedBox(width: 24.w),
                Expanded(child: _customFeatureBoxShimmerWidget())
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(child: _customFeatureBoxShimmerWidget()),
                SizedBox(width: 24.w),
                Expanded(child: _customFeatureBoxShimmerWidget())
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget employeeTodayWorkScheduleShimmerWidget() {
    return Shimmer.fromColors(
        baseColor: MyColors.shimmerColor,
        highlightColor: Get.context!.theme.scaffoldBackgroundColor,
        child: _customContainerShimmerWidget(margin: 15.0, height: 160, width: Get.width, borderRadius: 10.0));
  }

  static Widget employeeTodayDashboardShimmerWidget() {
    return Shimmer.fromColors(
        baseColor: MyColors.shimmerColor,
        highlightColor: Get.context!.theme.scaffoldBackgroundColor,
        child: _customContainerShimmerWidget(height: 160, width: Get.width, borderRadius: 10.0, margin: 15.0));
  }

  static Widget bookingDetailsShimmerWidget() {
    return Shimmer.fromColors(
        baseColor: MyColors.shimmerColor,
        highlightColor: Get.context!.theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                _customContainerShimmerWidget(height: 50, width: 350, borderRadius: 30.0),
                const SizedBox(height: 20),
                _customContainerShimmerWidget(height: 120, width: double.infinity, borderRadius: 10.0),
                const SizedBox(height: 50),
                _customContainerShimmerWidget(height: 100, width: double.infinity, borderRadius: 10.0),
                const SizedBox(height: 20),
                _customContainerShimmerWidget(height: 80, width: double.infinity, borderRadius: 10.0),
              ],
            ),
          ),
        ));
  }

  static Widget clientMyEmployeesShimmerWidget(){
    return Shimmer.fromColors(
      baseColor: MyColors.shimmerColor,
      highlightColor: Get.context!.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(10, (index) => _customContainerShimmerWidget(height: 125, width: double.infinity, borderRadius: 10.0, margin: 15)),
        ),
      ),
    );
  }
}

Widget _customFeatureBoxShimmerWidget() {
  return Container(
    height: 150,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: MyColors.shimmerColor),
  );
}

Widget _customContainerShimmerWidget(
    {required double height, required double width, required double borderRadius, double? margin}) {
  return Container(
      margin: EdgeInsets.only(bottom: margin ?? 0.0),
      height: height,
      width: width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), color: MyColors.shimmerColor));
}
