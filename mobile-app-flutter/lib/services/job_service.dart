import 'package:plagit/core/api_client.dart';
import 'package:plagit/models/job.dart';

class JobService {
  final _api = ApiClient();

  Future<List<Job>> getJobs({int page = 1, String? category, String? location}) async {
    final params = <String, String>{
      'page': page.toString(),
      if (category != null) 'category': category,
      if (location != null) 'location': location,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final data = await _api.get('/candidate/jobs?$query');
    final jobs = data['jobs'] as List;
    return jobs.map((j) => Job.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Job> getJobDetail(int jobId) async {
    final data = await _api.get('/candidate/jobs/$jobId');
    return Job.fromJson(data['job'] as Map<String, dynamic>);
  }
}
