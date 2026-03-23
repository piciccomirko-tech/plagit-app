import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'dart:io';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_assets.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/values/my_strings.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/default_image_widget.dart';
import '../controllers/update_post_controller.dart';

class UpdatePostView extends GetView<UpdatePostController> {
  const UpdatePostView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCreatePostAppbar(context),
      body: Obx(() => controller.isAllDataGenerated.isTrue
          ? Stack(
              children: [
                SizedBox(
                  height: Get.height,
                  child: GestureDetector(
                    onTap: () => Utils.unFocus(),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(15.0.w),
                        child: Column(
                          children: [
                            _buildProfileRow(context),
                            SizedBox(height: 15.w),
                            _buildContentInputField(context),
                            SizedBox(height: 15.w),
                            // _buildMediaGrid(),
                            // _buildLoadingMedia(),
                            _buildMediaGrid(),
                            // Obx(() {
                            //   return controller.selectedFiles.isNotEmpty
                            //       ? SizedBox(
                            //           height: 100,
                            //           child: ListView.builder(
                            //             scrollDirection: Axis.horizontal,
                            //             itemCount:
                            //                 controller.selectedFiles.length,
                            //             itemBuilder: (context, index) {
                            //               final String filePath =
                            //                   controller.selectedFiles[index];
                            //               final bool isVideo = filePath
                            //                       .toLowerCase()
                            //                       .endsWith('.mp4') ||
                            //                   filePath
                            //                       .toLowerCase()
                            //                       .endsWith('.mov');
                            //
                            //               return Padding(
                            //                 padding: const EdgeInsets.only(
                            //                     right: 8.0),
                            //                 child: ClipRRect(
                            //                   borderRadius:
                            //                       BorderRadius.circular(8),
                            //                   child: isVideo
                            //                       ? Stack(
                            //                           alignment:
                            //                               Alignment.center,
                            //                           children: [
                            //                             Obx(() => controller
                            //                                             .thumbnailLoadingStates[
                            //                                         filePath] ==
                            //                                     true
                            //                                 ? const Center(
                            //                                     child:
                            //                                         CircularProgressIndicator())
                            //                                 : controller.videoThumbnails[
                            //                                             filePath] !=
                            //                                         null
                            //                                     ? Image.file(
                            //                                         File(controller
                            //                                                 .videoThumbnails[filePath] ??
                            //                                             ''),
                            //                                         height: 100,
                            //                                         width: 100,
                            //                                         fit: BoxFit
                            //                                             .cover,
                            //                                       )
                            //                                     : Image.asset(
                            //                                         MyAssets
                            //                                             .videoThumbnail,
                            //                                         fit: BoxFit
                            //                                             .cover,
                            //                                         height: 100,
                            //                                         width: 100,
                            //                                         // width: Get.width,
                            //                                       )),
                            //                             Container(
                            //                               decoration:
                            //                                   BoxDecoration(
                            //                                 color: Colors.black
                            //                                     .withOpacity(
                            //                                         0.3),
                            //                                 shape:
                            //                                     BoxShape.circle,
                            //                               ),
                            //                               padding:
                            //                                   const EdgeInsets
                            //                                       .all(8),
                            //                               child: const Icon(
                            //                                 Icons.play_arrow,
                            //                                 color: Colors.white,
                            //                                 size: 30,
                            //                               ),
                            //                             ),
                            //                           ],
                            //                         )
                            //                       : Image.file(
                            //                           File(filePath),
                            //                           height: 100,
                            //                           width: 100,
                            //                           fit: BoxFit.cover,
                            //                         ),
                            //                 ),
                            //               );
                            //             },
                            //           ),
                            //         )
                            //       : Container();
                            // }),

                            SizedBox(height: 70.w),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // _buildUploadMediaButton(context)
              ],
            )
          : const SpinKitThreeBounce(
              color: MyColors.primaryLight,
              size: 30,
            )),
    );
  }

  Widget _buildContentInputField(BuildContext context) {
    return TextFormField(
      maxLines: null,
      minLines: 5,
      controller: controller.descriptionController,
      autofocus: false,
      // style: MyColors.l111111_dwhite(context).regular14,
      style: TextStyle(
        fontFamily: MyAssets.fontMontserrat,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        decoration: TextDecoration.none,
        color: MyColors.l111111_dwhite(context),
      ),
      onChanged: ((newVal) {
        controller.newTextContent.value = newVal;
      }),
      decoration: InputDecoration(
        fillColor: MyColors.lightCard(context),
        filled: true,
        hintText: "Write caption here.",
        hintStyle: TextStyle(
          color: MyColors.lightGrey,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          fontFamily: MyAssets.fontMontserrat,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: MyColors.noColor,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: MyColors.primaryLight,
            width: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30.h,
          height: 30.h,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: controller.getProfilePictureUrl.isEmpty ||
                  controller.getProfilePictureUrl == "undefined"
              ? DefaultImageWidget(
                  defaultImagePath:
                      Get.find<AppController>().user.value.isEmployee
                          ? MyAssets.employeeDefault
                          : Get.find<AppController>().user.value.isClient
                              ? MyAssets.clientDefault
                              : MyAssets.adminDefault,
                )
              : CustomNetworkImage(
                  radius: 30,
                  url: controller.getProfilePictureUrl.imageUrl,
                ),
        ),
        Text(
          controller.name.length > 25
              ? '  ${controller.name.substring(0, 25)}...'
              : '  ${controller.name}',
          style: MyColors.l111111_dwhite(context).medium15,
        ),
        SizedBox(height: 15.w)
      ],
    );
  }

  PreferredSizeWidget _buildCreatePostAppbar(BuildContext context) {
    return CustomAppbar.appbar(
      centerTitle: true,
      title: MyStrings.updateSocialPost.tr,
      context: context,
      actions: [
        // _buildAppBarAction(),
        GestureDetector(
          onTap: controller.isUploading.value
              ? null
              : () => controller.updatePost(context),
          child: Obx(() {
            final emptyContent = controller.newTextContent.value.isEmpty &&
                controller.selectedFiles.isEmpty;
            return Container(
              width: 100.0,
              height: 40.0,
              margin: EdgeInsets.only(
                bottom: 5.w,
                right: 10.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(33.0),
                gradient: emptyContent
                    ? Utils.secondaryGradient
                    : Utils.primaryGradient,
              ),
              alignment: Alignment.center,
              child: Text(
                MyStrings.update.tr,
                style: MyColors.white.semiBold13,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMediaGrid() {
    if (controller.selectedFiles.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      itemCount: controller.selectedFiles.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (_, index) {
        final String filePath = controller.selectedFiles[index];
        final bool isVideo = filePath.toLowerCase().endsWith('.mp4') ||
            filePath.toLowerCase().endsWith('.mov');

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        MyAssets.videoThumbnail,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        // width: Get.width,
                      ),
                      // Obx(() => controller.thumbnailLoadingStates[filePath] ==
                      //         true
                      //     ? const Center(child: CircularProgressIndicator())
                      //     : controller.videoThumbnails[filePath] != null
                      //         ? Image.file(
                      //             File(controller.videoThumbnails[filePath] ??
                      //                 ''),
                      //             height: 100,
                      //             width: 100,
                      //             fit: BoxFit.cover,
                      //           )
                      //         : Image.asset(
                      //             MyAssets.videoThumbnail,
                      //             fit: BoxFit.cover,
                      //             height: 100,
                      //             width: 100,
                      //             // width: Get.width,
                      //           )),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  )
                : Image.file(
                    File(filePath),
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }
}
