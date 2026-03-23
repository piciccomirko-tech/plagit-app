import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';

class AdminSearchController extends GetxController {
  var searchQuery = ''.obs;
  var searchResults = <Map<String, dynamic>>[].obs;

  // Predefined search items with their routes
  final List<Map<String, dynamic>> features = [
    {'title': 'Home', 'route': Routes.adminRoot},
    {'title': 'Dashboard', 'route': Routes.adminDashboard},
    {'title': 'Todays Candidates', 'route': Routes.adminTodaysEmployees},
    {'title': 'Messages', 'route': Routes.chatIt},
    {'title': 'Requests', 'route': Routes.adminClientRequest},
    {'title': 'Social Posts', 'route': Routes.adminRoot},
    {'title': 'Candidates', 'route': Routes.adminAllEmployees},
    {'title': 'Clients', 'route': Routes.adminAllClients},
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize searchResults with all items
    searchResults.value = features;
  }

  // Search functionality
  void onSearch(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      // Show all items when the input is empty
      searchResults.value = features;
    } else {
      // Filter items based on the search query
      searchResults.value = features
          .where((item) =>
              item['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
