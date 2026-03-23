
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';

class ClientHomePremiumCandidateCategorySliderWidget
    extends GetWidget<ClientHomePremiumController> {
  const ClientHomePremiumCandidateCategorySliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: Get.width>600?92.h:100,
        child: ListView.builder(
            itemCount: controller.positionList.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index){
              DropdownItem position = controller.positionList[index];
              return GestureDetector(
                onTap: ()=>controller.onPositionClick(position),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34.8,
                          backgroundColor: MyColors.primaryLight.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.network((position.logo ?? '').uniformImageUrl),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('${position.name}',
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                            style:  MyColors.l111111_dtext(context).medium12),
                      ],
                    ),
                  ),
                ),
              );
            })
    );
  }
}