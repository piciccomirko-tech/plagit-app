import 'package:lottie/lottie.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/employee/employee_search/controllers/employee_search_controller.dart';

import '../widgets/employee_premium_position_search_widget.dart';

class EmployeeSearchView extends GetView<EmployeeSearchController> {
  const EmployeeSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      extendBody: false,
      appBar:CustomAppbar.appbar(
          title: MyStrings.searchFeatures.tr,
          context: context,
          visibleBack: false,
          centerTitle: true
      ),
      body: InkWell(
        onTap: ()=>Utils.unFocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Lottie.asset(MyAssets.lottie.searchLottie, height: 200.h, width: Get.width),
                const EmployeePremiumPositionSearchWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
