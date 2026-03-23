import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:mh/main.dart';
import '../../../../../core/loggers/logger.dart';
import '../../../../../domain/repositories/social_feed_repository.dart';
import '../../../../common/data/data.dart';
import '../../../../models/followers_response_model.dart';
import '../../../../models/repost_request_model.dart';
import '../../../../models/saved_post_model.dart';
import '../../../../models/social_comment_request_model.dart';
import '../../../../models/social_feed_info_response_model.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../models/social_post_report_request_model.dart';
import '../../../admin/admin_home/controllers/admin_home_controller.dart';
import '../../../client/client_home_premium/controllers/client_home_premium_controller.dart';
import '../../../client/common/shortlist_controller.dart';
import '../../../client/employee_details/controllers/employee_details_controller.dart';
import '../../../employee/employee_home/controllers/employee_home_controller.dart';
import '../../individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import '../../live_chat/widgets/copy_able_text_widget.dart';
import '../../splash/controllers/splash_controller.dart';
import '../models/post_like_unlike_response_model.dart';
import '../views/common_social_feed_media_all_view.dart';
import '../views/common_social_feed_post_details_view.dart';
import 'package:mh/app/common/widgets/download_manager.dart';

import '../views/common_social_feed_view.dart';

class CommonSocialFeedController extends GetxController {
  CommonSocialFeedController({
    required this.socialFeedRepository,
  });
  final SocialFeedRepository socialFeedRepository;

  final ShortlistController shortlistController = Get.find();

  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  final isSocialFeedLoading = true.obs;
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;
  final moreSocialDataAvailable = true.obs;
  final isLoadingMoreSocialPost = false.obs;
  final currentSocialPage = 1.obs;
  final showComment = false.obs;
  final selectedIndex = 0.obs;
  final selectedIndexForComment = 0.obs;
  final isReacting = false.obs;
  final socialPostInfoDataLoading = true.obs;
  Rx<SocialPostModel> socialPostInfo = SocialPostModel().obs;
  RxBool noDataFound = false.obs;
  final isCommentLoading = false.obs;
  final TextEditingController newCommentEditTextController =
      TextEditingController();
  final TextEditingController commentEditTextController =
      TextEditingController();
  final TextEditingController commentReplyEditTextController =
      TextEditingController();
  final TextEditingController reportEditTextController =
      TextEditingController();
  final TextEditingController repostEditTextController =
      TextEditingController();
  final editingCommentId = ''.obs;
  final editingReplyId = ''.obs;
  final isEditCommentLoading = false.obs;
  final isReplyLoading = false.obs;
  final activeReplyCommentId = ''.obs;
  final Map<int, bool> postVisibilityMap = {};

  // final SplashController splashController = Get.put(SplashController());

  var currentSocialPost = SocialPostModel().obs;

  final isSavePostLoading = false.obs;

  final isNewPostLoading = false.obs;

  final currentSliderIndex = 0.obs;
  final dragStartY = 0.0.obs;
  final isCaptionVisible = true.obs;
  final opacity = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  bool isPostSaved(String postId) {
    return savedPostList.any((post) => post.post?.id == postId);
  }

