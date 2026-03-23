import 'package:carousel_slider/carousel_slider.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget {
  static Widget clientHomeShimmerWidget() {
    return Shimmer.fromColors(
      baseColor: MyColors.shimmerColor,
      highlightColor: Get.context!.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _customFeatureBoxShimmerWidget(height: 0.3.sw)),
                SizedBox(width: 24.w),
                Expanded(child: _customFeatureBoxShimmerWidget(height: 0.3.sw))
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(child: _customFeatureBoxShimmerWidget(height: 0.3.sw)),
                SizedBox(width: 24.w),
                Expanded(child: _customFeatureBoxShimmerWidget(height: 0.3.sw))
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(child: _customFeatureBoxShimmerWidget(height: 0.3.sw)),
                SizedBox(width: 24.w),
                Expanded(child: _customFeatureBoxShimmerWidget(height: 0.3.sw))
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget socialPostShimmerWidget() {
    return SingleChildScrollView(
      child: Column(
          children: List.generate(3, (index) {
        return Shimmer.fromColors(
            baseColor: MyColors.shimmerColor,
            highlightColor: Get.context!.theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                // Profile image and name placeholder
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.w,
                    left: 15.w,
                    right: 15.w,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image shimmer
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Name and time shimmer
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.grey[300],
                            ),
                            width: 120.0,
                            height: 16.0,
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            width: 60.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                // Content shimmer block
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        height: 16.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: double.infinity,
                        height: 16.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: 100.0,
                        height: 16.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
      })),
    );
  }

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
                Expanded(child: _customFeatureBoxShimmerWidget(height: 120)),
                SizedBox(width: 15.w),
                Expanded(child: _customFeatureBoxShimmerWidget(height: 120)),
                SizedBox(width: 15.w),
                Expanded(child: _customFeatureBoxShimmerWidget(height: 120)),
              ],
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(child: _customFeatureBoxShimmerWidget(height: 120)),
                SizedBox(width: 15.w),
                Expanded(child: _customFeatureBoxShimmerWidget(height: 120)),
                SizedBox(width: 15.w),
                Expanded(child: _customFeatureBoxShimmerWidget(height: 120))
              ],
            ),
            SizedBox(height: 15.h)
          ],
        ),
      ),
    );
  }

  static Widget employeeTodayWorkScheduleShimmerWidget() {
    return Shimmer.fromColors(
        baseColor: MyColors.shimmerColor,
        highlightColor: Get.context!.theme.scaffoldBackgroundColor,
        child: _customContainerShimmerWidget(
            margin: 13.0, height: 130, width: Get.width, borderRadius: 10.0));
  }

  static Widget employeeTodayDashboardShimmerWidget() {
    return Shimmer.fromColors(
        baseColor: MyColors.shimmerColor,
        highlightColor: Get.context!.theme.scaffoldBackgroundColor,
        child: _customContainerShimmerWidget(
            height: 130, width: Get.width, borderRadius: 10.0, margin: 15.0));
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
                _customContainerShimmerWidget(
                    height: 50, width: 350, borderRadius: 30.0),
                const SizedBox(height: 20),
                _customContainerShimmerWidget(
                    height: 120, width: double.infinity, borderRadius: 10.0),
                const SizedBox(height: 50),
                _customContainerShimmerWidget(
                    height: 100, width: double.infinity, borderRadius: 10.0),
                const SizedBox(height: 20),
                _customContainerShimmerWidget(
                    height: 80, width: double.infinity, borderRadius: 10.0),
              ],
            ),
          ),
        ));
  }

  static Widget clientMyEmployeesShimmerWidget({required double height}) {
    return Shimmer.fromColors(
      baseColor: MyColors.shimmerColor,
      highlightColor: Get.context!.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
              5,
              (index) => _customContainerShimmerWidget(
                  height: height,
                  width: double.infinity,
                  borderRadius: 10.0,
                  margin: 15)),
        ),
      ),
    );
  }

  static Widget clientDashboardShimmerEffectWidget() {
    return Shimmer.fromColors(
      baseColor: MyColors.shimmerColor,
      highlightColor: Get.context!.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(15, (index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5.0),
              height: 50.0,
              color: MyColors.primaryDark,
            );
          }),
        ),
      ),
    );
  }

  static Widget clientSubscriptionViewShimmerEffectWidget() {
    return Center(
      child: CarouselSlider.builder(
        itemCount: 3,
        itemBuilder: (context, index, realIndex) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  width: .5,
                  color: MyColors.c_A6A6A6,
                ),
                borderRadius: BorderRadius.circular(20.25),
                color: MyColors.lightCard(Get.context!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 20),
                    Container(height: 43, width: 43, color: Colors.white),
                    SizedBox(height: 20),
                    Container(height: 34, width: 100, color: Colors.white),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(height: 30, width: 50, color: Colors.white),
                        SizedBox(width: 5),
                        Container(height: 17, width: 50, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.grey, thickness: 0.3, endIndent: 5, indent: 5),
                    SizedBox(height: 10),
                    Column(
                      children: List.generate(3, (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(height: 21, width: 21, color: Colors.white),
                            SizedBox(width: 5),
                            Container(height: 18, width: 150, color: Colors.white),
                          ],
                        ),
                      )),
                    ),
                    Spacer(),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: MediaQuery.of(Get.context!).size.height - 230,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          viewportFraction: 0.75,
        ),
      ),
    );
  }

  static Widget employeeJobPostsShimmerWidget(
      {required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: MyColors.shimmerColor,
      highlightColor: Get.context!.theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
              3,
              (index) => Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: _customContainerShimmerWidget(
                        height: height,
                        width: width,
                        borderRadius: 10.0,
                        margin: 15.0),
                  )),
        ),
      ),
    );
  }
}

Widget _customFeatureBoxShimmerWidget({required double height}) {
  return Container(
    height: height,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: MyColors.shimmerColor),
  );
}

Widget _customContainerShimmerWidget(
    {required double height,
    required double width,
    required double borderRadius,
    double? margin}) {
  return Container(
      margin: EdgeInsets.only(top: margin ?? 0.0),
      height: height,
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: MyColors.shimmerColor));
}
