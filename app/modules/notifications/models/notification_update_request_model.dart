class NotificationUpdateRequestModel {
  final String id;
  final String? hiredStatus;
  final String fromWhere;
  final bool? readStatus;

  NotificationUpdateRequestModel({required this.id, this.hiredStatus, this.readStatus, required this.fromWhere});

  Map<String, dynamic> toJson() {
    if (fromWhere == 'notifications') {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = id;
      data['readStatus'] = readStatus;
      return data;
    } else {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = id;
      data['hiredStatus'] = hiredStatus;
      return data;
    }
  }
}
