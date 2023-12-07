class SocketLocationModel {
  String? sender;
  String? receiver;
  Cords? cords;

  SocketLocationModel({this.sender, this.receiver, this.cords});

  SocketLocationModel.fromJson(Map<String, dynamic> json) {
    sender = json['sender'];
    receiver = json['reciever'];
    cords = json['cords'] != null ? Cords.fromJson(json['cords']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sender'] = sender;
    data['reciever'] = receiver;
    if (cords != null) {
      data['cords'] = cords!.toJson();
    }
    return data;
  }
}

class Cords {
  double? latitude;
  double? longitude;

  Cords({this.latitude, this.longitude});

  Cords.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
