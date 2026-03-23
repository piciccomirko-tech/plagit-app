import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_job_posts_widget.dart';
import '../../../../common/style/my_decoration.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../models/dropdown_item.dart';
import '../../../common_modules/common_social_feed/views/common_social_feed_view.dart';

class ClientHomePremiumTabItemWidget
    extends GetWidget<ClientHomePremiumController> {
  const ClientHomePremiumTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedTabIndex.value == 0
        ? Padding(
      padding: EdgeInsets.only(bottom: 120),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GridView.builder(
          itemCount: controller.positionList.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            return _item(controller.positionList[index]);
          },
        ),
      )):controller.selectedTabIndex.value == 1?CommonSocialFeedView():Padding(
      padding: EdgeInsets.all(15.0.w),
      child: const ClientJobPostsWidget(),
      // child: const CommonJobPostsView(userType: 'client',isMyJobPost: true,),
    ),);
  }
  Widget _item(DropdownItem position) {
    return Center(
      child: Container(
        width: 182.w,
        height: 112.w,
        decoration: MyDecoration.cardBoxDecoration(context: controller.context!),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () => controller.onPositionClick(position),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: CustomNetworkImage(url: (position.logo ?? '').uniformImageUrl),
                ),
                SizedBox(height: 9.h),
                Text(
                  position.name ?? "-",
                  style: Get.width>600?MyColors.l111111_dwhite(controller.context!).medium12:MyColors.l111111_dwhite(controller.context!).medium14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}