class ShortListRequestModel {
  final String id;
  final String employeeId;

  ShortListRequestModel({required this.id, required this.employeeId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employeeId'] = employeeId;
    return data;
  }
}
