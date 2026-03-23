import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../common/widgets/profile_picture_widget.dart';
import '../../../../enums/custom_button_style.dart';
import '../controllers/employee_edit_profile_controller.dart';

class CandidateProfileImageUploadWidget extends GetWidget<EmployeeEditProfileController> {
  const CandidateProfileImageUploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.loading.value
        ? Center(child: CustomLoader.loading())
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageSourceActionSheet(context); // Show options for camera and gallery
                },
                child: Obx(() {
                  bool isImageLoading = controller.profilePicUrl.isNotEmpty && controller.candidateProfilePictureController.selectedImage.value == null;
                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          if (controller.candidateProfilePictureController.selectedImage.value != null)
                            CircleAvatar(
                              radius: 80.r,
                              backgroundColor: const Color.fromRGBO(238, 238, 238, 1),
                              backgroundImage: FileImage(controller.candidateProfilePictureController.selectedImage.value!),
                            )
                          else if (controller.profilePicUrl.isNotEmpty)
                            ProfilePictureWidget(
                              height: 160, // double radius for square dimension compatibility
                              viewOnly: true,
                              profilePictureUrl: controller.profilePicUrl.value.imageUrl,
                            )
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
                          
                          // if (isImageLoading) 
                          //   Positioned(
                          //     child: CupertinoActivityIndicator(), // Loading indicator while loading network image
                          //   ),
                          
                          Positioned(
                            // bottom: -5,
                            // right: 35,
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
        Obx(()=>         Visibility(
visible: controller.candidateProfilePictureController.selectedImage.value != null,
                child: CustomButtons.button(
                  height: 48.h,
                  text: "Update Image",
                  
                  margin: EdgeInsets.zero,
                  fontSize: 14.sp,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  onTap: controller.candidateProfilePictureController.uploadProfileImage,
                ),
              )),
            ],
          ));
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
                  controller.candidateProfilePictureController.pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  controller.candidateProfilePictureController.pickImageFromCamera();
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
