import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_search/controllers/client_search_controller.dart';

class ClientSearchItemWidget extends GetWidget<ClientSearchController> {
  const ClientSearchItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
        visible: Get.find<ClientHomeController>().positionList.isNotEmpty,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  topLeft: Radius.circular(15.0)
              ),
              color: MyColors.lightCard(context)),
          child: ListView.builder(
              itemCount: Get.find<ClientHomeController>().positionList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                DropdownItem position =
                Get.find<ClientHomeController>().positionList[index];
                return ListTile(
                  onTap: () => Get.find<ClientHomeController>()
                      .onSearchItemTap(position: position),
                  leading: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CustomNetworkImage(
                        url: (position.logo ?? '').uniformImageUrl),
                  ),
                  title: Text(position.name ?? '',
                      style: MyColors.l111111_dwhite(context).semiBold16),
                  trailing: const Icon(CupertinoIcons.arrow_up_left,
                      color: MyColors.c_C6A34F),
                );
              }),
        ))
    );
  }
}
