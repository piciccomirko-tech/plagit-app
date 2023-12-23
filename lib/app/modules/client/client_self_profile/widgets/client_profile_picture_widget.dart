import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/client/client_self_profile/controllers/client_self_profile_controller.dart';

class ClientProfilePictureWidget extends GetWidget<ClientSelfProfileController> {
  const ClientProfilePictureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        InkResponse(
          onTap: () => controller.showImagePickerBottomSheet(context),
          child: Stack(
            children: [
              Container(
                width: 150.h,
                height: 150.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2.5,
                      color: MyColors.c_C6A34F,
                    )),
                child: Obx(
                  () => controller.pickedImage.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(130),
                          child: Image.file(controller.pickedImage.value!, fit: BoxFit.cover))
                      : (controller.employee.value.details?.profilePicture ?? "").isEmpty
                          ? Image.asset(MyAssets.clientFixedLogo)
                          : CustomNetworkImage(
                              url: (controller.employee.value.details?.profilePicture ?? "").imageUrl,
                              radius: 130,
                            ),
                ),
              ),
              Positioned.fill(
                  child: Align(alignment: Alignment.bottomCenter, child: Image.asset(MyAssets.intersect, width: 90))),
              Positioned.fill(
                  bottom: 5,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(MyAssets.camera, width: 30, height: 30, color: MyColors.white))),
            ],
          ),
        ),
        /*Container(
          width: 130.h,
          height: 130.h,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2.5,
                color: MyColors.c_C6A34F,
              )),
          child: Image.asset(MyAssets.clientFixedLogo),
        )*/
        const Spacer(),
      ],
    );
  }
}
