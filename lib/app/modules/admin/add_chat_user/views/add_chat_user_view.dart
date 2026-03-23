import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/modules/admin/add_chat_user/widgets/client_chat_user.dart';
import 'package:mh/app/modules/admin/add_chat_user/widgets/employee_chat_user.dart';
import '../controllers/add_chat_user_controller.dart';

class AddChatUserView extends GetView<AddChatUserController> {
  const AddChatUserView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: AppBar(
        leading: const Align(child: CustomAppbarBackButton()),
        backgroundColor: MyColors.lightCard(context),
        title: Text(MyStrings.addChatUser.tr, style: MyColors.l111111_dwhite(context).semiBold18),
        bottom: TabBar(
          indicatorColor: MyColors.c_C6A34F,
          dividerColor: MyColors.c_C6A34F,
          labelColor: MyColors.c_C6A34F,
          controller: controller.tabController,
          tabs:  [
            Tab(
              text: MyStrings.client.toUpperCase().tr,
            ),
            Tab(
              text: MyStrings.employee.toUpperCase().tr,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: const [
          ClientChatUser(),
          EmployeeChatUser(),
        ],
      ),
    );
  }
}
