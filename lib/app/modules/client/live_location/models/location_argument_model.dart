class LocationArgumentModel {
  double? clientLat;
  double? clientLng;
  double? employeeLat;
  double? employeeLng;
  String? distance;
  String? clientId;
  String? employeePicture;
  String? employeeName;

  LocationArgumentModel(
      {this.clientLat,
      this.clientLng,
      this.employeeLat,
      this.employeeLng,
      this.distance,
      this.clientId,
      this.employeePicture, this.employeeName});
}
