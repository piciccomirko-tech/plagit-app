import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/admin/admin_home/models/admin_home_card_model.dart';

class AdminHomeCardWidget extends StatelessWidget {
  final AdminHomeCardModel adminHomeCardModel;
  const AdminHomeCardWidget({super.key, required this.adminHomeCardModel});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: adminHomeCardModel.onTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black, adminHomeCardModel.backgroundColor],
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                stops: const [0.1, 0.9],
                tileMode: TileMode.clamp),
          borderRadius: BorderRadius.circular(10.0),
            //color: adminHomeCardModel.backgroundColor
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(adminHomeCardModel.title, style: MyColors.white.semiBold20),
            Image.asset(
              adminHomeCardModel.icon,
              height: 60,
              width: 60,
            )
          ],
        ),
      ),
    );
  }
}
