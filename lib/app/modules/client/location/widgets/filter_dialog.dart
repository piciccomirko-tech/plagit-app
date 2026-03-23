import '../../../../common/utils/exports.dart';
import '../controllers/nearby_employee_controller.dart';

class FilterDialog extends GetWidget<NearbyEmployeeController> {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                20, // Add padding for keyboard
          ),
          decoration: BoxDecoration(
            color: MyColors.lightCard(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                height: 2,
                width: 50,
                color: MyColors.lightGrey,
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          size: 24,
                          color: MyColors.l111111_dwhite(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: MyAssets.fontMontserrat,
                            color: MyColors.l111111_dwhite(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        controller.isInitialDataLoading.value =
                            true; // Show loading state
                        try {
                          // Reset filter values
                          controller.selectedPosition.value = '';
                          controller.minRateController.text = '';
                          controller.maxRateController.text = '';

                          // Restore original data
                          if (controller.allEmployees.value != null) {
                            controller.employees.value =
                                controller.allEmployees.value!;
                            controller.employees.refresh();

                            // Immediately update markers
                            controller.updateMarkersOnly();
                          }

                          //Get.back(); // Close the dialog
                        } catch (e) {
                          debugPrint('Error resetting filters: $e');
                          Utils.showSnackBar(
                            message: "Error resetting filters.",
                            isTrue: false,
                          );
                        } finally {
                          controller.isInitialDataLoading.value =
                              false; // Hide loading state
                        }
                      },
                      child: Text(
                        'Reset all',
                        style: TextStyle(
                          color: MyColors.c_FF5029,
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: MyColors.c_FF5029,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: MyColors.lightGrey,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Position',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: MyAssets.fontMontserrat,
                    color: MyColors.l111111_dwhite(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: Get.width > 600 ? 92.h : 100,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.positionList.length,
                  itemBuilder: (context, index) {
                    final position = controller.positionList[index];
                    return Obx(() => GestureDetector(
                          onTap: () {
                            controller.selectedPosition.value =
                                position.id ?? "";
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color:
                                            controller.selectedPosition.value ==
                                                    position.id
                                                ? MyColors.primaryLight
                                                    .withOpacity(0.1)
                                                : MyColors.lightCard(context),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: controller
                                                      .selectedPosition.value ==
                                                  position.id
                                              ? MyColors.primaryDark
                                              : MyColors.lightGrey
                                                  .withOpacity(.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: Image.network((position.logo ?? '')
                                          .uniformImageUrl),
                                    ),
                                    if (controller.selectedPosition.value ==
                                        position.id)
                                      Positioned(
                                          top: 0,
                                          right: 1,
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color: MyColors.primaryDark,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: Center(
                                                child: Icon(
                                              Icons.check,
                                              color: MyColors.black,
                                                  size: 15,
                                            )),
                                          )

                                          // Icon(
                                          //   Icons.check_circle,
                                          //   color: MyColors.primaryDark,
                                          //   size: 20,
                                          // )

                                          )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  position.name ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: controller.selectedPosition.value ==
                                            position.id
                                        ? MyColors.primaryDark
                                        : MyColors.lightGrey,
                                    fontFamily: MyAssets.fontMontserrat,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Hourly Rate',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: MyAssets.fontMontserrat,
                    color: MyColors.l111111_dwhite(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: controller.minRateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Min',
                              hintStyle: TextStyle(
                                fontFamily: MyAssets.fontMontserrat,
                              )),
                          onChanged: (value) {
                            // if (value.isNotEmpty) {
                            //   setState(() {
                            //     minRate = double.parse(value.replaceAll('€', ''));
                            //   });
                            // }
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('-'),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: controller.maxRateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Max',
                              hintStyle: TextStyle(
                                fontFamily: MyAssets.fontMontserrat,
                              )),
                          onChanged: (value) {
                            // if (value.isNotEmpty) {
                            //   setState(() {
                            //     maxRate = double.parse(value.replaceAll('€', ''));
                            //   });
                            // }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: Get.width > 600 ? 250.w : 230.w,
                  child: CustomButtons.button(
                      height: Get.width > 600 ? 60 : 50,
                      text: MyStrings.apply.tr,
                      margin: EdgeInsets.zero,
                      fontSize: Get.width > 600 ? 20.sp : 16.sp,
                      customButtonStyle:
                          CustomButtonStyle.radiusTopBottomCorner,
                      onTap: () {
                        controller.mapFilter();
                        // controller.mapSearch();
                      }),
                ),
              ),
            ],
          ),
        ));
  }
}
