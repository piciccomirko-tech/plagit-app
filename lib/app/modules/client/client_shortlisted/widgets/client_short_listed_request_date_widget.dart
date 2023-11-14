import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/common/widgets/time_range_widget.dart';
import 'package:mh/app/modules/client/client_shortlisted/controllers/client_shortlisted_controller.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class ClientShortListedRequestDateWidget extends StatelessWidget {
  final List<RequestDateModel> requestDateList;
  final String shortListId;
  const ClientShortListedRequestDateWidget({super.key, required this.requestDateList, required this.shortListId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomAppbarBackButton(),
                Text('${requestDateList.calculateTotalDays()} Days Selected',
                    style: MyColors.l111111_dwhite(context).semiBold15),
                const Wrap()
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: requestDateList.length,
                  itemBuilder: (context, index) {
                    RequestDateModel requestDate = requestDateList[index];
                    return TimeRangeWidget(requestDate: requestDate, hasDeleteOption: true, onTap: ()=>Get.find<ClientShortlistedController>().onDateRemoveClick(index: index, requestDateList: requestDateList, shortListId: shortListId));
                  }),
            )
          ],
        ),
      ),
    );
  }
}