  void paginateTask(scrollController) {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent -
                  scrollController.position.pixels <=
              1000 &&
          isLoadingMoreSocialPost.value == false) {
        loadNextPage();
      }
    });
  }

  void loadNextPage() async {
    currentSocialPage.value++;
    await _getMoreSocialFeeds();
  }

  Future<void> getSocialPost(
      {bool needToJumpTop = false,
      bool refresh = false,
      bool refreshLoader = false,
      bool fromHome = false}) async {
    try {
      if (!refresh) {
        isSocialFeedLoading(true);
        showComment.value = false;
        socialPostList.clear();
        currentSocialPage(1);
      }
      if (refreshLoader) {
        isNewPostLoading(true);
      }
      final response = await socialFeedRepository.getSocialPost(
          pageNumber: currentSocialPage.value);

      if (response?.status != 'success') {
        throw Exception('Failed to get social feed posts ');
      } else {
        socialPostList.value = response?.socialFeeds?.posts ?? [];
        debugPrint('New social call done with length ${socialPostList.length}');
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {
      if (!refresh) {
        isSocialFeedLoading(false);
      }
      if (refresh || refreshLoader || fromHome) {
        isNewPostLoading(false);
        if (Get.find<AppController>().user.value.isClient) {
          Get.find<ClientHomePremiumController>().isNewPostAvailable(false);
        } else if (Get.find<AppController>().user.value.isEmployee) {
          Get.find<EmployeeHomeController>().isNewPostAvailable(false);
        } else if (Get.find<AppController>().user.value.isAdmin) {
          Get.find<AdminHomeController>().isNewPostAvailable(false);
        }
      }
      if (needToJumpTop == true) {
        if (Get.find<AppController>().user.value.isClient) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<ClientHomePremiumController>()
                .scrollController
                .jumpTo(0.0);
          });
        } else if (Get.find<AppController>().user.value.isEmployee) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<EmployeeHomeController>().scrollController.jumpTo(0.0);
          });
        } else if (Get.find<AppController>().user.value.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<AdminHomeController>().scrollController.jumpTo(0.0);
          });
        }
      }
    }
  }

  Future<void> getSocialPostAfterBlock({bool needToJumpTop = false}) async {
    try {
      // isSocialFeedLoading(true);
      showComment.value = false;
      // socialPostList.clear();
      // currentSocialPage(1);
      final response = await socialFeedRepository.getSocialPost(
          pageNumber: currentSocialPage.value);

      if (response?.status != 'success') {
        throw Exception('Failed to get social feed posts ');
      } else {
        socialPostList.value = response?.socialFeeds?.posts ?? [];
        debugPrint('New social call done with length ${socialPostList.length}');
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {
      // isSocialFeedLoading(false);
      // if (needToJumpTop == true) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     Get.find<EmployeeHomeController>().scrollController.jumpTo(0.0);
      //   });
      // }
    }
  }

  Future<void> _getMoreSocialFeeds() async {
    try {
      isLoadingMoreSocialPost(true);
      moreSocialDataAvailable(true);

      final response = await socialFeedRepository.getSocialPost(
          pageNumber: currentSocialPage.value);
      if (response?.status != 'success') {
        throw Exception('Failed to get more social feed posts ');
      } else {
        socialPostList.addAll(response?.socialFeeds?.posts ?? []);
        debugPrint(
            'New more social call done with length ${socialPostList.length}');
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {
      socialPostList.refresh();
      moreSocialDataAvailable(false);
      isLoadingMoreSocialPost(false);
    }
    // }
    //
    // Either<CustomError, SocialFeedResponseModel> responseData =
    // await _apiHelper.getSocialFeeds(
    //     socialFeedRequestModel: SocialFeedRequestModel(
    //         limit: 10,
    //         page: currentSocialPage.value,
    //         socialFeedType: SocialFeedType.public));
    // socialPostDataLoaded.value = true;
    // responseData.fold((CustomError customError) {
    //   moreSocialDataAvailable.value = false;
    // }, (SocialFeedResponseModel response) {
    //   if (response.status == "success") {
    //     if ((response.socialFeeds?.posts ?? []).isNotEmpty) {
    //       moreSocialDataAvailable.value = true;
    //     } else {
    //       moreSocialDataAvailable.value = false;
    //     }
    //     socialPostList.addAll(response.socialFeeds?.posts ?? []);
    //   }
    // });
    // socialPostList.refresh();
    // isLoadingMoreSocialPost.value = false;
  }

  Future<void> reactPost(
      {required String postId, required int index, String? img}) async {
    if (isReacting.value) return;
    selectedIndex(index);
    isReacting(true);
    SocialUser socialUser = SocialUser(
      id: appController.user.value.userId,
      name: appController.user.value.userName,
      countryName: appController.user.value.userCountry,
      profilePicture: userProfilePic,
    );
    var currentPost = socialPostList.elementAt(index);
    if ((currentPost.likes ?? [])
        .any((SocialUser a) => a.id == socialUser.id)) {
      currentPost.likes!.removeWhere((SocialUser a) => a.id == socialUser.id);
    } else {
      currentPost.likes!.add(socialUser);
    }
    // Create a new SocialPostModel with the updated likes list
    SocialPostModel newSocialPostModel = SocialPostModel(
      id: currentPost.id,
      content: currentPost.content,
      media: currentPost.media,
      active: currentPost.active,
      views: currentPost.views!,
      user: currentPost.user,
      comments: currentPost.comments,
      likes: currentPost.likes,
      reports: currentPost.reports,
      createdAt: currentPost.createdAt,
      repost: currentPost.repost,
      updatedAt: currentPost.updatedAt,
      v: currentPost.v,
      liked: currentPost.likes!.any((SocialUser a) => a.id == socialUser.id),
      recommendation: currentPost.recommendation,
    );

    currentSocialPost.value = currentPost;
    // print('currentPost${newSocialPostModel.likes?[0].countryName}');
    // Update the list by replacing the post at the specific index
    socialPostList[index] = newSocialPostModel;
    socialPostInfo.value = newSocialPostModel;
    isReacting(false);
    PostLikeUnlikeResponseModel? response =
        await socialFeedRepository.postSocialPostReact(postId: postId);
    debugPrint("postID: $postId, ${response?.message}");
  }

  Future<void> getSocialPostInfoByPostId(BuildContext context, postId) async {
    _showBottomSheet(context, MyStrings.peopleWhoLiked.tr);
    socialPostInfoDataLoading(true);
    _getSocialPostInfo(postId);
  }

  Future<void> seePostDetails(index) async {
    selectedIndex(index);
    newCommentEditTextController.clear();
    // showComment.value = appController.user.value.isAdmin ? false : true;
    showComment.value = true;
    socialPostInfo.value = socialPostList[index];
    Get.to(() => CommonSocialFeedPostDetailsView());
  }

  Future<void> seeMediaDetails(SocialPostModel socialPost, sliderIndex,
      {postIndex}) async {
    selectedIndex(postIndex);
    newCommentEditTextController.clear();
    // showComment.value = appController.user.value.isAdmin ? false : true;
    showComment.value = true;
    socialPostInfo.value = socialPost;
    currentSliderIndex.value = sliderIndex;
    Get.to(() => CommonSocialFeedPostMediaAllView());
    print(
        'CommonSocialFeedController.seeMediaDetails${currentSliderIndex.value}');
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      isCommentLoading(true);
      isEditCommentLoading(true);
      socialPostList[selectedIndex.value]
          .comments!
          .removeWhere((c) => c.id == commentId);
      isCommentLoading(false);
      isEditCommentLoading(false);
      final response = await socialFeedRepository.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      if (response?.status != 'success') {
        throw Exception('Failed to delete comment');
      } else {
        socialPostList[selectedIndex.value]
            .comments!
            .removeWhere((c) => c.id == commentId);
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    }
  }

  Future<void> deleteCommentReply(
      String postId, String commentId, String replyId) async {
    try {
      isCommentLoading(true);
      isEditCommentLoading(true);
      (socialPostList[selectedIndex.value]
              .comments!
              .firstWhere((comment) => comment.id == commentId))
          .children!
          .removeWhere((c) => c.id == replyId);
      isCommentLoading(false);
      isEditCommentLoading(false);
      final response = await socialFeedRepository.deleteComment(
        postId: postId,
        commentId: replyId,
      );
      if (response?.status != 'success') {
        throw Exception('Failed to delete comment');
      } else {}
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    }
  }

  void _showBottomSheet(context, String title) {
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
            return Obx(() => Column(
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
                    socialPostInfoDataLoading.value
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CupertinoActivityIndicator(),
                          )
                        : Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: socialPostInfo
                                  .value.likes!.length, // Example: 20 users
                              itemBuilder: (context, index) {
                                return ListTile(
                                    onTap: () {
                                      Get.back();
                                      if (socialPostInfo
                                              .value.likes![index].role
                                              ?.toLowerCase() ==
                                          "client") {
                                        if (Get.isRegistered<
                                            IndividualSocialFeedsController>()) {
                                          Get.find<
                                                  IndividualSocialFeedsController>()
                                              .onlyLoadData(socialPostInfo
                                                  .value.likes![index]);
                                        } else {
                                          Get.toNamed(
                                              Routes.individualSocialFeeds,
                                              arguments: socialPostInfo
                                                  .value.likes![index]);
                                        }
                                      } else {
                                        if (Get.isRegistered<
                                            EmployeeDetailsController>()) {
                                          Get.find<EmployeeDetailsController>()
                                              .onlyLoadData({
                                            'employeeId': socialPostInfo
                                                    .value.likes![index].id ??
                                                ""
                                          });
                                        } else {
                                          Get.toNamed(Routes.employeeDetails,
                                              arguments: {
                                                'employeeId': socialPostInfo
                                                        .value
                                                        .likes![index]
                                                        .id ??
                                                    ""
                                              });
                                        }
                                      }
                                    },
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.transparent,
                                      child: ClipOval(
                                        child: socialPostInfo
                                                        .value
                                                        .likes![index]
                                                        .profilePicture !=
                                                    null &&
                                                socialPostInfo
                                                        .value
                                                        .likes![index]
                                                        .profilePicture !=
                                                    "undefined"
                                            ? Image.network(
                                                socialPostInfo
                                                        .value
                                                        .likes![index]
                                                        .profilePicture
                                                        ?.socialMediaUrl ??
                                                    "",
                                                fit: BoxFit.cover,
                                                width: 48,
                                                height: 48,
                                              )
                                            : socialPostInfo.value.likes![index]
                                                        .role
                                                        ?.toLowerCase() ==
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
                                              socialPostInfo.value.likes![index]
                                                  .countryName
                                                  .toString()),
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
                                            style:
                                                MyColors.l111111_dwhite(context)
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

  Future<void> _getSocialPostInfo(socialPostId) async {
    Either<CustomError, SocialFeedInfoResponseModel> responseData =
        await _apiHelper.getSocialPostDetails(socialPostId: socialPostId);
    socialPostInfoDataLoading.value = false;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (response) async {
      if (response.status == "success" && response.socialFeed != null) {
        socialPostInfo.value = response.socialFeed!;

        if (currentSocialPost.value.id == socialPostId) {
          SocialPostModel socialPostModel = socialPostInfo.value;
          socialPostInfo.value.likes = currentSocialPost.value.likes;
          for (SocialUser item in socialPostModel.likes ?? []) {
            socialPostInfo.value.likes?.removeWhere((e) => e.id == item.id);
            socialPostInfo.value.likes?.add(item);
          }
        }
        debugPrint(socialPostInfo.value.likes!.length.toString());
      } else {
        noDataFound.value = true;
      }
    });
  }

  void onEditClick({required Job jobRequest}) =>
      Get.toNamed(Routes.createJobPost,
          arguments: CreateJobPostRequestModel(
            id: jobRequest.id ?? "",
            positionId: jobRequest.positionId?.id ?? "",
            clientId: appController.user.value.client?.id ?? "",
            // minRatePerHour: jobRequest.minRatePerHour ?? "0.0",
            // maxRatePerHour: jobRequest.maxRatePerHour ?? "0.0",
            salary: jobRequest.salary ?? '',
            age: jobRequest.age ?? '',
            experience: jobRequest.experience,
            vacancy: jobRequest.vacancy ?? 0,
            dates: jobRequest.dates ?? [],
            nationalities: jobRequest.nationalities ?? [],
            skills: jobRequest.skills ?? [],
            // minExperience: jobRequest.minExperience ?? 0,
            // maxExperience: jobRequest.maxExperience ?? 0,
            languages: jobRequest.languages ?? [],
            description: jobRequest.description ?? "",
            publishedDate: jobRequest.publishedDate,
            endDate: jobRequest.endDate,
          )
          // minAge: jobRequest.minAge,
          // maxAge: jobRequest.maxAge)
          );

  commentToggle(int index) {
    if (isCommentLoading.value) return;
    if (selectedIndexForComment.value != index) {
      newCommentEditTextController.clear();
    }
    showComment.value =
        selectedIndexForComment.value == index ? !showComment.value : true;
    selectedIndexForComment.value = index;
    selectedIndex.value = index;
    socialPostInfo.value = socialPostList[selectedIndex.value];
  }

  Future<void> addNewComment() async {
    String inputText = newCommentEditTextController.text.trim();

    if (inputText.isNotEmpty) {
      isCommentLoading(true);
      newCommentEditTextController.clear();

      try {
        final response = await socialFeedRepository.postSocialPostComment(
          socialCommentRequestModel: SocialCommentRequestModel(
            text: inputText,
            postId: socialPostList[selectedIndex.value].id ?? "",
            parentId: "",
          ),
        );
        if (response?.status != 'success') {
          Utils.showSnackBar(message: "${response?.message}", isTrue: false);
        } else {
          Utils.showSnackBar(message: "${response?.message}", isTrue: true);
          Comment comment = Comment(
            id: response?.comment?.id ?? '',
            text: inputText,
            children: <Comment>[],
            createdAt: DateTime.now(),
            user: SocialUser(
              id: appController.user.value.userId,
              name: appController.user.value.userName,
              positionId: '',
              positionName: '',
              email: appController.user.value.userEmail,
              role: appController.user.value.userRole,
              profilePicture: Utils.getProfilePicture,
              countryName: appController.user.value.userCountry,
            ),
          );
          socialPostList[selectedIndex.value].comments!.add(comment);
          socialPostInfo.value = socialPostList[selectedIndex.value];
          onTapCancelCommentEditing();
        }
      } catch (error) {
        if (kDebugMode) {
          Log.error(error.toString());
        }
      } finally {
        isCommentLoading(false);
      }
    }
  }

  Future<void> reportPost({required String postId}) async {
    Get.back();
    try {
      final response = await socialFeedRepository.postReportAgainstSocialPost(
          socialPostReportRequestModel: SocialPostReportRequestModel(
              postId: postId, reason: reportEditTextController.text));
      if (response?.status != 'success') {
        Utils.showSnackBar(
            message: "Failed to report this post. Please try again later.",
            isTrue: false);
      } else {
        Utils.showSnackBar(message: "${response?.message}", isTrue: true);
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {}
    reportEditTextController.clear();
  }

  Future<void> repostToMySocialFeed(
      {required String postId, required BuildContext context}) async {
    // Get.back();
    // CustomLoader.show(context);
    // Either<CustomError, CommonResponseModel> responseData = await _apiHelper
    //     .repostSocialPost(repostRequestModel: repostRequestModel);
    // CustomLoader.hide(context);
    // responseData.fold((CustomError customError) {
    //   Utils.errorDialog(context, customError);
    // }, (CommonResponseModel response) {
    //   if (response.status == "success") {
    //     getSocialFeeds();
    //     currentPage.value = 1;
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       scrollController.jumpTo(0.0);
    //     });
    //   }
    // });

    Get.back();
    try {
      final response = await socialFeedRepository.postRepostToMySocialFeed(
          repostRequestModel: RepostRequestModel(
              content: repostEditTextController.text.trim(), postId: postId));
      if (response?.status != 'success') {
        Utils.showSnackBar(message: "${response?.message}", isTrue: false);
      } else {
        getSocialPost(needToJumpTop: true);
        Utils.showSnackBar(message: "${response?.message}", isTrue: true);
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {}
    repostEditTextController.clear();
  }

  Future<void> deletePost(
      {required BuildContext context, required String postId}) async {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: MyStrings.areYouSureDeleteThisPost.tr,
      confirmButtonText: MyStrings.delete.tr,
      onConfirm: () async {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
        Get.until((route) => !Get.isDialogOpen!);
        // Get.back();
        CustomLoader.show(Get.context!);
        try {
          final response =
              await socialFeedRepository.deleteSocialPost(postId: postId);
          if (response?.status != 'success') {
            Utils.showSnackBar(message: "${response?.message}", isTrue: false);
          } else {
            // getSocialPost(needToJumpTop: true);
            socialPostList.removeWhere((item) => item.id == postId);
            Utils.showSnackBar(message: "${response?.message}", isTrue: true);
          }
        } catch (error) {
          if (kDebugMode) {
            Log.error(error.toString());
          }
        } finally {
          CustomLoader.hide(Get.context!);
        }
      },
    );
  }

  void activeInActivePost(
      {required BuildContext context,
      required String postId,
      required bool active}) {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: MyStrings.areYouSureInactiveThisPost.tr,
      confirmButtonText: MyStrings.inactive.tr,
      onConfirm: () async {
        Get.back();
        CustomLoader.show(context);
        try {
          final response = await socialFeedRepository.inactiveSocialPost(
              postId: postId, active: active);
          if (response?.status != 'success') {
            Utils.showSnackBar(message: "${response?.message}", isTrue: false);
          } else {
            socialPostList.removeWhere((item) => item.id == postId);
            // getSocialPost(needToJumpTop: true);
            Utils.showSnackBar(message: "${response?.message}", isTrue: true);
          }
        } catch (error) {
          if (kDebugMode) {
            Log.error(error.toString());
          }
        } finally {
          CustomLoader.hide(context);
        }
      },
    );
  }

  void onTapCancelCommentEditing() {
    isCommentLoading(true);
    editingReplyId.value = '';
    editingCommentId.value = '';
    isCommentLoading(false);
  }

  Future<void> updateExistingComment(postId, commentId) async {
    if (commentEditTextController.text.trim().isNotEmpty) {
      String updatedText = commentEditTextController.text.trim();
      commentEditTextController.clear();
      isCommentLoading(true);
      isEditCommentLoading(true);
      try {
        final comments = socialPostList[selectedIndex.value].comments!;
        final commentIndex = comments.indexWhere((c) => c.id == commentId);

        if (commentIndex != -1) {
          comments[commentIndex].text = updatedText;
        }
        editingReplyId.value = '';
        editingCommentId.value = '';
        isEditCommentLoading(false);
        isCommentLoading(false);
        final response = await socialFeedRepository.updateComment(
            postId: postId, commentId: commentId, newText: updatedText);
        if (response?.status != 'success') {
          Utils.showSnackBar(message: "${response?.message}", isTrue: false);
        } else {}
      } catch (error) {
        if (kDebugMode) {
          Log.error(error.toString());
        }
      } finally {}
    }
  }

  Future<void> addReply(Comment c, int index) async {
    if (commentReplyEditTextController.text.trim().isNotEmpty) {
      String replyText = commentReplyEditTextController.text.trim();
      commentReplyEditTextController.clear();
      isCommentLoading(true);
      isReplyLoading(true);
      try {
        final response = await socialFeedRepository.postSocialPostComment(
          socialCommentRequestModel: SocialCommentRequestModel(
            text: replyText,
            postId: socialPostList[selectedIndex.value].id ?? "",
            parentId: c.id ?? "",
          ),
        );
        if (response?.status != 'success') {
          Utils.showSnackBar(message: "${response?.message}", isTrue: false);
        } else {
          Comment replyComment = Comment(
            id: response?.comment?.id ?? '',
            text: replyText,
            createdAt: DateTime.now(),
            user: SocialUser(
                id: appController.user.value.userId,
                name: appController.user.value.userName,
                positionId: '',
                positionName: '',
                email: appController.user.value.userEmail,
                role: appController.user.value.userRole,
                profilePicture: Utils.getProfilePicture,
                countryName: appController.user.value.userCountry),
          );

          socialPostList[selectedIndex.value]
              .comments![index]
              .children
              ?.add(replyComment);
          socialPostInfo.value = socialPostList[selectedIndex.value];
        }
      } catch (error) {
        if (kDebugMode) {
          Log.error(error.toString());
        }
      } finally {
        activeReplyCommentId.value = '';
        isCommentLoading(false);
        isReplyLoading(false);
      }
    }
  }

  void showCommentReplyInputField(Comment c) {
    isCommentLoading(true);
    activeReplyCommentId.value == c.id
        ? null
        : commentReplyEditTextController.text = '';
    activeReplyCommentId.value = c.id ?? "";
    isCommentLoading(false);
  }

  Future<void> updateCommentReply(postId, commentId, replyId) async {
    String updatedText = commentReplyEditTextController.text.trim();
    if (updatedText.isNotEmpty) {
      isCommentLoading(true);
      isEditCommentLoading.value = true;
      final comments = socialPostList[selectedIndex.value].comments!;
      final commentIndex = comments.indexWhere((c) => c.id == commentId);

      if (commentIndex != -1) {
        final replyIndex = (comments[commentIndex].children ?? [])
            .indexWhere((reply) => reply.id == replyId);
        if (replyIndex != -1) {
          comments[commentIndex].children![replyIndex].text = updatedText;
        }
      }
      editingReplyId.value = '';
      editingCommentId.value = '';
      try {
        final response = await socialFeedRepository.updateComment(
            postId: postId, commentId: replyId, newText: updatedText);
        if (response?.status != 'success') {
          Utils.showSnackBar(message: "${response?.message}", isTrue: false);
        } else {}
      } catch (e) {
      } finally {
        isEditCommentLoading.value = false;
        isCommentLoading(false);
      }
    }
  }

  int getTotalCommentCount({required List<Comment> comments}) {
    int totalCount = 0;

    if (comments.isNotEmpty) {
      for (Comment comment in comments) {
        totalCount++;
        totalCount += getTotalCommentCount(comments: comment.children ?? []);
      }
    }

    return totalCount;
  }

  void startEditingReply(String parentId, Comment reply) {
    isCommentLoading(true);
    editingCommentId.value = '';
    editingReplyId.value = reply.id!;
    commentReplyEditTextController.text = reply.text ?? "";
    isCommentLoading(false);
  }

  Future<void> followUnfollowUser(userId) async {
    debugPrint(appController.isFollowing(userId).toString());
    if (appController.isFollowing(userId)) {
      appController.myFollowingList.remove(Following(id: userId));
    } else {
      appController.myFollowingList
          .add(Following(id: userId, notifications: true));
    }

    try {
      final response =
          await socialFeedRepository.followUnfollow(userId: userId);
      if (response?.status != 'success') {
        Utils.showSnackBar(message: "${response?.result}", isTrue: false);
      } else {
        Utils.showSnackBar(message: "${response?.result}", isTrue: true);
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {}
  }

  Future<void> savePost(String postId) async {
    // if (isSavePostLoading.value) return;
    CustomLoader.show(Get.context!);
    try {
      // isSavePostLoading(true);
      final response = await socialFeedRepository.savePost(postId: postId);
      if (response?.status != 'success') {
        // Utils.showSnackBar(message: "${response?.message}", isTrue: false);
      } else {
        savedPostList.add(SavedPostModel(
            id: response?.post?.id,
            post: SocialPostModel(id: response?.post?.post)));
        savedPostList.refresh();
        isPostSaved(postId);
        update();
        // Utils.showSnackBar(message: "${response?.message}", isTrue: true);
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {
      // isSavePostLoading(false);
      CustomLoader.hide(Get.context!);
    }
  }

  Future<void> deleteSavePost(String postId) async {
    // if (isSavePostLoading.value) return;
    CustomLoader.show(Get.context!);
    try {
      // isSavePostLoading(true);
      final response =
          await socialFeedRepository.deleteSavePost(postId: postId);
      if (response?.status != 'success') {
        // Utils.showSnackBar(message: "${response?.message}", isTrue: false);
      } else {
        savedPostList.removeWhere((item) => item.id == postId);
        savedPostList.refresh();
        isPostSaved(postId);
        update();
        // Utils.showSnackBar(message: "${response?.message}", isTrue: true);
      }
    } catch (error) {
      if (kDebugMode) {
        Log.error(error.toString());
      }
    } finally {
      // isSavePostLoading(false);
      CustomLoader.hide(Get.context!);
    }
  }

  void blockUser({required String userId, required BuildContext context}) {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: 'Do you want to block this user?',
      confirmButtonText: 'Block',
      onConfirm: () async {
        Get.back();
        CustomLoader.show(context);
        try {
          final response = await socialFeedRepository.blockUnblockUser(
              userId: userId, action: 'BLOCK');
          if (response?.status != 'success') {
            Utils.showSnackBar(message: "${response?.message}", isTrue: false);
          } else {
            // getSocialPost(needToJumpTop: true);
            Utils.showSnackBar(message: "${response?.message}", isTrue: true);
            getSocialPostAfterBlock(needToJumpTop: false);
          }
        } catch (error) {
          if (kDebugMode) {
            Log.error(error.toString());
          }
        } finally {
          CustomLoader.hide(context);
        }
      },
    );
  }

  bool isPostCurrentlyVisible(int index) {
    return postVisibilityMap[index] ?? false;
  }

  void markPostAsVisible(int index) {
    postVisibilityMap[index] = true;
  }

  void markPostAsHidden(int index) {
    postVisibilityMap[index] = false;
  }

  void incrementPostViews(String socialPostId) async {
    await _apiHelper.increasePostView(socialPostId: socialPostId);
  }

  Future<void> onBookNowClick(id) async {
    if (!appController.hasPermission()) return;
    Get.toNamed(Routes.calender,
        arguments: [id ?? '', shortListId(employeeId: id ?? ''), false]);
  }

  String shortListId({required String employeeId}) {
    for (var i in shortlistController.shortList) {
      if (i.employeeId == employeeId) {
        return i.sId ?? '';
      }
    }
    return '';
  }

  void showDownloadBottomSheet(context, List<Media> mediaList) {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.3, // Reduced to 0.3 for a smaller initial height
          minChildSize: 0.1, // Reduced to 0.1 for a very small minimum height
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(height: 1),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () {
                      downloadCurrentMedia(mediaList);
                      Get.back();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.download,
                          color: MyColors.c_C6A34F,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Download",
                          style: TextStyle(
                              fontFamily: MyAssets.fontMontserrat,
                              fontSize: 13,
                              color: MyColors.l111111_dffffff(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void downloadCurrentMedia(List<Media> mediaList) async {
    Media currentMedia = mediaList[currentSliderIndex.value];

    DownloadManager.downloadAndSaveMedia(
      mediaUrl: currentMedia.url?.imageUrl ?? "",
      mediaType: currentMedia.type ?? "",
      context: Get.context!,
    );
  }

  void onVerticalDragStart(DragStartDetails details) {
    dragStartY.value = details.globalPosition.dy;
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    double dragDistance = details.globalPosition.dy - dragStartY.value;
    double fadeThreshold = 150.0; // Adjust fade sensitivity

    // Reduce opacity as the user drags up or down

    opacity.value = 1.0 - (dragDistance.abs() / fadeThreshold).clamp(0.0, 1.0);

    // If drag distance exceeds threshold, go back
    if (dragDistance.abs() > fadeThreshold) {
      Get.back();
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    // Reset opacity if user doesn't drag far enough
    opacity.value = 1.0;
  }

  void toggleCaptionVisibility() {
    isCaptionVisible.value = !isCaptionVisible.value;
  }

  ScrollController commentsScrollController = ScrollController();
  void showReplyField(String commentId) {
    activeReplyCommentId.value = commentId; // Set the active comment ID
    // Scroll to the bottom of the comments section
    Future.delayed(Duration(milliseconds: 100), () {
      commentsScrollController.animateTo(
        commentsScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void showCommentBottomSheet(
      context, String title, CommonSocialFeedController feedController1) {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: Obx(
                () => Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
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
                    Expanded(
                      child: SingleChildScrollView(
                        // controller: commentsScrollController,
                        child: showComment.value
                            ? isCommentLoading.value
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.0.w, right: 15.0.w),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 15.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 10,
                                              child: SizedBox(
                                                height: 40,
                                                child: buildCommentTextField(
                                                    context, feedController1),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            buildCommentButton(
                                                context, feedController1)
                                          ],
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          // reverse: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              (socialPostInfo.value.comments ??
                                                      [])
                                                  .length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Comment c = (socialPostInfo
                                                    .value.comments ??
                                                [])[index];
                                            Comment comment = c;

                                            return Column(
                                              children: [
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: buildComentsListTitle(
                                                      c, context),
                                                  leading: editingCommentId
                                                                  .value ==
                                                              comment.id &&
                                                          editingReplyId
                                                                  .value ==
                                                              ''
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            onTapCancelCommentEditing();
                                                          },
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                      : GestureDetector(
                                                          onTap: () => c.user
                                                                      ?.role
                                                                      ?.toLowerCase() ==
                                                                  "client"
                                                              ? Get.toNamed(
                                                                  Routes
                                                                      .individualSocialFeeds,
                                                                  arguments:
                                                                      c.user)
                                                              : Get.toNamed(
                                                                  Routes
                                                                      .employeeDetails,
                                                                  arguments: {
                                                                      'employeeId':
                                                                          c.user?.id ??
                                                                              ""
                                                                    }),
                                                          child: CircleAvatar(
                                                            backgroundImage: ((c.user?.profilePicture ??
                                                                            "")
                                                                        .isEmpty ||
                                                                    c.user?.profilePicture ==
                                                                        "undefined")
                                                                ? AssetImage(c
                                                                            .user
                                                                            ?.role
                                                                            ?.toUpperCase() ==
                                                                        "ADMIN"
                                                                    ? MyAssets
                                                                        .adminDefault
                                                                    : c.user?.role?.toUpperCase() ==
                                                                            "CLIENT"
                                                                        ? MyAssets
                                                                            .clientDefault
                                                                        : MyAssets
                                                                            .employeeDefault)
                                                                : NetworkImage((c
                                                                            .user
                                                                            ?.profilePicture ??
                                                                        "")
                                                                    .socialMediaUrl),
                                                          ),
                                                        ),
                                                  subtitle:
                                                      editingCommentId.value ==
                                                                  comment.id &&
                                                              editingReplyId
                                                                      .value ==
                                                                  ''
                                                          ? Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        commentEditTextController,
                                                                    maxLines:
                                                                        null,
                                                                    minLines: 1,
                                                                    style: MyColors.l111111_dwhite(
                                                                            context)
                                                                        .medium13,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              10.0.w),
                                                                      // hintText: MyStrings.editCommentHint.tr,
                                                                      fillColor:
                                                                          MyColors
                                                                              .noColor,
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                MyColors.lightGrey,
                                                                            width: 0.5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon: isEditCommentLoading
                                                                          .value
                                                                      ? CupertinoActivityIndicator(
                                                                          radius:
                                                                              10, // Adjust the radius for size
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .send_outlined,
                                                                          color:
                                                                              MyColors.primaryLight),
                                                                  onPressed: isEditCommentLoading
                                                                          .value
                                                                      ? null
                                                                      : () async {
                                                                          updateExistingComment(
                                                                              socialPostInfo.value.id!,
                                                                              editingCommentId.value);
                                                                        },
                                                                ),
                                                              ],
                                                            )
                                                          : Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CopyableTextWidget(
                                                                  text:
                                                                      c.text ??
                                                                          "",
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    color: MyColors
                                                                        .l111111_dwhite(
                                                                            context),
                                                                  ),
                                                                  textColor: MyColors
                                                                      .l111111_dwhite(
                                                                          context),
                                                                  linkColor:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                                // Text(
                                                                //   c.text ?? "",
                                                                //   style: TextStyle(
                                                                //     fontFamily: MyAssets
                                                                //         .fontMontserrat,
                                                                //     color: MyColors
                                                                //         .l111111_dwhite(
                                                                //         context),
                                                                //   ),
                                                                // ),
                                                                SizedBox(
                                                                    height:
                                                                        5.w),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    showCommentReplyInputField(
                                                                        c);
                                                                  },
                                                                  child: Text(
                                                                    MyStrings
                                                                        .reply
                                                                        .tr,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          MyAssets
                                                                              .fontMontserrat,
                                                                      color: MyColors
                                                                          .lightGrey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                  trailing: comment.user?.id ==
                                                          appController
                                                              .user.value.userId
                                                      ? PopupMenuButton<String>(
                                                          onSelected: (value) {
                                                            if (value ==
                                                                'edit') {
                                                              isCommentLoading
                                                                  .value = true;
                                                              editingReplyId
                                                                  .value = '';
                                                              editingCommentId
                                                                      .value =
                                                                  comment.id
                                                                      .toString();
                                                              commentEditTextController
                                                                      .text =
                                                                  comment.text ??
                                                                      "";
                                                              isCommentLoading
                                                                      .value =
                                                                  false;
                                                            } else if (value ==
                                                                'delete') {
                                                              deleteComment(
                                                                  socialPostInfo
                                                                      .value
                                                                      .id!,
                                                                  comment.id!);
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context) =>
                                                                  [
                                                            PopupMenuItem(
                                                              value: 'edit',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: MyColors
                                                                          .primaryLight),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    "Edit",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            MyAssets.fontMontserrat),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'delete',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            MyAssets.fontMontserrat),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : null,
                                                ),
                                                if ((c.children ?? [])
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 30.0.w),
                                                    child: ListView.builder(
                                                      itemCount:
                                                          (c.children ?? [])
                                                              .length,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        Comment reply =
                                                            (c.children ??
                                                                [])[index];
                                                        return ListTile(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      0.0),
                                                          title: Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () => reply
                                                                            .user
                                                                            ?.role
                                                                            ?.toLowerCase() ==
                                                                        "client"
                                                                    ? Get.toNamed(
                                                                        Routes
                                                                            .individualSocialFeeds,
                                                                        arguments:
                                                                            reply
                                                                                .user)
                                                                    : Get.toNamed(
                                                                        Routes
                                                                            .employeeDetails,
                                                                        arguments: {
                                                                            'employeeId':
                                                                                reply.user?.id ?? ""
                                                                          }),
                                                                child: Text(
                                                                  reply.user?.name !=
                                                                              null &&
                                                                          reply.user!.name!.length >
                                                                              12
                                                                      ? Utils.truncateCharacters(
                                                                          reply.user!.name ??
                                                                              '',
                                                                          12)
                                                                      : reply.user
                                                                              ?.name ??
                                                                          '',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    fontSize:
                                                                        13,
                                                                    color: MyColors
                                                                        .l111111_dwhite(
                                                                            context),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10.w),
                                                              CircleAvatar(
                                                                radius: 1.5,
                                                                backgroundColor:
                                                                    MyColors.l111111_dwhite(
                                                                        context),
                                                              ),
                                                              SizedBox(
                                                                  width: 10.w),
                                                              Text(
                                                                Utils.formatDateTime(
                                                                    reply.createdAt ??
                                                                        DateTime
                                                                            .now(),
                                                                    socialFeed:
                                                                        true),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    fontSize:
                                                                        12,
                                                                    color: MyColors
                                                                        .lightGrey),
                                                              ),
                                                            ],
                                                          ),
                                                          leading: editingReplyId
                                                                      .value ==
                                                                  reply.id
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    onTapCancelCommentEditing();
                                                                  },
                                                                  child: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .red,
                                                                  ))
                                                              : GestureDetector(
                                                                  onTap: () => reply
                                                                              .user
                                                                              ?.role
                                                                              ?.toLowerCase() ==
                                                                          "client"
                                                                      ? Get.toNamed(
                                                                          Routes
                                                                              .individualSocialFeeds,
                                                                          arguments: reply
                                                                              .user)
                                                                      : Get.toNamed(
                                                                          Routes
                                                                              .employeeDetails,
                                                                          arguments: {
                                                                              'employeeId': reply.user?.id ?? ""
                                                                            }),
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundImage: ((reply.user?.profilePicture ?? "").isEmpty ||
                                                                            reply.user?.profilePicture ==
                                                                                "undefined")
                                                                        ? AssetImage(reply.user?.role?.toUpperCase() ==
                                                                                "ADMIN"
                                                                            ? MyAssets.adminDefault
                                                                            : reply.user?.role?.toUpperCase() == "CLIENT"
                                                                                ? MyAssets.clientDefault
                                                                                : MyAssets.employeeDefault)
                                                                        : NetworkImage((reply.user?.profilePicture ?? "").socialMediaUrl),
                                                                  ),
                                                                ),
                                                          subtitle: editingReplyId
                                                                      .value ==
                                                                  reply.id
                                                              ? Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            commentReplyEditTextController,
                                                                        maxLines:
                                                                            null,
                                                                        minLines:
                                                                            1,
                                                                        style: MyColors.l111111_dwhite(context)
                                                                            .medium13,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          contentPadding:
                                                                              EdgeInsets.all(10.0.w),
                                                                          fillColor:
                                                                              MyColors.noColor,
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                            borderSide:
                                                                                BorderSide(color: MyColors.lightGrey, width: 0.5),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      icon: isReplyLoading
                                                                              .value
                                                                          ? CupertinoActivityIndicator(
                                                                              radius: 10, // Adjust the radius for size
                                                                            )
                                                                          : Icon(
                                                                              Icons.send,
                                                                              color: MyColors.primaryLight),
                                                                      onPressed: isReplyLoading
                                                                              .value
                                                                          ? null
                                                                          : () async {
                                                                              updateCommentReply(socialPostInfo.value.id, c.id, reply.id);
                                                                            },
                                                                    ),
                                                                  ],
                                                                ) // Show editable field if in edit mode
                                                              : CopyableTextWidget(
                                                                  text: reply
                                                                          .text ??
                                                                      "",
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    fontSize:
                                                                        12,
                                                                    color: MyColors
                                                                        .lightGrey,
                                                                  ),
                                                                  textColor:
                                                                      MyColors
                                                                          .lightGrey,
                                                                  linkColor:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                          // Text(
                                                          //         reply.text ??
                                                          //             "",
                                                          //         style:
                                                          //             TextStyle(
                                                          //           fontFamily:
                                                          //               MyAssets
                                                          //                   .fontMontserrat,
                                                          //           color: MyColors
                                                          //               .lightGrey,
                                                          //         ),
                                                          //       ),
                                                          trailing: reply.user
                                                                      ?.id ==
                                                                  appController
                                                                      .user
                                                                      .value
                                                                      .userId
                                                              ? PopupMenuButton<
                                                                  String>(
                                                                  onSelected:
                                                                      (value) {
                                                                    if (value ==
                                                                        'edit') {
                                                                    } else if (value ==
                                                                        'delete') {
                                                                      deleteCommentReply(
                                                                          socialPostInfo
                                                                              .value
                                                                              .id!,
                                                                          c.id!,
                                                                          reply
                                                                              .id!);
                                                                    }
                                                                  },
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context) =>
                                                                          [
                                                                    PopupMenuItem(
                                                                      value:
                                                                          'edit',
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                              Icons.edit,
                                                                              color: MyColors.primaryLight),
                                                                          SizedBox(
                                                                              width: 8),
                                                                          Text(
                                                                              "Edit"),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    PopupMenuItem(
                                                                      value:
                                                                          'delete',
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red),
                                                                          SizedBox(
                                                                              width: 8),
                                                                          Text(
                                                                              "Delete"),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : null,
                                                        );
                                                      },
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                    ),
                                                  )
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.0.w, right: 15.0.w),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 15.h),
                                        if (!appController.user.value.isAdmin)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 10,
                                                child: SizedBox(
                                                  height: 40,
                                                  child: buildCommentTextField(
                                                      context, feedController1),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              buildCommentButton(
                                                  context, feedController1)
                                            ],
                                          ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          // reverse: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              (socialPostInfo.value.comments ??
                                                      [])
                                                  .length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Comment c = (socialPostInfo
                                                    .value.comments ??
                                                [])[index];
                                            Comment comment = c;

                                            return Column(
                                              children: [
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: buildComentsListTitle(
                                                      c, context),
                                                  leading: editingCommentId
                                                                  .value ==
                                                              comment.id &&
                                                          editingReplyId
                                                                  .value ==
                                                              ''
                                                      ? GestureDetector(
                                                          onTap: () {
                                                            onTapCancelCommentEditing();
                                                          },
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                      : GestureDetector(
                                                          onTap: () => c.user
                                                                      ?.role
                                                                      ?.toLowerCase() ==
                                                                  "client"
                                                              ? Get.toNamed(
                                                                  Routes
                                                                      .individualSocialFeeds,
                                                                  arguments:
                                                                      c.user)
                                                              : Get.toNamed(
                                                                  Routes
                                                                      .employeeDetails,
                                                                  arguments: {
                                                                      'employeeId':
                                                                          c.user?.id ??
                                                                              ""
                                                                    }),
                                                          child: CircleAvatar(
                                                            backgroundImage: ((c.user?.profilePicture ??
                                                                            "")
                                                                        .isEmpty ||
                                                                    c.user?.profilePicture ==
                                                                        "undefined")
                                                                ? AssetImage(c
                                                                            .user
                                                                            ?.role
                                                                            ?.toUpperCase() ==
                                                                        "ADMIN"
                                                                    ? MyAssets
                                                                        .adminDefault
                                                                    : c.user?.role?.toUpperCase() ==
                                                                            "CLIENT"
                                                                        ? MyAssets
                                                                            .clientDefault
                                                                        : MyAssets
                                                                            .employeeDefault)
                                                                : NetworkImage((c
                                                                            .user
                                                                            ?.profilePicture ??
                                                                        "")
                                                                    .socialMediaUrl),
                                                          ),
                                                        ),
                                                  subtitle:
                                                      editingCommentId.value ==
                                                                  comment.id &&
                                                              editingReplyId
                                                                      .value ==
                                                                  ''
                                                          ? Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        commentEditTextController,
                                                                    maxLines:
                                                                        null,
                                                                    minLines: 1,
                                                                    style: MyColors.l111111_dwhite(
                                                                            context)
                                                                        .medium13,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              10.0.w),
                                                                      // hintText: MyStrings.editCommentHint.tr,
                                                                      fillColor:
                                                                          MyColors
                                                                              .noColor,
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                MyColors.lightGrey,
                                                                            width: 0.5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon: isEditCommentLoading
                                                                          .value
                                                                      ? CupertinoActivityIndicator(
                                                                          radius:
                                                                              10, // Adjust the radius for size
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .send_outlined,
                                                                          color:
                                                                              MyColors.primaryLight),
                                                                  onPressed: isEditCommentLoading
                                                                          .value
                                                                      ? null
                                                                      : () async {
                                                                          updateExistingComment(
                                                                              socialPostInfo.value.id!,
                                                                              editingCommentId.value);
                                                                        },
                                                                ),
                                                              ],
                                                            )
                                                          : Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CopyableTextWidget(
                                                                  text:
                                                                      c.text ??
                                                                          "",
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    color: MyColors
                                                                        .l111111_dwhite(
                                                                            context),
                                                                  ),
                                                                  textColor: MyColors
                                                                      .l111111_dwhite(
                                                                          context),
                                                                  linkColor:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                                // Text(
                                                                //   c.text ?? "",
                                                                //   style:
                                                                //   TextStyle(
                                                                //     fontFamily:
                                                                //     MyAssets
                                                                //         .fontMontserrat,
                                                                //     color: MyColors
                                                                //         .l111111_dwhite(
                                                                //         context),
                                                                //   ),
                                                                // ),
                                                                SizedBox(
                                                                    height:
                                                                        5.w),
                                                                if (!appController
                                                                    .user
                                                                    .value
                                                                    .isAdmin)
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      showCommentReplyInputField(
                                                                          c);

                                                                      ///for scroll up
                                                                      // Future.delayed(Duration(milliseconds: 100), () {
                                                                      //   commentsScrollController.animateTo(
                                                                      //     commentsScrollController.position.maxScrollExtent,
                                                                      //     duration: Duration(milliseconds: 300),
                                                                      //     curve: Curves.easeInOut,
                                                                      //   );
                                                                      // });
                                                                    },
                                                                    child: Text(
                                                                      MyStrings
                                                                          .reply
                                                                          .tr,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            MyAssets.fontMontserrat,
                                                                        color: MyColors
                                                                            .lightGrey,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                  trailing: comment.user?.id ==
                                                          appController
                                                              .user.value.userId
                                                      ? PopupMenuButton<String>(
                                                          onSelected: (value) {
                                                            if (value ==
                                                                'edit') {
                                                              isCommentLoading
                                                                  .value = true;
                                                              editingReplyId
                                                                  .value = '';
                                                              editingCommentId
                                                                      .value =
                                                                  comment.id
                                                                      .toString();
                                                              commentEditTextController
                                                                      .text =
                                                                  comment.text ??
                                                                      "";
                                                              isCommentLoading
                                                                      .value =
                                                                  false;
                                                            } else if (value ==
                                                                'delete') {
                                                              deleteComment(
                                                                  socialPostInfo
                                                                      .value
                                                                      .id!,
                                                                  comment.id!);
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context) =>
                                                                  [
                                                            PopupMenuItem(
                                                              value: 'edit',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: MyColors
                                                                          .primaryLight),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    "Edit",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            MyAssets.fontMontserrat),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 'delete',
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    "Delete",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            MyAssets.fontMontserrat),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : null,
                                                ),
                                                if (activeReplyCommentId
                                                        .value ==
                                                    c.id)
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 20),
                                                      Expanded(
                                                        flex: 1,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            isCommentLoading
                                                                .value = true;
                                                            activeReplyCommentId
                                                                .value = '';
                                                            isCommentLoading
                                                                .value = false;
                                                          },
                                                          child: Icon(
                                                              Icons.clear,
                                                              color: Colors.red,
                                                              size: 15),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 5,
                                                          child: SizedBox(
                                                            height: 40,
                                                            child: TextField(
                                                              maxLines: null,
                                                              minLines: 1,
                                                              controller:
                                                                  commentReplyEditTextController,
                                                              // onTap: (){
                                                              //   // Scroll to the text field when it is tapped
                                                              //   WidgetsBinding.instance.addPostFrameCallback((_) {
                                                              //     if (MediaQuery.of(context).viewInsets.bottom > 0) {
                                                              //       // If the keyboard is visible
                                                              //       commentsScrollController.animateTo(
                                                              //         commentsScrollController.position.maxScrollExtent,
                                                              //         duration: Duration(milliseconds: 300),
                                                              //         curve: Curves.easeInOut,
                                                              //       );
                                                              //     }
                                                              //   });
                                                              // },
                                                              style: MyColors
                                                                      .l111111_dwhite(
                                                                          context)
                                                                  .medium13,
                                                              decoration: InputDecoration(
                                                                  contentPadding: EdgeInsets.all(
                                                                      10.0.w),
                                                                  filled: true,
                                                                  hintText: MyStrings
                                                                      .writeAReply
                                                                      .tr,
                                                                  hintStyle: MyColors
                                                                      .lightGrey
                                                                      .medium13,
                                                                  fillColor: MyColors
                                                                      .noColor,
                                                                  border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(
                                                                          10.0),
                                                                      borderSide: const BorderSide(
                                                                          width:
                                                                              0.05,
                                                                          color: MyColors
                                                                              .lightGrey)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(10.0),
                                                                      borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey))),
                                                            ),
                                                          )),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        flex: 1,
                                                        child: GestureDetector(
                                                          onTap: isReplyLoading
                                                                  .value
                                                              ? null
                                                              : () {
                                                                  addReply(
                                                                      c, index);
                                                                },
                                                          child: isReplyLoading
                                                                  .value
                                                              ? CupertinoActivityIndicator(
                                                                  radius:
                                                                      10, // Adjust the radius for size
                                                                ) // Show loading if true
                                                              : const Icon(
                                                                  Icons
                                                                      .send_outlined,
                                                                  color: MyColors
                                                                      .primaryLight),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if ((c.children ?? [])
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 30.0.w),
                                                    child: ListView.builder(
                                                      itemCount:
                                                          (c.children ?? [])
                                                              .length,
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (context, index) {
                                                        Comment reply =
                                                            (c.children ??
                                                                [])[index];
                                                        return ListTile(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      0.0),
                                                          title: Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () => reply
                                                                            .user
                                                                            ?.role
                                                                            ?.toLowerCase() ==
                                                                        "client"
                                                                    ? Get.toNamed(
                                                                        Routes
                                                                            .individualSocialFeeds,
                                                                        arguments:
                                                                            reply
                                                                                .user)
                                                                    : Get.toNamed(
                                                                        Routes
                                                                            .employeeDetails,
                                                                        arguments: {
                                                                            'employeeId':
                                                                                reply.user?.id ?? ""
                                                                          }),
                                                                child: Text(
                                                                  reply.user?.name !=
                                                                              null &&
                                                                          reply.user!.name!.length >
                                                                              12
                                                                      ? Utils.truncateCharacters(
                                                                          reply.user!.name ??
                                                                              '',
                                                                          12)
                                                                      : reply.user
                                                                              ?.name ??
                                                                          '',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: MyColors
                                                                        .l111111_dwhite(
                                                                            context),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10.w),
                                                              CircleAvatar(
                                                                radius: 1.5,
                                                                backgroundColor:
                                                                    MyColors.l111111_dwhite(
                                                                        context),
                                                              ),
                                                              SizedBox(
                                                                  width: 10.w),
                                                              Text(
                                                                Utils.formatDateTime(
                                                                    reply.createdAt ??
                                                                        DateTime
                                                                            .now(),
                                                                    socialFeed:
                                                                        true),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    fontSize:
                                                                        12,
                                                                    color: MyColors
                                                                        .lightGrey),
                                                              ),
                                                            ],
                                                          ),
                                                          leading: editingReplyId
                                                                      .value ==
                                                                  reply.id
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    onTapCancelCommentEditing();
                                                                  },
                                                                  child: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .red,
                                                                  ))
                                                              : GestureDetector(
                                                                  onTap: () => reply
                                                                              .user
                                                                              ?.role
                                                                              ?.toLowerCase() ==
                                                                          "client"
                                                                      ? Get.toNamed(
                                                                          Routes
                                                                              .individualSocialFeeds,
                                                                          arguments: reply
                                                                              .user)
                                                                      : Get.toNamed(
                                                                          Routes
                                                                              .employeeDetails,
                                                                          arguments: {
                                                                              'employeeId': reply.user?.id ?? ""
                                                                            }),
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundImage: ((reply.user?.profilePicture ?? "").isEmpty ||
                                                                            reply.user?.profilePicture ==
                                                                                "undefined")
                                                                        ? AssetImage(reply.user?.role?.toUpperCase() ==
                                                                                "ADMIN"
                                                                            ? MyAssets.adminDefault
                                                                            : reply.user?.role?.toUpperCase() == "CLIENT"
                                                                                ? MyAssets.clientDefault
                                                                                : MyAssets.employeeDefault)
                                                                        : NetworkImage((reply.user?.profilePicture ?? "").socialMediaUrl),
                                                                  ),
                                                                ),
                                                          subtitle: editingReplyId
                                                                      .value ==
                                                                  reply.id
                                                              ? Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            commentReplyEditTextController,
                                                                        maxLines:
                                                                            null,
                                                                        minLines:
                                                                            1,
                                                                        style: MyColors.l111111_dwhite(context)
                                                                            .medium13,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          contentPadding:
                                                                              EdgeInsets.all(10.0.w),
                                                                          fillColor:
                                                                              MyColors.noColor,
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                            borderSide:
                                                                                BorderSide(color: MyColors.lightGrey, width: 0.5),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    IconButton(
                                                                      icon: isReplyLoading
                                                                              .value
                                                                          ? CupertinoActivityIndicator(
                                                                              radius: 10, // Adjust the radius for size
                                                                            )
                                                                          : Icon(
                                                                              Icons.send,
                                                                              color: MyColors.primaryLight),
                                                                      onPressed: isReplyLoading
                                                                              .value
                                                                          ? null
                                                                          : () async {
                                                                              updateCommentReply(socialPostInfo.value.id, c.id, reply.id);
                                                                            },
                                                                    ),
                                                                  ],
                                                                ) // Show editable field if in edit mode
                                                              : CopyableTextWidget(
                                                                  text: reply
                                                                          .text ??
                                                                      "",
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        MyAssets
                                                                            .fontMontserrat,
                                                                    fontSize:
                                                                        12,
                                                                    color: MyColors
                                                                        .lightGrey,
                                                                  ),
                                                                  textColor:
                                                                      MyColors
                                                                          .lightGrey,
                                                                  linkColor:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                          // Text(
                                                          //         reply.text ??
                                                          //             "",
                                                          //         style:
                                                          //             TextStyle(
                                                          //           fontFamily:
                                                          //               MyAssets
                                                          //                   .fontMontserrat,
                                                          //           fontSize:
                                                          //               12,
                                                          //           color: MyColors
                                                          //               .lightGrey,
                                                          //         ),
                                                          //       ),
                                                          trailing: reply.user
                                                                      ?.id ==
                                                                  appController
                                                                      .user
                                                                      .value
                                                                      .userId
                                                              ? PopupMenuButton<
                                                                  String>(
                                                                  onSelected:
                                                                      (value) {
                                                                    if (value ==
                                                                        'edit') {
                                                                      startEditingReply(
                                                                          c.id!,
                                                                          reply);
                                                                    } else if (value ==
                                                                        'delete') {
                                                                      deleteCommentReply(
                                                                          socialPostInfo
                                                                              .value
                                                                              .id!,
                                                                          c.id!,
                                                                          reply
                                                                              .id!);
                                                                    }
                                                                  },
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context) =>
                                                                          [
                                                                    PopupMenuItem(
                                                                      value:
                                                                          'edit',
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                              Icons.edit,
                                                                              color: MyColors.primaryLight),
                                                                          SizedBox(
                                                                              width: 8),
                                                                          Text(
                                                                            "Edit",
                                                                            style:
                                                                                TextStyle(fontFamily: MyAssets.fontMontserrat),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    PopupMenuItem(
                                                                      value:
                                                                          'delete',
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red),
                                                                          SizedBox(
                                                                              width: 8),
                                                                          Text(
                                                                            "Delete",
                                                                            style:
                                                                                TextStyle(fontFamily: MyAssets.fontMontserrat),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : null,
                                                        );
                                                      },
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                    ),
                                                  )
                                              ],
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  )
                            : SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
