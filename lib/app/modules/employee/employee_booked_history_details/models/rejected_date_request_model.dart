import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class RejectedDateRequestModel {
  final String shortListId;
  final List<RequestDateModel> requestDateList;
  final List<RequestDateModel> rejectedDateList;

  RejectedDateRequestModel(
      {required this.shortListId, required this.requestDateList, required this.rejectedDateList});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = shortListId;
    data['requestDate'] = requestDateList.map((RequestDateModel v) => v.toJson()).toList();
    data['rejectedDate'] = rejectedDateList.map((RequestDateModel v) => v.toJson()).toList();
    return data;
  }
}
