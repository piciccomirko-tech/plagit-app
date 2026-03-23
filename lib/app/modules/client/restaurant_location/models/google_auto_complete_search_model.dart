class GoogleAutoCompleteSearchModel {
  String? mainText;
  String? secondaryText;

  GoogleAutoCompleteSearchModel({this.mainText, this.secondaryText});

  GoogleAutoCompleteSearchModel.fromJson(Map<String, dynamic> json) {
    mainText = json['main_text'];
    secondaryText = json['secondary_text'];
  }

}
