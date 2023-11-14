import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';

class ClientUniformImageWidget extends StatelessWidget {
  final List<String> imageList;
  const ClientUniformImageWidget({super.key, required this.imageList});

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
              const Text('Here are the uniforms for different posts'),
              const SizedBox(height: 5),
              const Text('provided by us'),
              const SizedBox(height: 20),
              SizedBox(
                height: Get.width,
                child: ListView.builder(
                    itemCount: imageList.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return CustomNetworkImage(url: (imageList[index]).imageUrl);
                    }),
              )
            ])));
  }
}
