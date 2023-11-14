class NationalityModel {
  String? status;
  int? statusCode;
  List<NationalityDetailsModel>? nationalities;

  NationalityModel({this.status, this.statusCode, this.nationalities});

  NationalityModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    if (json['nationalities'] != null) {
      nationalities = <NationalityDetailsModel>[];
      json['nationalities'].forEach((v) {
        nationalities!.add(NationalityDetailsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusCode'] = statusCode;
    if (nationalities != null) {
      data['nationalities'] =
          nationalities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NationalityDetailsModel {
  String? sId;
  String? country;
  String? nationality;

  NationalityDetailsModel({this.sId, this.country, this.nationality});

  NationalityDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    country = json['country'];
    nationality = json['nationality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['country'] = country;
    data['nationality'] = nationality;
    return data;
  }
}
