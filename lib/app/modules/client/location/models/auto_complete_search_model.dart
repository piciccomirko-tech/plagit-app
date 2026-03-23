class AutoCompleteSearchModel {
  final String mainText;
  final String secondaryText;
  final String lat;
  final String long;
  final String employeeId;

  AutoCompleteSearchModel({
    required this.mainText,
    required this.secondaryText,
    required this.lat,
    required this.long,
    required this.employeeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoCompleteSearchModel &&
          runtimeType == other.runtimeType &&
          employeeId == other.employeeId;

  @override
  int get hashCode => employeeId.hashCode;

  factory AutoCompleteSearchModel.fromJson(Map<String, dynamic> json) {
    return AutoCompleteSearchModel(
      mainText: json['main_text'] ?? '',
      secondaryText: json['secondary_text'] ?? '',
      lat: json['lat'] ?? '',
      long: json['long'] ?? '',
      employeeId: json['employee_id'] ?? '',
    );
  }
}
