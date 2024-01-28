import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/models/dropdown_item.dart';

import '../../../../common/style/my_decoration.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controllers/mh_employees_controller.dart';

class MhEmployeesView extends GetView<MhEmployeesController> {
  const MhEmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: " ${MyStrings.employees.tr}",
        context: context,
        visibleMH: true,
        visibleBack: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: Get.width -
                    (20 +
                        20 // horizontal padding (left + right)
                        +
                        182.w +
                        182.w // item width (2 items)
                    ),
                runSpacing: 20,
                children: [
                  ...controller.positionList.map((DropdownItem e) {
                    return _item(e);
                  }),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(DropdownItem position) {
    return Container(
      width: 182.w,
      height: 112.w,
      decoration: MyDecoration.cardBoxDecoration(context: controller.context!),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () => controller.onPositionClick(position),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50.w,
                height: 50.w,
                child: CustomNetworkImage(url: (position.logo ?? '').uniformImageUrl),
              ),
              SizedBox(height: 9.h),
              Text(
                position.name ?? "-",
                style: MyColors.l111111_dwhite(controller.context!).medium14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
