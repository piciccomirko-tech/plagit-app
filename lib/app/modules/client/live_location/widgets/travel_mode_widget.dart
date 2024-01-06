import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/live_location/controllers/live_location_controller.dart';
import 'package:mh/app/modules/client/live_location/models/travel_mode_model.dart';

class TravelModeWidget extends StatelessWidget {
  final TravelModeModel travelMode;
  const TravelModeWidget({super.key, required this.travelMode});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => Get.find<LiveLocationController>().onTravelModeTap(mode: travelMode.title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
            color: travelMode.isSelected == true ? Colors.blue : Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(20.0)),
        child: Row(
          children: [
            Image.asset(travelMode.icon, height: 20, width: 20),
            const SizedBox(width: 5),
            Text(travelMode.title, style: MyColors.black.semiBold13)
          ],
        ),
      ),
    );
  }
}
