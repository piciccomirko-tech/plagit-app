import 'package:mh/app/common/widgets/no_item_found.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controllers/admin_client_request_controller.dart';

class AdminClientRequestView extends GetView<AdminClientRequestController> {
  const AdminClientRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: MyStrings.requests.tr,
      ),
      body: Obx(
        () => (controller.adminHomeController.requestedEmployees.value.requestEmployeeList ?? []).isEmpty ||
                controller.adminHomeController.numberOfRequestFromClient == 0
            ? const NoItemFound()
            : ListView.builder(
                itemCount: (controller.adminHomeController.requestedEmployees.value.requestEmployeeList ?? []).length,
                itemBuilder: (context, index) {
                  return int.parse(controller.getSuggested(index).split(' ')[2]) > 0 ? const Wrap() : _item(index);
                },
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              ),
      ),
    );
  }

  Widget _item(int index) => GestureDetector(
        onTap: () => controller.onItemClick(index),
        child: Container(
          margin:  EdgeInsets.all(14.sp).copyWith(top: 0.sp, bottom: 12.sp),
          padding:  EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: MyColors.lightCard(controller.context!),
            border: Border.all(
              width: .5,
              color: MyColors.c_A6A6A6,
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.getRestaurantName(index),
                    style: Get.width>600?MyColors.l111111_dtext(controller.context!).semiBold13:MyColors.l111111_dtext(controller.context!).semiBold16,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    controller.getSuggested(index),
                    style: Get.width>600?MyColors.l7B7B7B_dtext(controller.context!).regular9:MyColors.l7B7B7B_dtext(controller.context!).regular12,
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Container(
                    padding:  EdgeInsets.all(7.sp),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyColors.c_C6A34F.withOpacity(.1),
                    ),
                    child:  Icon(
                      Icons.arrow_forward,
                      size: 15.w,
                      color: MyColors.c_C6A34F,
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () => controller.onCancelClick(
                        requestId:
                            controller.adminHomeController.requestedEmployees.value.requestEmployeeList?[index].id ?? ''),
                    child:  Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 25.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
