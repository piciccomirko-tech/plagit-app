import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar_back_button.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../controllers/client_employee_chat_controller.dart';

class ClientEmployeeChatView extends GetView<ClientEmployeeChatController> {
  const ClientEmployeeChatView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(54.h),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: const Color(0XFF000000).withOpacity(.08),
              offset: Offset(0, 3.h),
              blurRadius: 10.0,
            )
          ]),
          child: AppBar(
            backgroundColor: MyColors.lightCard(context),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10.0),
              ),
            ),
            elevation: 0,
            leading: const Align(child: CustomAppbarBackButton()),
            centerTitle: true,
            title: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    controller.receiverName,
                    style: MyColors.l111111_dwhite(context).semiBold18,
                  ),
                  Visibility(
                      visible: controller.isReceiverOnline.value,
                      child: Container(
                        height: 10,
                        width: 10,
                        margin: const EdgeInsets.only(left: 5),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.loading.value
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: MyColors.c_C6A34F,
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: controller.messageCollection.orderBy('time').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          const Center(
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: MyColors.c_C6A34F,
                            ),
                          );
                        }

                        if ((snapshot.data?.docs ?? []).isEmpty) {
                          return Center(
                            child: Text(
                              "No Massage",
                              style: MyColors.text.regular14,
                            ),
                          );
                        }

                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          controller.setMassagePosition();
                        });

                        return ListView.builder(
                          controller: controller.scrollController,
                          itemCount: (snapshot.data?.docs ?? []).length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data = snapshot.data!.docs[index].data()! as Map<String, dynamic>;

                            double topMargin = 0;

                            if (index > 0) {
                              Map<String, dynamic> previousData =
                                  snapshot.data!.docs[index - 1].data()! as Map<String, dynamic>;
                              if (previousData["fromId"] != data["fromId"]) {
                                topMargin = 20;
                              }
                            }

                            return _msg(
                              fromId: data["fromId"],
                              text: data["text"],
                              lastItem: (snapshot.data?.docs ?? []).length - 1 == index,
                              topMargin: topMargin,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
          Obx(
            () => Padding(
              padding: EdgeInsets.only(bottom: controller.appController.bottomPadding.value),
              child: CustomBottomBar(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: 54.w,
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(color: Color.fromRGBO(8, 56, 73, 0.5)),
                              BoxShadow(
                                offset: Offset(0, .5),
                                blurRadius: 1,
                                color: Color(0xFFF9F8F9),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(25),
                            color: MyColors.lnull_d111111(context),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextField(
                              controller: controller.tecController,
                              cursorColor: MyColors.l111111_dwhite(context),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: MyColors.l111111_dwhite(context).regular16,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Message",
                                hintStyle: MyColors.text.regular16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: controller.onSendTap,
                        child: Container(
                          width: 54.w,
                          height: 54.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.c_C6A34F,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Transform.translate(
                              offset: const Offset(-2, 2),
                              child: Image.asset(
                                MyAssets.msgSend,
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _msg({
    required String fromId,
    required String text,
    required bool lastItem,
    required double topMargin,
  }) {
    return Column(
      children: [
        // _msgDate(msg.createdAt!),

        fromId == controller.fromId ? _senderMsg(text, topMargin) : _receiverMsg(text, topMargin),

        Visibility(
          visible: lastItem,
          child: const SizedBox(
            height: 100,
          ),
        )
      ],
    );
  }

  Widget _senderMsg(String msg, double topMargin) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14).copyWith(
            bottom: 5,
            left: Get.width * .2,
            top: topMargin,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
              color: MyColors.c_C6A34F,
              border: Border.all(color: MyColors.c_C6A34F),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              )),
          child: Text(
            msg,
            style: MyColors.white.regular15,
          ),
        ),
      );

  Widget _receiverMsg(String msg, double topMargin) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14).copyWith(
            bottom: 5,
            right: Get.width * .2,
            top: topMargin,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
              color: MyColors.lightCard(controller.context!),
              border: Border.all(color: MyColors.c_C6A34F),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
          child: Text(
            msg,
            style: MyColors.l111111_dwhite(controller.context!).regular15,
          ),
        ),
      );
}
