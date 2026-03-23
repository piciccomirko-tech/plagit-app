class EmployeeProfileAdditionalModel {
  final String id;
  final List<String>? languages;
  // final List<String>? skills;
    final List<Map<String, String>>? skills; // Modified to hold skillId and skillName

  final int? height;
  final String? dressSize;
  final String? emergencyContact;
  final String? higherEducation;
  final String? bio;
  final String? currentOrganisation;

  EmployeeProfileAdditionalModel({
    required this.id,
    this.languages,
    this.skills,
    this.height,
    this.dressSize,
    this.emergencyContact,
    this.higherEducation,
    this.bio,
    this.currentOrganisation,
  });

  // Factory constructor to create an instance from JSON
  factory EmployeeProfileAdditionalModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileAdditionalModel(
      id: json['id'] as String,
      languages: (json['languages'] as List?)?.map((e) => e as String).toList(),
      // skills: (json['skills'] as List?)?.map((e) => e as String).toList(),
            skills: (json['skills'] as List?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList(), // Deserialize skills as List<Map<String, String>>
      height: json['height'] as int?,
      dressSize: json['dressSize'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      higherEducation: json['higherEducation'] as String?,
      bio: json['bio'] as String?,
      currentOrganisation: json['currentOrganisation'] as String?,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languages': languages,
      'skills': skills,
      'height': height,
      'dressSize': dressSize,
      'emergencyContact': emergencyContact,
      'higherEducation': higherEducation,
      'bio': bio,
      'currentOrganisation': currentOrganisation,
    };
  }
}
