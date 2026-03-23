class ClientUpdateStatusModel {
  String? id;
  bool? checkIn;
  bool? checkOut;
  String? clientComment;
  String? clientCheckInTime;
  String? clientCheckOutTime;
  int? clientBreakTime;
  double? travelCost;
  double? tips;

  ClientUpdateStatusModel(
      {this.id,
      this.checkIn,
      this.checkOut,
      this.clientComment,
      this.clientCheckInTime,
      this.clientCheckOutTime,
      this.clientBreakTime,
      this.travelCost,
      this.tips
      });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['checkIn'] = checkIn;
    data['checkOut'] = checkOut;
    data['clientComment'] = clientComment;
    data['clientCheckInTime'] = clientCheckInTime;
    data['clientCheckOutTime'] = clientCheckOutTime;
    data['clientBreakTime'] = clientBreakTime;
    data['travel_cost'] = travelCost;
    data['tips'] = tips;
    return data;
  }
}
