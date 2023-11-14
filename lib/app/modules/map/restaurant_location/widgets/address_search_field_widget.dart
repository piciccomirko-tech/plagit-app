import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/map/restaurant_location/controllers/restaurant_location_controller.dart';

class AddressSearchFieldWidget extends GetWidget<RestaurantLocationController> {
  const AddressSearchFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: TextFormField(
        controller: controller.tecAutoCompleteSearch,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        cursorColor: MyColors.c_C6A34F,
        autofocus: true,
        decoration: InputDecoration(
          isDense: true,
          suffixIcon: Obx(() => controller.autoCompleteSearchQuery.value.isNotEmpty
              ? InkWell(onTap: controller.onClearClick, child: Icon(Icons.clear, color: Colors.grey.shade600))
              : const Wrap()),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 35,
            minHeight: 35,
          ),
          prefixIcon: Icon(CupertinoIcons.location_solid, color: Colors.grey.shade600, size: 20),
          hintText: "Search your desired location...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          //contentPadding: 8.topPadding,
        ),
        keyboardType: TextInputType.text,
        onChanged: controller.onAddressSearch,
      )
    );
  }
}
