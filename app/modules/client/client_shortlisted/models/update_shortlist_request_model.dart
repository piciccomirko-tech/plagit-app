import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class UpdateShortListRequestModel {
  final String shortListId;
  final List<RequestDateModel> requestDateList;
  bool? uniformMandatory;

  UpdateShortListRequestModel(
      {required this.shortListId, required this.requestDateList, required this.uniformMandatory});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = shortListId;
    data['requestDate'] = requestDateList.map((v) => v.toJson()).toList();
    if (uniformMandatory != null) {
      data['uniformMandatory'] = uniformMandatory;
    }
    return data;
  }
}
