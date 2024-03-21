import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';

class ClientBottomNavBarWidget extends GetWidget<ClientHomeController> {
  const ClientBottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(30.0), topLeft: Radius.circular(30.0)),
      child: BottomAppBar(
        elevation: 20,
        surfaceTintColor: MyColors.lightCard(context),
        shadowColor: MyColors.c_A6A6A6,
        color: MyColors.lightCard(context),
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(),
          StadiumBorder(side: BorderSide(color: MyColors.c_A6A6A6)),
        ),
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkResponse(
              onTap: controller.onHelpAndSupportClick,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(MyAssets.support, height: 25, width: 25),
                  Text(MyStrings.helpSupport.tr.split("&").last)
                ],
              ),
            ),
            const SizedBox(), // This is the space for the notch
            InkResponse(
              onTap: () => controller.onProfileTapped(context: context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Image.asset(MyAssets.user, height: 25, width: 25), Text(MyStrings.profile.tr)],
              ),
            )
          ],
        ),
      ),
    );
  }
}
