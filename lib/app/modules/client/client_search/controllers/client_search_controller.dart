import 'dart:async';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_search/widgets/client_search_item_widget.dart';

class ClientSearchController extends GetxController {
  TextEditingController tecSearch = TextEditingController();
  RxBool showClearIcon = false.obs;

  final ClientHomeController clientHomeController =
      Get.find<ClientHomeController>();

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
    clientHomeController.positionList.clear();

    if (query.isNotEmpty) {
      // Log the start of the search
      // Filter the positions based on the search query
      var filteredPositions = clientHomeController.appController.allActivePositions.where(
        (item) => item.name!.toLowerCase().contains(query.toLowerCase())
      );

      // Log the number of results found
      // Add the filtered results to the position list
      clientHomeController.positionList.addAll(filteredPositions);

      // Refresh the position list to update the UI
      clientHomeController.positionList.refresh();

      // Display the search results
      showSearchItem();
    } else {
      clearIconTap();  // Reset if query is empty
    }
  }

  // Clear search input and reset state
  void clearIconTap() {
    tecSearch.clear();
    showClearIcon.value = false;
    clientHomeController.positionList.clear();
    Utils.unFocus();

  }

  // Show the search results in a bottom sheet
  void showSearchItem() {
    Get.bottomSheet(
      isScrollControlled: true,
      const ClientSearchItemWidget(),
    );
  }

  // Dispose of the timer when the controller is destroyed
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
