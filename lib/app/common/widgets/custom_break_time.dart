import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../modules/employee/employee_home/controllers/employee_home_controller.dart';
import '../utils/exports.dart';

class  CustomBreakTime {
  static void show(BuildContext context, Function(int hour, int min) onBreakTimePickDone) {
    int hour = 0;
    int min = 0;

    showMaterialModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: MyColors.lightCard(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 19.h),

                Center(
                  child: Container(
                    height: 4.h,
                    width: 80.w,
                    decoration: const BoxDecoration(
                      color: MyColors.c_5C5C5C,
                    ),
                  ),
                ),

                SizedBox(height: 19.h),

                Row(
                  children: [
                    _divider(context),

                    SizedBox(width: 10.w),

                    Text(
                      "Break Time",
                      style: MyColors.l7B7B7B_dtext(context).semiBold16,
                    ),

                    SizedBox(width: 10.w),

                    _divider(context),
                  ],
                ),

                SizedBox(
                  height: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Center(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            perspective: .005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (int value) {
                              hour = value;
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 4,
                                builder: (context, index) {
                                  return _value(context, index);
                                }),
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -13),
                        child: Text(
                          "Hour",
                          style: MyColors.l111111_dwhite(context).regular14,
                        ),
                      ),

                      SizedBox(
                        width: 70,
                        child: Center(
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 50,
                            perspective: .005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (int value) {
                              min = value * 5;
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (context, index) {
                                  return _value(context, index * 5);
                                }),
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -13),
                        child: Text(
                          "Min",
                          style: MyColors.l111111_dwhite(context).regular14,
                        ),
                      ),
                    ],
                  ),
                ),

                CustomButtons.button(
                  text: "Done",
                  onTap: (){
                    Navigator.pop(context); // hide modal
                    onBreakTimePickDone(hour, min);
                  },
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                ),

                SizedBox(height: 11.h),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      Get.find<EmployeeHomeController>().resetSlider();
    });
  }

  static Widget _divider(BuildContext context) => Expanded(
        child: Container(
          height: 1,
          color: MyColors.lD9D9D9_dstock(context),
        ),
      );

  static Widget _value(BuildContext context, int value) => Text(
        value.toString(),
        style: MyColors.l111111_dwhite(context).semiBold22,
      );
}
