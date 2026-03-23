
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/admin/admin_search/controllers/admin_search_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/no_item_found.dart';

class AdminSearchView extends GetView<AdminSearchController> {
  const AdminSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
          centerTitle: true,
          visibleBack: false,
          title: MyStrings.search.tr ,
          context: context),
      body: 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 25.h,),
            // Search Input
            CustomTextInputField(label: "Search for a feature...", 
            prefixIcon:  Icons.search,
            onChange: (value) => controller.onSearch(value),
            ),
       
            const SizedBox(height: 20),
            // Dynamic Search Results
            Expanded(
              child: Obx(
                () => controller.searchResults.isEmpty
                    ? const Center(
                        child: NoItemFound(),
                      )
                    : ListView.builder(
                        itemCount: controller.searchResults.length,
                        itemBuilder: (context, index) {
                          final result = controller.searchResults[index];
                          return ListTile(
                            title: Text(result['title']!),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              // Navigate to the respective route
                              // Get.toNamed(result['route']!);
                                if (Get.currentRoute == result['route']) {
    // If already on the route, just refresh
    Get.offNamed(result['route']!, preventDuplicates: false);
  } else {
    // Navigate to the new route
    Get.toNamed(result['route']!);
  }
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
