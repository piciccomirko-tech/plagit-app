class Job {
  final int id;
  final int businessId;
  final String title;
  final String description;
  final String category;
  final String location;
  final double? latitude;
  final double? longitude;
  final String contractType;
  final String? salaryRange;
  final String status;
  final DateTime createdAt;

  const Job({
    required this.id,
    required this.businessId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.latitude,
    this.longitude,
    required this.contractType,
    this.salaryRange,
    required this.status,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
    id: json['id'] as int,
    businessId: json['business_id'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    location: json['location'] as String,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    contractType: json['contract_type'] as String,
    salaryRange: json['salary_range'] as String?,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
