class UserProfileCompletionDetails {
  final String id;
  final int profileCompleted;
  final String role;

  UserProfileCompletionDetails({
    required this.id,
    required this.profileCompleted,
    required this.role,
  });

  // Factory constructor to parse only the `details` map
  factory UserProfileCompletionDetails.fromJson(Map<String, dynamic> json) {
    return UserProfileCompletionDetails(
      id: json['_id'] ?? '',
      profileCompleted: json['profileCompleted'] ?? 0,
      role: json['role'] ?? '',
    );
  }

  // Factory constructor to parse the entire response and extract `details`
  factory UserProfileCompletionDetails.fromApiResponse(Map<String, dynamic> json) {
    // Check if `details` is present and is a Map
    final details = json['details'] as Map<String, dynamic>? ?? {};
    return UserProfileCompletionDetails.fromJson(details);
  }
}
