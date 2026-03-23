import 'package:cached_network_image/cached_network_image.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/admin/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/admin/chat_it/models/chat_it_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../helpers/responsive_helper.dart';

class ChatUserWidget extends StatelessWidget {
  final Conversation conversation;

  const ChatUserWidget({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return (conversation.members ?? []).isNotEmpty
        ? GestureDetector(
            onLongPress: () => Get.find<ChatItController>()
                .onLongTapped(conversationId: conversation.id ?? ""),
            onTap: () => Get.find<ChatItController>().onUserTapped(
              id:conversation.id.toString(),
                member: (conversation.members ?? []).first,
                isAdmin: conversation.isAdmin ?? false),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: MyColors.lightCard(context),
                  border: Border.all(color: MyColors.noColor, width: 0.5)),
              margin: EdgeInsets.only(bottom: 10.h),
              padding:
                  EdgeInsets.symmetric(vertical: Get.width > 600 ? 15.h : 5.h),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 10.sp),
                leading: CircleAvatar(
                  backgroundColor: MyColors.primaryLight,
                  radius: 26,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.transparent,
                    backgroundImage: Get.find<ChatItController>()
                            .checkAdmin(isAdmin: conversation.isAdmin ?? false)
                        ? AssetImage(MyAssets.adminDefault)
                        : (((conversation.members ?? []).first.profilePicture ??
                                        "")
                                    .isEmpty ||
                                ((conversation.members ?? [])
                                        .first
                                        .profilePicture ==
                                    "undefined"))
                            ? AssetImage((conversation.members ?? [])
                                        .first
                                        .role
                                        ?.toUpperCase() ==
                                    "CLIENT"
                                ? MyAssets.clientDefault
                                : MyAssets.employeeDefault)
                            : CachedNetworkImageProvider(((conversation.members ?? [])
                                        .first
                                        .profilePicture ??
                                    "")
                                .imageUrl),
                  ),
                ),
                title: Text(
                    Get.find<ChatItController>()
                            .checkAdmin(isAdmin: conversation.isAdmin ?? false)
                        ? "Support"
                        : (conversation.members ?? []).first.name ?? "",
                    style: Get.width > 600
                        ? MyColors.l111111_dwhite(context).semiBold10
                        : MyColors.l111111_dwhite(context).semiBold17),
                subtitle: conversation.latestMessage?.senderDetails!=null?conversation.latestMessage?.senderDetails?.id ==
                        Get.find<AppController>().user.value.userId
                    ? Text(
                        "${MyStrings.you.tr}: ${conversation.latestMessage?.text ?? MyStrings.noMessage.tr}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ResponsiveHelper.isTab(context)?MyColors.lightGrey.regular9:MyColors.lightGrey.regular14)
                    : Text(
                    conversation.latestMessage?.senderDetails?.name!=null?
                    "${conversation.latestMessage?.senderDetails?.name}: ${conversation.latestMessage?.text ?? MyStrings.noMessage.tr}":
                    conversation.latestMessage?.text ?? MyStrings.noMessage.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ResponsiveHelper.isTab(context)?MyColors.lightGrey.regular9:MyColors.lightGrey.regular14)
                    : Text( MyStrings.noMessage.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ResponsiveHelper.isTab(context)?MyColors.lightGrey.regular9:MyColors.lightGrey.regular14),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if ((conversation.unreadMsg ?? 0) > 0)
                       CircleAvatar(
                        backgroundColor: MyColors.primaryLight,
                          radius: conversation.unreadMsg! >9?12:8,
                          child:Text( "${conversation.unreadMsg}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MyColors.white.regular9.copyWith(fontWeight: FontWeight.bold,fontSize: ResponsiveHelper.isTab(context)?14:10))
                      ),
                    Flexible(
                      child: Text(
                        timeago.format(
                            conversation.latestMessage?.dateTime ??
                            conversation.createdAt ??
                            DateTime.now()),
                          style: Get.width > 600
                              ? (MyColors.lightGrey.regular13)
                                  .copyWith(fontSize: 10)
                              : (MyColors.lightGrey.regular12)
                                  .copyWith(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const Wrap();
  }
}
