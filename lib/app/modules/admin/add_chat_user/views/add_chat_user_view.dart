import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
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
        title: Text('Add Chat User', style: MyColors.l111111_dwhite(context).semiBold18),
        bottom: TabBar(
          indicatorColor: MyColors.c_C6A34F,
          labelColor: MyColors.c_C6A34F,
          controller: controller.tabController,
          tabs: const [
            Tab(
              text: 'CLIENT',
            ),
            Tab(
              text: 'EMPLOYEE',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          FirstTab(),
          SecondTab(),
        ],
      ),
    );
  }
}

class FirstTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Content of Tab 1',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class SecondTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Content of Tab 2',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
