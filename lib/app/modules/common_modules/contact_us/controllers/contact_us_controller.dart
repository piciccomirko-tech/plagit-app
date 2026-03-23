import 'dart:developer';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsController extends GetxController {
  void launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Handle the case where the email app is not available
      log("Could not open email client");
    }
  }
}
