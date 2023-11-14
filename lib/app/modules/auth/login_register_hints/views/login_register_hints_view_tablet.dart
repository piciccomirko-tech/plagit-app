import '../../../../common/utils/exports.dart';
import '../controllers/login_register_hints_controller.dart';

class LoginRegisterHintsViewTablet extends GetView<LoginRegisterHintsController> {
  const LoginRegisterHintsViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Text("Tablet"),
    );
  }
}
