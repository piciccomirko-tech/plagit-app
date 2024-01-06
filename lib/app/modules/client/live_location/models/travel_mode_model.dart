import 'package:mh/app/common/utils/exports.dart';

class TravelModeModel {
  final String icon;
  final String title;
  TravelModeModel({required this.icon, required this.title});
}

RxList<TravelModeModel> travelModeList = <TravelModeModel>[
  TravelModeModel(icon: MyAssets.driving, title: "Driving"),
  TravelModeModel(icon: MyAssets.walking, title: "Walking"),
  TravelModeModel(icon: MyAssets.biCycling, title: "Bicycling"),
  TravelModeModel(icon: MyAssets.transit, title: "Transit"),
].obs;
