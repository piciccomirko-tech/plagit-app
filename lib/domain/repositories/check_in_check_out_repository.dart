import '../model/check_in_check_out_history_model.dart';

abstract class CheckInCheckOutRepository {
  Future<CheckInCheckOutHistoryModel?> getCheckInOutUpdateHistory({
    required String currentHiredEmployeeId,
  });
}
