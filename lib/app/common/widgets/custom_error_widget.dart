import '../utils/exports.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;

  const CustomErrorWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MyAssets.somethingWrong,
            fit: BoxFit.cover,
          ),
          // Positioned(
          //   bottom: MediaQuery.of(context).size.height * 0.15,
          //   left: MediaQuery.of(context).size.width * 0.3,
          //   right: MediaQuery.of(context).size.width * 0.3,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       Toast.snackbar("Error submit successfully");
          //     },
          //     child: const Text(
          //       "SUBMIT REPORT",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
