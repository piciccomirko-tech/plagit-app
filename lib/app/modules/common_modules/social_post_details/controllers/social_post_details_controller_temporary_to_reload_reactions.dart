import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/social_feed_info_response_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../../common/data/data.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/employee_details/controllers/employee_details_controller.dart';
import '../../individual_social_feeds/controllers/individual_social_feeds_controller.dart';

class SocialPostDetailsControllerTemporaryToReloadReactions extends GetxController {
  BuildContext? context;

  Rx<SocialPostModel> socialPostInfo = SocialPostModel().obs;
  RxBool socialPostInfoDataLoading = true.obs;
  RxBool noDataFound = false.obs;

  bool _isReacting = false;
  bool _isBlocking = false;

  final ApiHelper _apiHelper = Get.find<ApiHelper>();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> _getSocialPostInfo(socialPostId) async {
    Either<CustomError, SocialFeedInfoResponseModel> responseData =
        await _apiHelper.getSocialPostDetails(socialPostId: socialPostId);
    socialPostInfoDataLoading.value = false;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (response) async {
      if (response.status == "success" && response.socialFeed != null) {
        socialPostInfo.value = response.socialFeed!;
        debugPrint(socialPostInfo.value.likes!.length.toString());
      } else {
        noDataFound.value = true;
      }
    });
  }

  Future<void> _postIncreasePostViewCount(socialPostId) async {
        await _apiHelper.increasePostView(socialPostId: socialPostId);
  }

  //Method For Finding Posts by ID
  Future<void> getSocialPostInfoByPostId(postId) async {
    _showFollowersFollowingBottomSheet(MyStrings.peopleWhoLiked.tr);
    socialPostInfoDataLoading(true);
    _getSocialPostInfo(postId);
    _postIncreasePostViewCount(postId);
  }

  void _showFollowersFollowingBottomSheet( String title) {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Obx(()=>Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                // List
                socialPostInfoDataLoading.value?Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CupertinoActivityIndicator(),
                ):Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: socialPostInfo.value.likes!.length, // Example: 20 users
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            Get.back();
                            if (socialPostInfo.value.likes![index].role?.toLowerCase() ==
                                "client") {
                              if (Get.isRegistered<
                                  IndividualSocialFeedsController>()) {
                                Get.find<IndividualSocialFeedsController>()
                                    .onlyLoadData(socialPostInfo.value.likes![index]);
                              } else {
                                Get.toNamed(Routes.individualSocialFeeds,
                                    arguments: socialPostInfo.value.likes![index]);
                              }
                            } else {
                              if (Get.isRegistered<
                                  EmployeeDetailsController>()) {
                                Get.find<EmployeeDetailsController>()
                                    .onlyLoadData({
                                  'employeeId': socialPostInfo.value.likes![index].id ?? ""
                                });
                              } else {
                                Get.toNamed(Routes.employeeDetails, arguments: {
                                  'employeeId': socialPostInfo.value.likes![index].id ?? ""
                                });
                              }
                            }
                          },
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: socialPostInfo.value.likes![index].profilePicture != null &&
                                  socialPostInfo.value.likes![index].profilePicture !=
                                      "undefined"
                                  ? Image.network(
                                "https://mh-user-bucket.s3.amazonaws.com/public/users/profile/${socialPostInfo.value.likes![index].profilePicture}",
                                fit: BoxFit.cover,
                                width: 48,
                                height: 48,
                              )
                                  : socialPostInfo.value.likes![index].role?.toLowerCase() ==
                                  "client"
                                  ? Image.asset(
                                MyAssets.clientDefault,
                                fit: BoxFit.cover,
                                width: 48,
                                height: 48,
                              )
                                  : Image.asset(
                                MyAssets.employeeDefault,
                                fit: BoxFit.cover,
                                width: 48,
                                height: 48,
                              ),
                            ),
                          ),
                          title: Text(
                            '${socialPostInfo.value.likes![index].name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              SvgPicture.network(
                                Data.getCountryFlagByName(
                                    socialPostInfo.value.likes![index].countryName.toString()),
                                width: 10,
                                height: 10,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  ("${socialPostInfo.value.likes![index].countryName}")
                                      .toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MyColors.l111111_dwhite(context)
                                      .regular11,
                                ),
                              ),
                            ],
                          ));
                    },
                  ),
                ),
              ],
            ));
          },
        );
      },
    );
  }
}
