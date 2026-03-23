import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';

typedef OnRatingUpdate = void Function(double rating);
typedef OnReviewSubmit = void Function(
    {required String id, required String reviewForId});
typedef OnCancelClick = void Function(
    {required String id,
    required String reviewForId,
    required double manualRating});

class RatingReviewWidget extends StatelessWidget {
  final ReviewDialogDetailsModel reviewDialogDetailsModel;
  final OnRatingUpdate onRatingUpdate;
  final OnCancelClick onCancelClick;
  final TextEditingController tecReview;
  final OnReviewSubmit onReviewSubmit;
  final String reviewFor;

  const RatingReviewWidget(
      {super.key,
      required this.reviewFor,
      required this.onRatingUpdate,
      required this.onReviewSubmit,
      required this.onCancelClick,
      required this.reviewDialogDetailsModel,
      required this.tecReview});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0.w),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)),
                color: MyColors.lightCard(context)),
            height: 400,
            child: Center(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(MyStrings.ratingJourney.tr.toUpperCase(),
                      style: MyColors.l111111_dwhite(context).semiBold16),
                  SizedBox(height: 10.h),
                  // Text("${reviewDialogDetailsModel.restaurantDetails?.profilePicture
                  //                       }" , maxLines: null,),
                
                  ClipOval(
                    child: ((reviewFor == 'client'
                                ? (reviewDialogDetailsModel.restaurantDetails
                                            ?.profilePicture ??
                                        '')
                                    .isEmpty
                                : (reviewDialogDetailsModel
                                            .employeeDetails?.profilePicture ??
                                        '')
                                    .isEmpty) ||
                            (reviewFor == 'client'
                                ? reviewDialogDetailsModel
                                        .restaurantDetails?.profilePicture ==
                                    "undefined"
                                : reviewDialogDetailsModel
                                        .employeeDetails?.profilePicture ==
                                    "undefined"))
                        ? DefaultImageWidget(
                            radius: 80,
                            defaultImagePath: reviewFor == 'client'
                                ? MyAssets.clientDefault
                                : MyAssets.employeeDefault)
                        : CachedNetworkImage(
                            imageUrl: reviewFor == 'client'
                                ? (reviewDialogDetailsModel.restaurantDetails
                                            ?.profilePicture ??
                                        '')
                                    .imageUrl
                                : (reviewDialogDetailsModel
                                            .employeeDetails?.profilePicture ??
                                        '')
                                    .imageUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 35.w * 2,
                              height: 35.w * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) =>
                                const CupertinoActivityIndicator(), // Placeholder widget while loading
                            errorWidget: (context, url, error) => const Icon(Icons
                                .image_not_supported_outlined), // Error widget if image fails to load
                          ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                      reviewFor == 'client'
                          ? reviewDialogDetailsModel
                                  .restaurantDetails?.restaurantName ??
                              ''
                          : reviewDialogDetailsModel.employeeDetails?.name ??
                              '',
                      style: MyColors.l111111_dwhite(context).semiBold15),
                  SizedBox(height: 10.h),
                  RatingBar.builder(
                    initialRating: 0.0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: onRatingUpdate,
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: tecReview,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: null,
                    cursorColor: MyColors.c_C6A34F,
                    style: MyColors.l111111_dwhite(context).regular14,
                    decoration: MyDecoration.inputFieldDecoration(
                      context: context,
                      label: MyStrings.commentIfAny.tr,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomButtons.button(
                    height: 48,
                    margin: EdgeInsets.zero,
                    onTap: () {
                      onReviewSubmit(
                          id: reviewDialogDetailsModel.id ?? '',
                          reviewForId: reviewFor == 'client'
                              ? reviewDialogDetailsModel
                                      .restaurantDetails?.hiredBy ??
                                  ''
                              : reviewDialogDetailsModel.employeeId ?? '');
                    },
                    text: MyStrings.submit.tr,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  ),
                ],
              ),
            ))),
        Positioned.fill(
            child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              onTap: () {
                onCancelClick(
                    id: reviewDialogDetailsModel.id ?? '',
                    reviewForId: reviewFor == 'client'
                        ? reviewDialogDetailsModel.restaurantDetails?.hiredBy ??
                            ''
                        : reviewDialogDetailsModel.employeeId ?? '',
                    manualRating: 5.0);
              },
              child: const CircleAvatar(
                radius: 13.0,
                backgroundColor: Colors.red,
                child: Icon(Icons.clear, color: Colors.white, size: 15),
              ),
            ),
          ),
        ))
      ],
    );
  }
}
