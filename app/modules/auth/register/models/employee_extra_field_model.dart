class ExtraFieldModel {
  String? status;
  int? statusCode;
  String? message;
  ExtraFieldDetailsModel? extraFieldDetails;

  ExtraFieldModel({this.status, this.statusCode, this.message, this.extraFieldDetails});

  ExtraFieldModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    extraFieldDetails = json['details'] != null ? ExtraFieldDetailsModel.fromJson(json['details']) : null;
  }
}

class ExtraFieldDetailsModel {
  String? country;
  List<Fields>? fields;
  ExtraFieldDetailsModel({this.country, this.fields});

  ExtraFieldDetailsModel.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    if (json['fields'] != null) {
      fields = <Fields>[];
      json['fields'].forEach((v) {
        fields!.add(Fields.fromJson(v));
      });
    }
  }
}

class Fields {
  String? inputType;
  String? label;
  String? placeholder;
  bool? disabled;
  bool? required;
  String? value;
  Fields({this.inputType, this.label, this.placeholder, this.disabled, this.required, this.value});

  Fields.fromJson(Map<String, dynamic> json) {
    inputType = json['inputType'];
    label = json['label'];
    placeholder = json['placeholder'];
    disabled = json['disabled'];
    required = json['required'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inputType'] = inputType;
    data['label'] = label;
    data['placeholder'] = placeholder;
    data['disabled'] = disabled;
    data['required'] = required;
    data['value'] = value;
    return data;
  }
}
