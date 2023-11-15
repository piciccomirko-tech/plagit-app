import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/position_info_model.dart';

class ClientUniformImageWidget extends StatelessWidget {
  final PositionInfoDetailsModel positionInfoDetailsModel;
  const ClientUniformImageWidget({super.key, required this.positionInfoDetailsModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
            child: Column(children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomAppbarBackButton(),
                  Text('Uniform List', style: MyColors.l111111_dwhite(context).semiBold20),
                  const Wrap()
                ],
              ),
              const SizedBox(height: 10),
               Text('Here are the uniforms for different posts', style: MyColors.l111111_dwhite(context).medium15),
              const SizedBox(height: 5),
               Text('provided by us', style: MyColors.l111111_dwhite(context).medium15),
              const SizedBox(height: 20),
              SizedBox(
                height: Get.width * 0.8,
                child: positionInfoDetailsModel.images != null && positionInfoDetailsModel.images!.isNotEmpty
                    ? ListView.builder(
                        itemCount: positionInfoDetailsModel.images?.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CustomNetworkImage(
                                    fit: BoxFit.cover, url: (positionInfoDetailsModel.images![index]).uniformImageUrl)),
                          );
                        })
                    : const NoItemFound(),
              ),
              const SizedBox(height: 20),
              Text(positionInfoDetailsModel.name ?? '', style: MyColors.l111111_dwhite(context).semiBold18)
            ])));
  }
}
