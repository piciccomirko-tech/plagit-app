import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/models/upload_file_for_social_feed_model.dart';
import 'package:mh/app/modules/common_modules/create_post/controllers/create_post_controller.dart';

class CreatePostView extends GetView<CreatePostController> {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Obx(
      () => Scaffold(
        appBar: _buildCreatePostAppbar(context),
        body: Stack(
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
                        _buildMediaGrid(),
                        _buildLoadingMedia(),
                        SizedBox(height: 70.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildUploadMediaButton(context)
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMedia() {
    if (controller.isUploadLoading.value == false) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 15.w),
        const SpinKitThreeBounce(
          color: MyColors.primaryLight,
          size: 30,
        ),
      ],
    );
  }

  Widget _buildContentInputField(BuildContext context) {
    return TextFormField(
      maxLines: null,
      minLines: 5,
      controller: controller.tecContent,
      autofocus: false,
      style: MyColors.l111111_dwhite(context).regular14,
      onChanged: ((newVal) {
        controller.newTextContent.value = newVal;
      }),
      decoration: InputDecoration(
        fillColor: MyColors.lightCard(context),
        filled: true,
        hintText: "write caption here.",
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

  Widget _buildUploadMediaButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: controller.isUploading.value
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () => controller.filePickAndCompressed(),
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
                      style: MyColors.primaryLight.semiBold16,
                    )
                  ],
                ),
              ),
            ),
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
        var file = controller.selectedFiles[index];
        return _buildMediaGridItem(file, index);
      },
    );
  }

  Widget _buildMediaGridItem(PlatformFileUpload file, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: double.infinity,
                height: size,
                child: _buildMediaWidget(file),
              ),
            ),
            _buildCompressedProgress(file),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  controller.selectedFiles.removeAt(index);
                  controller.mediaPathList.removeAt(index);
                },
                child: const CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompressedProgress(PlatformFileUpload file) {
    return Positioned(
      top: 10,
      left: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: MyColors.primaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          file.uploadPercentage == 0
              ? "Uploading..."
              : file.uploadPercentage >= 100.00
                  ? "Upload Completed"
                  : "Uploaded ${file.uploadPercentage.toStringAsFixed(0)}%",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
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
        _buildAppBarAction(),
      ],
    );
  }

  Widget _buildAppBarAction() {
    return Obx(() {
      final isCompressionLoading = controller.isUploadLoading.value;

      if (isCompressionLoading) {
        return _publishPost(canPressed: false);
      }
      return _publishPost(canPressed: true);
    });
  }

  Widget _publishPost({required bool canPressed}) {
    final isCompressionLoading = controller.isUploadLoading.value;

    return GestureDetector(
      onTap: isCompressionLoading
          ? controller.mediaLoadingErrorSnackbar
          : ((controller.title).isNotEmpty
              ? controller.updateSocialPost
              : controller.createPost),
      child: Container(
        width: 100.0,
        height: 40.0,
        margin: EdgeInsets.only(
          bottom: 5.w,
          right: 10.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(33.0),
          gradient:
              canPressed ? Utils.primaryGradient : Utils.secondaryGradient,
        ),
        alignment: Alignment.center,
        child: Text(
          (controller.title).isNotEmpty
              ? MyStrings.update.tr
              : MyStrings.publish.tr,
          style: MyColors.white.semiBold13,
        ),
      ),
    );
  }

  Widget _buildMediaWidget(PlatformFileUpload file) {
    final fileType = file.type;

    if (fileType == "image") {
      return file.file.path!.startsWith('/')
          ? Image.file(
              File(file.file.path!),
              fit: BoxFit.cover,
            )
          : CachedNetworkImage(
              imageUrl: file.file.path!.socialMediaUrl,
              fit: BoxFit.cover,
            );
    } else if (fileType == "video") {
      return Image.asset(
        MyAssets.videoThumbnail,
        fit: BoxFit.cover,
      );
    } else {
      return Center(child: Text("Unsupported Media"));
    }
  }

  String getFileType(String path) {
    if (path.endsWith(".jpg") || path.endsWith(".png")) {
      return "image";
    } else if (path.endsWith(".mp4") || path.endsWith(".mov")) {
      return "video";
    }
    return "unknown";
  }
}
