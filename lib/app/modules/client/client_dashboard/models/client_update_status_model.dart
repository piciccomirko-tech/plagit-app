class ClientUpdateStatusModel {
  String? id;
  bool? checkIn;
  bool? checkOut;
  String? clientComment;
  String? clientCheckInTime;
  String? clientCheckOutTime;
  int? clientBreakTime;

  ClientUpdateStatusModel(
      {this.id,
      this.checkIn,
      this.checkOut,
      this.clientComment,
      this.clientCheckInTime,
      this.clientCheckOutTime,
      this.clientBreakTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['checkIn'] = checkIn;
    data['checkOut'] = checkOut;
    data['clientComment'] = clientComment;
    data['clientCheckInTime'] = clientCheckInTime;
    data['clientCheckOutTime'] = clientCheckOutTime;
    data['clientBreakTime'] = clientBreakTime;
    return data;
  }
}
