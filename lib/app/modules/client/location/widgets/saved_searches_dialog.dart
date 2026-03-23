import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../controllers/nearby_employee_controller.dart';

class SavedSearchesDialog extends GetWidget<NearbyEmployeeController> {
  const SavedSearchesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: MyColors.lightCard(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                  height: 2,
                  width: 50,
                  color: MyColors.lightGrey,
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 24,
                            color: MyColors.l111111_dwhite(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Saved Searches (${controller.savedSearchList.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: MyAssets.fontMontserrat,
                              color: MyColors.l111111_dwhite(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          if (controller.savedSearchList.isNotEmpty) {
                            controller.deleteAllMapSearch();
                          }
                        },
                        child: Text(
                          'Remove all',
                          style: TextStyle(
                            color: MyColors.c_FF5029,
                            fontSize: 14,
                            fontFamily: MyAssets.fontMontserrat,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                controller.savedSearchList.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: controller.savedSearchList.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final search = controller.savedSearchList[index];
                          return GestureDetector(
                            onTap: () =>
                                controller.onSavedSearchSelected(search),
                            child: Container(
                              color: MyColors.lightCard(context),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            search.address ?? '',
                                            style: TextStyle(
                                              fontFamily:
                                                  MyAssets.fontMontserrat,
                                              color: MyColors.l111111_dwhite(
                                                  context),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: MyColors.primaryDark
                                                .withOpacity(.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            search.position?.name ?? '',
                                            style: TextStyle(
                                              fontFamily:
                                                  MyAssets.fontMontserrat,
                                              color: MyColors.l111111_dwhite(
                                                  context),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Container(
                                        //   padding: const EdgeInsets.symmetric(
                                        //     horizontal: 12,
                                        //     vertical: 6,
                                        //   ),
                                        //   decoration: BoxDecoration(
                                        //     color: MyColors.lightGrey.withOpacity(0.2),
                                        //     borderRadius:
                                        //         BorderRadius.circular(20),
                                        //   ),
                                        //   child: Text(
                                        //     "${Utils.getCurrencySymbol()}${(search.minHourlyRate ?? 0.0).toStringAsFixed(2)}/hour - ${Utils.getCurrencySymbol()}${(search.maxHourlyRate ?? 0.0).toStringAsFixed(2)}/hour",
                                        //     style: TextStyle(
                                        //       fontFamily: MyAssets.fontMontserrat,
                                        //       color: MyColors.l111111_dwhite(
                                        //           context),
                                        //       fontSize: 14,
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    search.totalCount.toString(),
                                    style: TextStyle(
                                        fontFamily: MyAssets.fontMontserrat,
                                        color: MyColors.l111111_dwhite(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      controller.deleteMapSearch(
                                          searchId: search.id ?? "");
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 24,
                                      color: MyColors.lightGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : NoItemFound(),
              ],
            ),
          ),
        ));
  }
}
