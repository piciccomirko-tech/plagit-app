import 'package:mh/app/common/app_info/app_info.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/horizontal_divider_with_text.dart';
import '../controllers/login_register_hints_controller.dart';

class LoginRegisterHintsViewPhone extends GetView<LoginRegisterHintsController> {
  const LoginRegisterHintsViewPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body:  Column(
        children: [
            HorizontalDividerWithText(
              text: AppInfo.appName.toUpperCase(),
            ),
          ],
      )
    );
  }
}
