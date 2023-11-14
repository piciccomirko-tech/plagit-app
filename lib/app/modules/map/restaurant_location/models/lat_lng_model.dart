class LatLngModel {
  double? lat;
  double? lng;

  LatLngModel({this.lat, this.lng});

  LatLngModel.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

}