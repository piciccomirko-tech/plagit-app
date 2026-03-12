import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/modules/client/live_location/controllers/live_location_controller.dart';
import 'package:mh/app/modules/client/live_location/models/travel_mode_model.dart';
import 'package:mh/app/modules/client/live_location/widgets/travel_mode_widget.dart';

class TravelMode extends GetWidget<LiveLocationController> {
  const TravelMode({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
            children: List.generate(
                travelModeList.length, (int index) => TravelModeWidget(travelMode: travelModeList[index])),
          )),
    );
  }
}
