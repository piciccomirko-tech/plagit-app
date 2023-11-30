import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/admin/admin_home/models/admin_home_card_model.dart';

class AdminHomeCardWidget extends StatelessWidget {
  final AdminHomeCardModel adminHomeCardModel;
  final int index;
  const AdminHomeCardWidget({super.key, required this.adminHomeCardModel, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: adminHomeCardModel.onTap,
      child: Stack(
        children: [
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, adminHomeCardModel.backgroundColor],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  stops: const [0.1, 0.9],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.circular(10.0),
              //color: adminHomeCardModel.backgroundColor
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(adminHomeCardModel.title, style: MyColors.white.semiBold20),
                Image.asset(
                  adminHomeCardModel.icon,
                  height: 60,
                  width: 60,
                )
              ],
            ),
          ),
          Positioned.fill(
              child: Align(
            alignment: Alignment.topLeft,
            child: Obx(() => Visibility(
                visible: index == 1 && Get.find<AdminHomeController>().numberOfRequestFromClient > 0,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                      backgroundColor: MyColors.c_C6A34F,
                      radius: 10,
                      child: Text(Get.find<AdminHomeController>().numberOfRequestFromClient.toString(),
                          style: MyColors.white.semiBold15)),
                ))),
          )),
          Positioned.fill(
              child: Align(
            alignment: Alignment.topLeft,
            child: Obx(() => Visibility(
                visible: index == 2 && Get.find<AdminHomeController>().unreadMsgFromEmployee.value > 0,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                      backgroundColor: MyColors.c_C6A34F,
                      radius: 10,
                      child: Text(Get.find<AdminHomeController>().unreadMsgFromEmployee.toString(),
                          style: MyColors.white.semiBold15)),
                ))),
          )),
          Positioned.fill(
              child: Align(
            alignment: Alignment.topLeft,
            child: Obx(() => Visibility(
                visible: index == 3 && Get.find<AdminHomeController>().unreadMsgFromClient.value > 0,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                      backgroundColor: MyColors.c_C6A34F,
                      radius: 10,
                      child: Text(Get.find<AdminHomeController>().unreadMsgFromClient.toString(),
                          style: MyColors.white.semiBold15)),
                ))),
          ))
        ],
      ),
    );
  }
}
