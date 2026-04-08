class Application {
  final int id;
  final int jobId;
  final int candidateId;
  final String status;
  final String? coverLetter;
  final DateTime createdAt;

  const Application({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.status,
    this.coverLetter,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
    id: json['id'] as int,
    jobId: json['job_id'] as int,
    candidateId: json['candidate_id'] as int,
    status: json['status'] as String,
    coverLetter: json['cover_letter'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
