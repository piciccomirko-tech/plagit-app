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
import '../controllers/new_create_post_controller.dart';

class NewCreatePostView extends GetView<NewCreatePostController> {
  const NewCreatePostView({super.key});
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
                            Obx(() {
                              return controller.selectedFiles.isNotEmpty
                                  ? SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            controller.selectedFiles.length,
                                        itemBuilder: (context, index) {
                                          final String filePath =
                                              controller.selectedFiles[index];
                                          final bool isVideo = filePath
                                                  .toLowerCase()
                                                  .endsWith('.mp4') ||
                                              filePath
                                                  .toLowerCase()
                                                  .endsWith('.mov');

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: isVideo
                                                      ? Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Obx(() => controller
                                                                            .thumbnailLoadingStates[
                                                                        filePath] ==
                                                                    true
                                                                ? Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey[200],
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                                  child: const Center(
                                                                      child:
                                                                          CircularProgressIndicator()),
                                                                )
                                                                : controller.videoThumbnails[
                                                                            filePath] !=
                                                                        null
                                                                    ? Image
                                                                        .file(
                                                                        File(controller.videoThumbnails[filePath] ??
                                                                            ''),
                                                                        height:
                                                                            100,
                                                                        width:
                                                                            100,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : Image
                                                                        .asset(
                                                                        MyAssets
                                                                            .videoThumbnail,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        height:
                                                                            100,
                                                                        width:
                                                                            100,
                                                                        // width: Get.width,
                                                                      )),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.3),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              child: const Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                                size: 30,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Image.file(
                                                          File(filePath),
                                                          height: 100,
                                                          width: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      // Get the file path to safely remove corresponding thumbnail
                                                      if (isVideo) {
                                                        controller
                                                            .videoThumbnails
                                                            .remove(filePath);
                                                      }
                                                      // Remove the file from selectedFiles list
                                                      controller.selectedFiles
                                                          .removeAt(index);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container();
                            }),

                            SizedBox(height: 70.w),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildUploadMediaButton(context)
              ],
            )
          : const SpinKitThreeBounce(
              color: MyColors.primaryLight,
              size: 30,
            )),
      /*body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(
                hintText: 'Write something...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.pickMedia(context),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Select Media'),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return controller.selectedFiles.isNotEmpty
                  ? SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedFiles.length,
                        itemBuilder: (context, index) {
                          final bool isVideo = controller.selectedFiles[index]
                                  .toLowerCase()
                                  .endsWith('.mp4') ||
                              controller.selectedFiles[index]
                                  .toLowerCase()
                                  .endsWith('.mov');

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: isVideo
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.file(
                                              File(controller.videoThumbnails[
                                                      controller.selectedFiles[
                                                          index]] ??
                                                  ''),
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.3),
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
                                          File(controller.selectedFiles[index]),
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: () {
                                      controller.selectedFiles.removeAt(index);
                                      if (isVideo) {
                                        controller.videoThumbnails.remove(
                                            controller.selectedFiles[index]);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : Container();
            }),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.isUploading.value
                  ? null
                  : () => controller.createPost(context),
              icon: controller.isUploading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(controller.isUploading.value
                  ? 'Uploading...'
                  : 'Create Post'),
            ),
          ],
        ),
      ),*/
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
        fontWeight: FontWeight.w500,
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
          width: 35.h,
          height: 35.h,
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
          style: MyColors.l111111_dwhite(context)
              .medium15
              .merge(TextStyle(fontSize: 17)),
        ),
        SizedBox(height: 15.w)
      ],
    );
  }

  Widget _buildUploadMediaButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: controller.isUploading.value
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () => controller.pickMultipleMediaFiles(),
              child: Container(
                height: 70,
                width: Get.width,
                padding: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  color: MyColors.lightCard(context),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_enhance_outlined,
                        color: MyColors.primaryLight),
                    Text(
                      " ${MyStrings.uploadPhotoVideo.tr}",
                      style: MyColors.primaryLight.semiBold16
                          .merge(TextStyle(fontSize: 15)),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildCreatePostAppbar(BuildContext context) {
    return CustomAppbar.appbar(
      centerTitle: true,
      title: (controller.title).isNotEmpty
          ? MyStrings.updateSocialPost.tr
          : MyStrings.createSocialPost.tr,
      context: context,
      actions: [
        // _buildAppBarAction(),
        GestureDetector(
          onTap: controller.isUploading.value
              ? null
              : (controller.title).isNotEmpty
                  // ? () => controller.updateSocialPost(context)
                  ? () => controller.updatePost(context)
                  : () => controller.createPost(context),
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
                (controller.title).isNotEmpty
                    ? MyStrings.update.tr
                    : MyStrings.publish.tr,
                style: MyColors.white.semiBold13.merge(TextStyle(fontSize: 15)),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Widget _buildAppBarAction() {
  //   return Obx(() {
  //     final isCompressionLoading = controller.isUploadLoading.value;
  //
  //     if (isCompressionLoading) {
  //       return _publishPost(canPressed: false);
  //     }
  //     return _publishPost(canPressed: true);
  //   });
  // }
  //
  // Widget _publishPost({required bool canPressed}) {
  //   final isCompressionLoading = controller.isUploadLoading.value;
  //
  //   return GestureDetector(
  //     onTap: isCompressionLoading
  //         ? controller.mediaLoadingErrorSnackbar
  //         : ((controller.title).isNotEmpty
  //             ? controller.updateSocialPost
  //             : controller.createPost),
  //     child: Container(
  //       width: 100.0,
  //       height: 40.0,
  //       margin: EdgeInsets.only(
  //         bottom: 5.w,
  //         right: 10.w,
  //       ),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(33.0),
  //         gradient:
  //             canPressed ? Utils.primaryGradient : Utils.secondaryGradient,
  //       ),
  //       alignment: Alignment.center,
  //       child: Text(
  //         (controller.title).isNotEmpty
  //             ? MyStrings.update.tr
  //             : MyStrings.publish.tr,
  //         style: MyColors.white.semiBold13,
  //       ),
  //     ),
  //   );
  // }
}
