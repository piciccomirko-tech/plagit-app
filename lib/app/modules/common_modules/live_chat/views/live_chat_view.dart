import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/modules/common_modules/live_chat/widgets/conversation_widget.dart';
import 'package:mh/app/modules/common_modules/live_chat/widgets/message_type_widget.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../controllers/live_chat_controller.dart';

class LiveChatView extends GetView<LiveChatController> {
  const LiveChatView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return WillPopScope(
      onWillPop: () async {
        controller.onBackPressed;
        if (!controller.messageLoaded.value) {
          return false; // Prevent back navigation
        }
        return true;
      },

      // onPopInvokedWithResult: ,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(ResponsiveHelper.isTab(Get.context)? 0.07.sw : 54),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0XFF000000).withOpacity(.08),
                  offset: const Offset(0, 3),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: AppBar(
              backgroundColor: MyColors.lightCard(context),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10.0),
                ),
              ),
              leading: Obx(
                () => Align(
                  child: controller.messageLoaded.value
                      ? CustomAppbarBackButton()
                      : Container(
                    margin:  EdgeInsets.all(ResponsiveHelper.isTab(Get.context)?10:0),
                          height: 25.sp,
                          width: 25.sp,
                          decoration: BoxDecoration(
                            color: MyColors.lightGrey,
                            borderRadius: BorderRadius.circular(3.86),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: ResponsiveHelper.isTab(Get.context)?10.sp:16.sp,
                            ),
                          ),
                        ),
                ),
              ),
              centerTitle: true,
              title: InkWell(
                onTap: () {
                  if (controller.liveChatDataTransferModel.role == 'EMPLOYEE') {
                    Get.toNamed(
                      Routes.employeeDetails,
                      arguments: {
                        'employeeId':
                            controller.liveChatDataTransferModel.toId,
                      },
                    );
                  } else if (controller.liveChatDataTransferModel.role ==
                      'CLIENT') {
                    // Create the ClientId object
                    ClientId clientId = ClientId(
                      id: controller.liveChatDataTransferModel.toId,
                      role: 'CLIENT',

                      // countryName: controller.liveChatDataTransferModel.to ??
                      //     '',
                      restaurantName:
                          controller.liveChatDataTransferModel.toName,

                      profilePicture: (controller
                                  .liveChatDataTransferModel.toProfilePicture)
                          .imageUrl,
                      name: controller.liveChatDataTransferModel.toName,
                    );

                    // log("profuile img url: ${controller.employeePaymentHistoryList[index].restaurantDetails?.profilePicture?.imageUrl ?? ''}");
                    Get.toNamed(Routes.individualSocialFeeds,
                        arguments: controller.clientIdToSocialUser(clientId));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(top: Get.width > 600 ? 10 : 0),
                  child: Row(
                    children: [
                      Obx(()=>controller.loadingUserInfo.value?Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 19,
                  ),
                )
                    : CircleAvatar(
                        backgroundColor: MyColors.primaryLight,
                        radius: 19,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: controller.appController.user.value.isAdmin && controller.clientProfilePicUrl.value==''
                              ? controller.toUserTypeIsCandidate.value?AssetImage( MyAssets.employeeDefault):AssetImage( MyAssets.clientDefault):
                              controller.clientProfilePicUrl.value==''
                              ? AssetImage( MyAssets.adminDefault)
                              : NetworkImage((controller.clientProfilePicUrl.value).imageUrl),
                        ),
                      ),),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(controller.liveChatDataTransferModel.toName,
                            style: Get.width > 600
                                ? MyColors.l111111_dwhite(context).semiBold10
                                : MyColors.l111111_dwhite(context).semiBold16,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
               Obx(()=> controller.textNeedToBeCopied.value.isNotEmpty?IconButton(onPressed: (){controller.copyToClipboard();}, icon: Icon(Icons.copy)):SizedBox.shrink())
              ],
            ),
          ),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: ConversationWidget()),
            MessageTypeWidget(),
          ],
        ),
      ),
    );
  }
}
