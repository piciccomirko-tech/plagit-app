import 'package:mh/app/common/utils/exports.dart';

class HomeCardWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final void Function() onTap;
  const HomeCardWidget({super.key, required this.imageUrl, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10.0), color: MyColors.lightCard(context)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(imageUrl, height: 40, width: 40),
              Text(title, style: MyColors.l111111_dwhite(context).semiBold12)
            ],
          ),
        ),
      ),
    );
  }
}
