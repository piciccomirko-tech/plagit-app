import 'package:lottie/lottie.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controllers/client_notification_controller.dart';

class ClientNotificationView extends GetView<ClientNotificationController> {
  const ClientNotificationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "Notification",
        context: context,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(MyAssets.lottie.noNotification),

          Center(child: Text("No Notification", style: MyColors.l111111_dwhite(context).semiBold22,)),
        ],
      ),
    );
  }
}
