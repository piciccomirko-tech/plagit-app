import 'dart:developer';
import '../utils/exports.dart';

class CustomAppBarJobPost {
  static PreferredSize build({
    required String title,
    required BuildContext context,
    List<Widget>? actions,
    bool centerTitle = false,
    bool showBackButton = true,
    VoidCallback? onBackButtonPressed,
    double? radius ,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
  backgroundColor: MyColors.lightCard(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(radius ?? 10.0),
              ),
            ),
            elevation: 0,
        title:     Text(
                  title.tr,
                  style: Get.width > 600
                      ? MyColors.l111111_dwhite(context).semiBold15
                      : MyColors.l111111_dwhite(context).semiBold18,
                ),
        centerTitle: centerTitle,
        leading: showBackButton 
        ? 
           GestureDetector(
              onTap: () {
                  // Check if the callback is null or not
                  if (onBackButtonPressed != null) {
                    log("CustomAppBar: onBackButtonPressed callback called"); // Log inside widget
                    onBackButtonPressed();
                  } else {
                    log("CustomAppBar: No callback, default Get.back()"); // Log if no callback
                    Get.back();
                  }
                },
             child: Container(
                     height: Get.width>600?25.h: 25.h,
                     width: Get.width>600?25.w: 25.w,
                     decoration: BoxDecoration(
              color: MyColors.c_C6A34F,
              borderRadius: BorderRadius.circular(3.86),
                     ),
                     child:  Center(
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
                     ),),
           )
                 
         :null,
            // ? IconButton(
            //     icon: Icon(Icons.arrow_back, color: Colors.black),
              
            //   )
            // : null,
        actions: actions,
      ),
    );
  }
}
