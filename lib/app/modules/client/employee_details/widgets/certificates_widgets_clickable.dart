import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CertificateListWidget extends StatelessWidget {
  final List<dynamic>? certificates;

  CertificateListWidget({required this.certificates});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: (certificates ?? [])
          .map((certificate) {
            if (certificate is Map<String, dynamic>) {
              final name = certificate['certificateName'] ?? 'Unknown';
              final link = certificate['attachment'] ?? '';
              return _buildClickableItem(name, link);
            }
            return SizedBox.shrink(); // Return an empty widget for invalid entries
          })
          .toList(),
    );
  }

  Widget _buildClickableItem(String name, String link) {
    return InkWell(
      onTap: () async {
        log("clicked: ${'https://mh-user-bucket.s3.amazonaws.com/public/users/profile/'+link+'.PDF'}");
        if (await canLaunch(link)) {
          await launch('https://mh-user-bucket.s3.amazonaws.com/public/users/profile/'+link);
        } else {
          // Handle the error if the link cannot be launched
          print('Could not launch $link');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          name,
          style: TextStyle(
            color: Colors.blue, // Make the text appear as a link
            decoration: TextDecoration.underline,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
