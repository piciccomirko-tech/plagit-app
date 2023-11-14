import 'package:lottie/lottie.dart';

import '../utils/exports.dart';

class NoItemFound extends StatelessWidget {
  const NoItemFound({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(MyAssets.lottie.notFound, height: 300),
          Text(
            "Found Nothing!",
            style: MyColors.l111111_dwhite(context).semiBold18,
          ),
        ],
      ),
    );
  }
}
