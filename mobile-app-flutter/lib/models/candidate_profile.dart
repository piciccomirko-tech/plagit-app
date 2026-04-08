/// Typed candidate profile model — mirrors Swift CandidateProfileDTO.
///
/// Replaces all raw `Map<String, dynamic>` usage for candidate data
/// throughout the candidate-side screens.
library;

import 'package:plagit/core/mock/mock_data.dart';

// ─────────────────────────────────────────────
// ProfileCompletionItem
// ─────────────────────────────────────────────

/// A single item in the profile-completion checklist.
class ProfileCompletionItem {
  final String label;
  final bool done;

  const ProfileCompletionItem({required this.label, required this.done});

  factory ProfileCompletionItem.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionItem(
      label: json['label'] as String,
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'done': done};
}

// ─────────────────────────────────────────────
// CandidateProfile
// ─────────────────────────────────────────────

/// Full candidate profile, including completion items and subscription plan.
class CandidateProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final String? role;
  final String status; // 'active' | 'suspended'
  final bool isVerified;
  final int profileStrength; // 0–100
  final int? profileViews;
  final double avatarHue;
  final String? photoUrl;
  final String? experience;
  final String? languages;
  final String? verificationStatus; // 'verified' | 'pending' | 'unverified'
  final String? createdAt;
  final String initials;
  final String plan; // 'free' | 'premium'
  final String? nationality;
  final String? availability;
  final String? salary;
  final String? contractPreference;
  final List<ProfileCompletionItem> completionItems;

  const CandidateProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.role,
    this.status = 'active',
    this.isVerified = false,
    this.profileStrength = 0,
    this.profileViews,
    this.avatarHue = 0.0,
    this.photoUrl,
    this.experience,
    this.languages,
    this.verificationStatus,
    this.createdAt,
    required this.initials,
    this.plan = 'free',
    this.nationality,
    this.availability,
    this.salary,
    this.contractPreference,
    this.completionItems = const [],
  });

  // ── JSON serialisation ──

  factory CandidateProfile.fromJson(Map<String, dynamic> json) {
    // languages can arrive as List<String> or comma-separated String.
    final rawLangs = json['languages'];
    String? languagesStr;
    if (rawLangs is List) {
      languagesStr = rawLangs.cast<String>().join(', ');
    } else if (rawLangs is String) {
      languagesStr = rawLangs;
    }

    // completionItems may or may not be present.
    final rawItems = json['completionItems'] as List<dynamic>?;
    final items = rawItems
            ?.map((e) =>
                ProfileCompletionItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CandidateProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String? ?? 'active',
      isVerified: json['isVerified'] as bool? ?? false,
      profileStrength: json['profileCompletion'] as int? ??
          json['profileStrength'] as int? ??
          0,
      profileViews: json['profileViews'] as int?,
      avatarHue: (json['avatarHue'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['photoUrl'] as String?,
      experience: json['experience'] as String?,
      languages: languagesStr,
      verificationStatus: json['verificationStatus'] as String?,
      createdAt: json['createdAt'] as String?,
      initials: json['initials'] as String? ?? '',
      plan: json['plan'] as String? ?? 'free',
      nationality: json['nationality'] as String?,
      availability: json['availability'] as String?,
      salary: json['salary'] as String?,
      contractPreference: json['contractPreference'] as String?,
      completionItems: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'location': location,
        'role': role,
        'status': status,
        'isVerified': isVerified,
        'profileCompletion': profileStrength,
        'profileViews': profileViews,
        'avatarHue': avatarHue,
        'photoUrl': photoUrl,
        'experience': experience,
        'languages': languages,
        'verificationStatus': verificationStatus,
        'createdAt': createdAt,
        'initials': initials,
        'plan': plan,
        'nationality': nationality,
        'availability': availability,
        'salary': salary,
        'contractPreference': contractPreference,
        'completionItems':
            completionItems.map((i) => i.toJson()).toList(),
      };

  // ── Computed properties ──

  /// First name extracted from the full name.
  String get firstName => name.split(' ').first;

  /// Whether the candidate is on a premium plan.
  bool get isPremium => plan == 'premium';

  /// Alias so callers can use either name.
  int get completionPercentage => profileStrength;

  // ── Mock factory ──

  /// Returns a mock profile using the same data currently in [MockData].
  static CandidateProfile mock() {
    final json = <String, dynamic>{
      ...MockData.candidate,
      'completionItems': MockData.profileItems,
    };
    return CandidateProfile.fromJson(json);
  }
}
