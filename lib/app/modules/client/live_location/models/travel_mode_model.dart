import 'package:mh/app/common/utils/exports.dart';

class TravelModeModel {
  final String icon;
  final String title;
  bool? isSelected;
  TravelModeModel({required this.icon, required this.title, this.isSelected});
}

RxList<TravelModeModel> travelModeList = <TravelModeModel>[
  TravelModeModel(icon: MyAssets.driving, title: "Driving", isSelected: true),
  TravelModeModel(icon: MyAssets.walking, title: "Walking"),
  TravelModeModel(icon: MyAssets.biCycling, title: "Bicycling"),
  TravelModeModel(icon: MyAssets.transit, title: "Transit"),
].obs;
