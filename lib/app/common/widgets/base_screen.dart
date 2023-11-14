import '../utils/exports.dart';

class BaseScreen extends StatelessWidget {
  final Widget appbar;
  final Widget body;
  final double height;

  const BaseScreen({
    super.key,
    required this.appbar,
    required this.body,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(height), // Set this height
        child: appbar,
      ),
      body: body,
    );
  }
}
