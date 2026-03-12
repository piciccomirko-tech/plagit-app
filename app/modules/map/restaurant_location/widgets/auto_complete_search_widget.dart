import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/map/restaurant_location/controllers/restaurant_location_controller.dart';

class AutoCompleteSearchWidget extends GetWidget<RestaurantLocationController> {
  const AutoCompleteSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.autoCompleteDataLoaded.value == false) {
        return Container();
      } else if (controller.autoCompleteDataLoaded.value == true && controller.googleAutoCompleteSearchList.isEmpty) {
        return Container();
      } else {
        return Container(
          height: 450,
          margin: const EdgeInsets.only(top: 80.0),
          padding: const EdgeInsets.only(top: 30.0),
          decoration: BoxDecoration(color: Colors.grey.shade900),
          child: Center(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: controller.googleAutoCompleteSearchList.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        radius: 18,
                        backgroundColor: MyColors.c_C6A34F,
                        child: Icon(
                          CupertinoIcons.location,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                      title: Text(
                        controller.googleAutoCompleteSearchList[index].mainText ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        controller.googleAutoCompleteSearchList[index].secondaryText ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () => controller.onAddressClick(
                          addressText:
                              '${controller.googleAutoCompleteSearchList[index].mainText}, ${controller.googleAutoCompleteSearchList[index].secondaryText}'),
                    ),
                    Divider(
                      color: Colors.grey.shade800,
                      height: 1.0,
                      thickness: 1.0,
                      indent: 70,
                      endIndent: 10,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    });
  }
}
