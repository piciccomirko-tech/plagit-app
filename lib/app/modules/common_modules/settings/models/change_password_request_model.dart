class ChangePasswordRequestModel {
  final String? id;
  final String? newPassword;
  final String? currentPassword;

  ChangePasswordRequestModel({required this.id, required this.newPassword, required this.currentPassword});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['newPassword'] = newPassword;
    data['currentPassword'] = currentPassword;
    return data;
  }
}
