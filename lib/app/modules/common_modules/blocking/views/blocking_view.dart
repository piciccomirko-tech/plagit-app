import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';

import '../../../../common/data/data.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/employees_by_id.dart';
import '../controllers/blocking_controller.dart';

class BlockingView extends GetView<BlockingController> {
  const BlockingView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.blocking.tr,
        context: context,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 40.h),
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getBlockingList();
          },
          child: Obx(
            () => controller.isLoading.value
                ? Center(child: ShimmerWidget.socialPostShimmerWidget())
                : controller.isLoading.value == false &&
                        controller.blockedUserList.isEmpty
                    ? Center(child: NoItemFound())
                    : ListView.builder(
                        itemCount: controller.blockedUserList.length,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        primary: false,
                        padding: EdgeInsets.zero,
                        itemBuilder: (BuildContext context, int index) {
                          BlockUsersModel user =
                              controller.blockedUserList[index];
                          return ListTile(
                            onTap: () {},
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: user.profilePicture == null &&
                                        user.profilePicture == "undefined"
                                    ? user.role?.toUpperCase() == "EMPLOYEE"
                                        ? Image.asset(
                                            MyAssets.employeeDefault,
                                            fit: BoxFit.cover,
                                            width: 48,
                                            height: 48,
                                          )
                                        : user.role?.toUpperCase() == "CLIENT"
                                            ? Image.asset(
                                                MyAssets.clientDefault,
                                                fit: BoxFit.cover,
                                                width: 48,
                                                height: 48,
                                              )
                                            : Image.asset(
                                                MyAssets.adminDefault,
                                                fit: BoxFit.cover,
                                                width: 48,
                                                height: 48,
                                              )
                                    : Image.network(
                                        "https://mh-user-bucket.s3.amazonaws.com/public/users/profile/${user.profilePicture}",
                                        fit: BoxFit.cover,
                                        width:
                                            48, // Ensure the image fits within the circle
                                        height: 48,
                                      ),
                              ),
                            ),
                            title: user.restaurantName == null
                                ? Text(
                                    '${user.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    '${user.restaurantName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            subtitle: Row(
                              children: [
                                if (user.role?.toUpperCase() == "EMPLOYEE") ...[
                                  Text(
                                    ("${user.positionName} . "),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MyColors.l111111_dwhite(context)
                                        .regular11,
                                  ),
                                  SizedBox(width: 15.w),
                                ],
                                SvgPicture.network(
                                  Data.getCountryFlagByName(
                                      user.countryName.toString()),
                                  width: 10,
                                  height: 10,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    ("${user.countryName}").toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: MyColors.l111111_dwhite(context)
                                        .regular11,
                                  ),
                                ),
                              ],
                            ), // Replace with user status
                            trailing: controller.selectedIndex.value == index &&
                                    controller.isUnBlocking.value
                                ? CupertinoActivityIndicator()
                                : InkWell(
                                    onTap: () {
                                      controller.unblockUser(user.id, index);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5),
                                          ),
                                          border: Border.all(
                                              color: MyColors.primaryLight,
                                              width: 1.5)),
                                      padding: EdgeInsets.all(8),
                                      child: Text('Unblock',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black)),
                                    ),
                                  ),
                          );
                        }),
          ),
        ),
      ),
    );
  }
}
