
import '../../domain/model/check_in_check_out_history_model.dart';

class CheckInCheckOutMapper {
  static CheckInCheckOutHistoryModel? mapResponseToDomain(
      CheckInCheckOutHistoryModel? response) {
    if (response == null) {
      return null;
    }

    return response;
  }
}
