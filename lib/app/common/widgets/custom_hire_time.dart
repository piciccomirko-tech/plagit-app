import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/timer_wheel_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../utils/exports.dart';

class CustomHireTime {
  static void show(BuildContext context, Function(String fromTime, String toTime) onSuccessfullyTimeSelect) {
    String fromTime = Utils.getCurrentTimeWithAMPM();
    String toTime = Utils.getCurrentTimeWithAMPM();

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
                _title(context, "From time"),
                TimerWheelWidget(
                  height: 150.h,
                  width: 300.w,
                  centerHighlightColor: MyColors.c_DDBD68.withOpacity(0.4),
                  onTimeChanged: (String time) {
                    fromTime = time;
                  },
                ),
                SizedBox(height: 30.h),
                _title(context, "To time"),
                SizedBox(height: 11.h),
                TimerWheelWidget(
                  height: 150.h,
                  width: 300.w,
                  centerHighlightColor: MyColors.c_DDBD68.withOpacity(0.4),
                  onTimeChanged: (String time) {
                    toTime = time;
                  },
                ),
                SizedBox(height: 30.h),
                CustomButtons.button(
                  text: "Done",
                  onTap: () {
                    if (fromTime == toTime) {
                      CustomDialogue.information(
                        context: context,
                        title: "Invalid Time Range",
                        description: "From-time and To-time should be same",
                      );
                    } else {
                      Get.back(); // hide modal
                      onSuccessfullyTimeSelect(fromTime, toTime);
                    }
                  },
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      // call after close modal
    });
  }

  static Widget _divider(BuildContext context) => Expanded(
        child: Container(
          height: 1,
          color: MyColors.lD9D9D9_dstock(context),
        ),
      );

  static Widget _title(BuildContext context, String text) => Row(
        children: [
          _divider(context),
          SizedBox(width: 10.w),
          Text(
            text,
            style: MyColors.l7B7B7B_dtext(context).semiBold16,
          ),
          SizedBox(width: 10.w),
          _divider(context),
        ],
      );

  /* static void show(BuildContext context, Function(String fromTime, String toTime) onSuccessfullyTimeSelect) {
    int fromTimeHour = 0;
    int fromTimeMin = 0;
    int toTimeHour = 0;
    int toTimeMin = 0;

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

                _title(context, "From time"),

                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      _hourAndMinInWheel(
                        childCount: 24,
                        onItemSelect: (int value) {
                          fromTimeHour = value;
                        },
                        itemBuilder: (context, index) {
                          return _value(context, index);
                        },
                      ),

                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: Text(
                          ":",
                          style: MyColors.l111111_dwhite(context).semiBold24,
                        ),
                      ),

                      _hourAndMinInWheel(
                          childCount: 12,
                          onItemSelect: (int value) {
                            fromTimeMin = value * 5;
                          },
                          itemBuilder: (context, index) {
                            return _value(context, index * 5);
                          },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                _title(context, "To time"),

                SizedBox(height: 11.h),

                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _hourAndMinInWheel(
                          childCount: 24,
                          onItemSelect: (int value) {
                            toTimeHour = value;
                          },
                          itemBuilder: (context, index) {
                            return _value(context, index);
                          },
                      ),
                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: Text(
                          ":",
                          style: MyColors.l111111_dwhite(context).semiBold24,
                        ),
                      ),

                      _hourAndMinInWheel(
                        childCount: 12,
                        onItemSelect: (int value) {
                          toTimeMin = value * 5;
                        },
                        itemBuilder: (context, index) {
                          return _value(context, index * 5);
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                CustomButtons.button(
                  text: "Done",
                  onTap: (){
                    if(fromTimeHour == 0 && fromTimeMin  == 0 && toTimeHour == 0 && toTimeMin  == 0 ) {
                      CustomDialogue.information(
                        context: context,
                        title: "Invalid Time",
                        description: "Your selected time is invalid. Please select valid value",
                      );
                    } else {
                      Get.back(); // hide modal
                      onSuccessfullyTimeSelect("$fromTimeHour:$fromTimeMin", "$toTimeHour:$toTimeMin");
                    }

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
      // call after close modal
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

  static Widget _title(BuildContext context, String text) => Row(
        children: [
          _divider(context),
          SizedBox(width: 10.w),
          Text(
            text,
            style: MyColors.l7B7B7B_dtext(context).semiBold16,
          ),
          SizedBox(width: 10.w),
          _divider(context),
        ],
      );

  static Widget _hourAndMinInWheel({
    required int childCount,
    required Function(int value) onItemSelect,
    required Widget? Function(BuildContext context, int index) itemBuilder,
  }) =>
      SizedBox(
        width: 70,
        child: Center(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 30,
            perspective: .005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onItemSelect,
            childDelegate: ListWheelChildBuilderDelegate(
                childCount: 24,
                builder: itemBuilder,
            ),
          ),
        ),
      );*/
}
