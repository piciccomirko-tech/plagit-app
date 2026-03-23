class UserSuggestionModel {
  final String? id;
  final String? restaurantName;
  final String? name;
  final String? role;
  final String? profilePicture;
  final String? positionName;
  final String? countryName;
  final double? score;

  UserSuggestionModel({
    this.id,
     this.restaurantName,
     this.name,
    this.profilePicture,
    this.positionName,
    this.countryName,
    this.score,
    this.role,
  });

  factory UserSuggestionModel.fromJson(Map<String, dynamic> json) {
    return UserSuggestionModel(
      id: json['_id'] as String?,
      restaurantName: json['restaurantName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'EMPLOYEE',
      profilePicture: json['profilePicture'] as String?,
      positionName: json['positionName'] as String?,
      countryName: json['countryName'] as String?,
      score: (json['score'] as num?)?.toDouble(), // Safely handle null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantName': restaurantName,
      'name': name,
      'role': role,
      'profilePicture': profilePicture,
      'positionName': positionName,
      'countryName': countryName,
      'score': score,
    };
  }

}
