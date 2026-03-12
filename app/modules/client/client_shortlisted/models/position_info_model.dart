class PositionInfoModel {
  String? status;
  int? statusCode;
  PositionInfoDetailsModel? details;

  PositionInfoModel({this.status, this.statusCode, this.details});

  PositionInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    details = json['details'] != null ? PositionInfoDetailsModel.fromJson(json['details']) : null;
  }
}

class PositionInfoDetailsModel {
  String? name;
  List<String>? images;

  PositionInfoDetailsModel({this.name, this.images});

  PositionInfoDetailsModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    images = json['images'].cast<String>();
  }
}
