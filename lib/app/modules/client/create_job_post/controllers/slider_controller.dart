import 'package:get/get.dart';

class SliderController extends GetxController {
  // Define an observable RxList to store the type, min, and max values
  var sliderData = <Map<String, dynamic>>[].obs;
  // Fixed ranges for each slider type
  final Map<String, Map<String, String>> fixedRanges = {
    'Age': {'min': "18.0", 'max': "80.0"},
    'Hourly Rate': {'min': "0.0", 'max': "15000.0"},
    'Experience': {'min': "0.0", 'max': "50.0"},
    // Add more types as needed 
  };

  // Retrieve fixed min/max for the type
  Map<String, String> getFixedRangeForType(String type) {
    return fixedRanges[type] ?? {'min': "0.0", 'max': "100.0"};
  }
  // Function to initialize or update the data
  void setSliderData(List<Map<String, dynamic>> newData) {
    sliderData.assignAll(newData);
  }
  void addSliderDataIfNotExists(String type, double minValue, double maxValue) {
  // Check if the type already exists in the list
  int index = sliderData.indexWhere((element) => element['type'] == type);
  
  // If it doesn't exist, add the new item
  if (index == -1) {
    sliderData.add({
      'type': type,
      'min': minValue,
      'max': maxValue,
    });
    sliderData.refresh();  // Notify listeners that the data has changed
  }
}


  // Function to retrieve data by type (e.g., "Age" or "Hourly")
  Map<String, dynamic>? getSliderDataByType(String type) {
    return sliderData.firstWhereOrNull((element) => element['type'] == type);
  }
 // Function to add or update min/max values based on type
  void addOrUpdateSliderData(String type, double minValue, double maxValue) {
    // Check if the type already exists in the list
    int index = sliderData.indexWhere((element) => element['type'] == type);
    
    if (index != -1) {
      // Type exists, update the min and max values
      sliderData[index]['min'] = minValue;
      sliderData[index]['max'] = maxValue;
    } else {
      // Type doesn't exist, add a new entry
      sliderData.add({
        'type': type,
        'min': minValue,
        'max': maxValue,
      });
    }
    
    // Refresh the list to notify observers
    sliderData.refresh();
  }

  // Function to update specific type data
  void updateSliderData(String type, double minValue, double maxValue) {
    int index = sliderData.indexWhere((element) => element['type'] == type);
    if (index != -1) {
      sliderData[index] = {
        'type': type,
        'min': minValue,
        'max': maxValue
      };
      sliderData.refresh();  // Refresh the list to notify listeners
    }
  }
}
