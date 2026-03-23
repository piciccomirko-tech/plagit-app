class SkillModel {
  final String id;
  final String name;

  SkillModel({required this.id, required this.name});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
