import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controller/about-us-controller.dart';

class AboutUsDetailsView extends GetView<AboutUsController> {
  const AboutUsDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "About Us",
        context: context,
        centerTitle: true,
        visibleBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Center(
                child: Image.asset(
                  MyAssets.logo, // Replace with your logo path
                  height: 100, // Adjust as per your design
                ),
              ),
              const SizedBox(height: 20),
              // Title Section
              Text(
                "PLAGIT, where hospitality talent meets opportunity.",
                textAlign: TextAlign.center,
                style:  MyColors.c_DDBD68.regular18,
                
              ),
              const SizedBox(height: 20),
              // Content Section
              Text(
                "PLAGIT represents the evolution of a journey that started in 2016 with Mirko Hospitality. "
                "Led by Mirko Picicco, a renowned Italian businessman deeply rooted in London's restaurant and hotel industry.\n\n"
                "We specialize in connecting top professionals with hospitality’s leading businesses, elevating guest experiences and industry standards. "
                "We lead with an innovative and tech-driven approach, featuring QR codes, dashboards, and our app, to expand the talent search, ensuring the best fit for your needs. "
                "We thrive on understanding your challenges, delivering tailored-made solutions. Many renowned London hotels and restaurants trust us with their staffing, and we’re eager to do the same for you.",
                textAlign: TextAlign.justify,
                style:MyColors.lightGrey.medium14.copyWith(
               ),
                
              ),
              const SizedBox(height: 30),
              // Footer Section
              Divider(
                thickness: 1,
                color: MyColors.primaryLight,
              ),
              Text(
                "Join us on our mission to redefine hospitality talent!",
                textAlign: TextAlign.center,
                style: MyColors.primaryLight.regular18
              ),
            ],
          ),
        ),
      ),
    );
  }
}
