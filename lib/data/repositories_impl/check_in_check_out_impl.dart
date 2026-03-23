
import 'package:mh/data/data_sources/check_in_check_out_data_source.dart';
import 'package:mh/data/mappers/check_in_check_out_mapper.dart';
import 'package:mh/domain/repositories/check_in_check_out_repository.dart';
import '../../domain/model/check_in_check_out_history_model.dart';

class CheckInCheckOutImpl implements CheckInCheckOutRepository {
  final CheckInCheckOutDataSource checkInCheckOutDataSource;

  CheckInCheckOutImpl({
    required this.checkInCheckOutDataSource,
  });

  @override
  Future<CheckInCheckOutHistoryModel?> getCheckInOutUpdateHistory({
    required String currentHiredEmployeeId,
  }) async {
    final response = await checkInCheckOutDataSource.getCheckInOutUpdateHistory(
        currentHiredEmployeeId: currentHiredEmployeeId
    );

    final commonUploadModel = CheckInCheckOutMapper.mapResponseToDomain(response);

    return commonUploadModel;
  }
}
