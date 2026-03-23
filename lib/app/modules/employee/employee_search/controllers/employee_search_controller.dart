import 'dart:async';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_search/widgets/employee_search_item_widget.dart';

class EmployeeSearchController extends GetxController{
  TextEditingController tecSearch = TextEditingController();
  RxBool showClearIcon = false.obs;

  final EmployeeHomeController employeeHomeController =
  Get.find<EmployeeHomeController>();

  BuildContext? context;

  Timer? _debounce;  // Timer for manually handling debounce

  // This method is triggered when the search text changes
  void onSearchChanged(String query) {
    // Clear any existing timer to prevent multiple searches
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Start a new timer (500ms delay) before executing the search
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      // Perform search after the delay
      _performSearch(query);
    });

    // Show or hide the clear icon based on the input
    showClearIcon.value = query.isNotEmpty;

    // Log search input changes
  }

  // Perform the actual search logic
  void _performSearch(String query) {
    employeeHomeController.featureList.clear();

    if (query.isNotEmpty) {
      // Log the start of the search
      // Filter the positions based on the search query
      var filteredPositions = employeeHomeController.appController.employeeSearchList.where(
              (item) => item.name!.toLowerCase().contains(query.toLowerCase())
      );

      // Log the number of results found
      // Add the filtered results to the position list
      employeeHomeController.featureList.addAll(filteredPositions);

      // Refresh the position list to update the UI
      employeeHomeController.featureList.refresh();

      // Display the search results
      employeeHomeController.featureList.isNotEmpty? showSearchItem():
      Utils.showSnackBar(
          message: MyStrings.foundNothing.tr,
          isTrue: false);
    } else {
      clearIconTap();  // Reset if query is empty
    }
  }

  // Clear search input and reset state
  void clearIconTap() {
    tecSearch.clear();
    showClearIcon.value = false;
    employeeHomeController.featureList.clear();
    Utils.unFocus();

  }

  // Show the search results in a bottom sheet
  void showSearchItem() {
    Get.bottomSheet(
      isScrollControlled: true,
      const EmployeeSearchItemWidget(),
    );
  }

  // Dispose of the timer when the controller is destroyed
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

}