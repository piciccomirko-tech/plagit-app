import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import '../../../../common/widgets/profile_picture_widget.dart';
import '../../../../enums/custom_button_style.dart';
import '../controllers/client_edit_profile_controller.dart';
import '../controllers/image_upload_controller.dart';

class ProfileImageUploadWidget extends StatelessWidget {
  // Initialize the controller

  final ClientEditProfileController clientEditProfileController = Get.find<ClientEditProfileController>();
  final ProfilePictureController controller = Get.find<ProfilePictureController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showImageSourceActionSheet(context); // Show options for camera and gallery
          },
          child: Obx(() {

            return Column(
              children: [
                // Text("${controller.selectedImage}"),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Show the selected image if available
                    if (controller.selectedImage.value != null)
                      CircleAvatar(
                        radius: 80.r,
                        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
                        backgroundImage: FileImage(controller.selectedImage.value!),
                      )
                    // Use ProfilePictureWidget if no new image is selected, but profile picture URL is available
                    else if (clientEditProfileController.profilePicUrl.isNotEmpty)
                      ProfilePictureWidget(
                        height: 160, // Double the radius for compatibility
                        viewOnly: true,
                        profilePictureUrl: clientEditProfileController.getProfilePicture,
                      )
                    // Show placeholder if no image or URL is available
                    else
                      CircleAvatar(
                        radius: 80.r,
                        backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 25.sp, color: Colors.grey),
                            Text('Upload Image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),

                    // Show loading indicator while the network image is loading
                    // if (isImageLoading)
                    //   Positioned(
                    //     child: CupertinoActivityIndicator(),
                    //   ),

                    // Upload icon overlay at the bottom-right of the profile image
                    Positioned(
                      // bottom: 0,
                      // right: 40,
                      child: CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.cloud_upload, size: 18.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
        SizedBox(height: 20),
    Obx(()=>    Visibility(
          visible: controller.selectedImage.value != null,

          child: CustomButtons.button(
            height: 48.h,
            text: "Update Image",
            margin: EdgeInsets.zero,
            fontSize: 14.sp,
            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            onTap: controller.uploadProfileImage,
          ),
        )),
      ],
    );
  }

  // Show options for camera or gallery
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  controller.pickImageFromGallery(); // Pick image from gallery
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  controller.pickImageFromCamera(); // Pick image from camera
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
