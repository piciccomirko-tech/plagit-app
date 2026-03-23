
import '../../domain/model/check_in_check_out_history_model.dart';

abstract class CheckInCheckOutDataSource {
  Future<CheckInCheckOutHistoryModel> getCheckInOutUpdateHistory(
      {required String currentHiredEmployeeId});
}
