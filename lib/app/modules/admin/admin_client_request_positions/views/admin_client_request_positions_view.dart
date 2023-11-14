import 'package:mh/app/models/dropdown_item.dart';

import '../../../../common/style/my_decoration.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controllers/admin_client_request_positions_controller.dart';

class AdminClientRequestPositionsView extends GetView<AdminClientRequestPositionsController> {
  const AdminClientRequestPositionsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: 'Requested Positions',
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
                spacing: Get.width - (
                    20 + 20 // horizontal padding (left + right)
                        + 182.w + 182.w // item width (2 items)
                ),
                runSpacing: 20,
                children: [
                  ...controller.positions.map(( DropdownItem e) {
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
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      position.logo!,
                      width: 50.w,
                      height: 50.w,
                    ),

                    SizedBox(height: 9.h),

                    Text(
                      position.name ?? "-",
                      style: MyColors.l111111_dwhite(controller.context!).medium14,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10)
                    ),
                    color: MyColors.c_C6A34F,
                  ),
                  child: Text(
                    controller.getSuggested(position),
                    style: MyColors.white.regular12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
