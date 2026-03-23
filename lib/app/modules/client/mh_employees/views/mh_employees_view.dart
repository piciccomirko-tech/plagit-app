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
        title: " ${MyStrings.candidates.tr}",
        context: context,
        visibleMH: true,
        visibleBack: true,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GridView.builder(
          itemCount: controller.positionList.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            return _item(controller.positionList[index]);
          },
        ),
      )
      ,
    );
  }

  Widget _item(DropdownItem position) {
    return Center(
      child: Container(
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
                  style: Get.width>600?MyColors.l111111_dwhite(controller.context!).medium12:MyColors.l111111_dwhite(controller.context!).medium14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
