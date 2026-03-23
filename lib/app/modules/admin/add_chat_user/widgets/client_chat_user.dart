import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/modules/admin/add_chat_user/controllers/add_chat_user_controller.dart';

class ClientChatUser extends GetWidget<AddChatUserController> {
  const ClientChatUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if(controller.clientsDataLoaded.value == false){
        return Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Center(child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 90)),
        );
      }
      else if(controller.clientsDataLoaded.value == true && (controller.clients.value.users??[]).isEmpty){
        return const Center(child: NoItemFound());
      }
      else{
        return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: (controller.clients.value.users??[]).length,
            itemBuilder: (BuildContext context, int index){
              Employee client = (controller.clients.value.users??[])[index];
              return ListTile(
                onTap: ()=>controller.onUserTapped(employee: client),
                leading: client.profilePicture!=null && client.profilePicture!.isNotEmpty?
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage((client.profilePicture??"").imageUrl),
                ):CircleAvatar(
                  backgroundColor: MyColors.primaryLight,
                  radius: 26,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.transparent,
                    backgroundImage:  AssetImage(MyAssets.clientDefault),))
                ,
                title: Text(client.restaurantName??"", style: MyColors.l111111_dwhite(context).medium16),
                subtitle: Text(client.email??"", style: MyColors.l111111_dwhite(context).regular13),
              );
            });
      }
    });
  }
}
