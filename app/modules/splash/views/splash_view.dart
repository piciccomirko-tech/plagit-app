import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import '../../../common/utils/exports.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {

    controller.context = context;
    StorageHelper.setLanguage = "en";

    return WillPopScope(
      onWillPop: () async => Utils.appExitConfirmation(context),
      child: Scaffold(
        body: Center(child: CustomLoader.loading()),
      ),
    );
  }
}
