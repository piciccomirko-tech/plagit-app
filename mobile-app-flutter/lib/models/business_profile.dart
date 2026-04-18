/// Typed business profile model — mirrors Swift BusinessProfileDTO.
///
/// Replaces all raw `Map<String, dynamic>` usage for business data
/// throughout the business-side screens.
library;

import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/models/candidate_profile.dart'; // reuse ProfileCompletionItem

// -----------------------------------------
// BusinessProfile
// -----------------------------------------

/// Full business profile, including completion items and subscription plan.
class BusinessProfile {
  final String id;
  final String name;
  final String initials;
  final String contactName;
  final String email;
  final String? phone;
  final String location;
  final String category;
  final String size;
  final String subscription; // 'free' | 'basic' | 'pro' | 'premium'
  final int profileCompletion;
  final String? website;
  final String? description;
  final String? logoUrl;
  final String? coverImage;
  final List<String> galleryImages;
  final String? videoUrl;
  final List<ProfileCompletionItem> completionItems;

  const BusinessProfile({
    required this.id,
    required this.name,
    required this.initials,
    required this.contactName,
    required this.email,
    this.phone,
    required this.location,
    required this.category,
    required this.size,
    this.subscription = 'basic',
    this.profileCompletion = 0,
    this.website,
    this.description,
    this.logoUrl,
    this.coverImage,
    this.galleryImages = const [],
    this.videoUrl,
    this.completionItems = const [],
  });

  // -- Computed properties --

  /// Whether the business is on a premium or pro plan.
  bool get isPremium => subscription != 'basic' && subscription != 'free';

  /// First name extracted from the contact name.
  String get firstName => contactName.split(' ').first;

  // -- JSON serialisation --

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    final rawItems = json['completionItems'] as List<dynamic>?;
    final items = rawItems
            ?.map((e) =>
                ProfileCompletionItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final rawGallery =
        json['galleryImages'] ?? json['gallery_images'] ?? json['gallery'];
    final gallery = rawGallery is List
        ? rawGallery.whereType<String>().toList()
        : const <String>[];

    return BusinessProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      contactName: json['contactName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      location: json['location'] as String? ?? '',
      category: json['category'] as String? ?? '',
      size: json['size'] as String? ?? '',
      subscription: json['subscription'] as String? ?? 'basic',
      profileCompletion: json['profileCompletion'] as int? ?? 0,
      website: json['website'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String? ?? json['logo_url'] as String?,
      coverImage:
          json['coverImage'] as String? ?? json['cover_image'] as String?,
      galleryImages: gallery,
      videoUrl: json['videoUrl'] as String? ?? json['video_url'] as String?,
      completionItems: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
        'contactName': contactName,
        'email': email,
        'phone': phone,
        'location': location,
        'category': category,
        'size': size,
        'subscription': subscription,
        'profileCompletion': profileCompletion,
        'website': website,
        'description': description,
        'logoUrl': logoUrl,
        'coverImage': coverImage,
        'galleryImages': galleryImages,
        'videoUrl': videoUrl,
        'completionItems': completionItems.map((i) => i.toJson()).toList(),
      };

  // -- Mock factory --

  /// Returns a mock profile using the same data currently in [MockData].
  static BusinessProfile mock() {
    final json = <String, dynamic>{
      ...MockData.business,
      'completionItems': MockData.businessProfileItems,
    };
    return BusinessProfile.fromJson(json);
  }
}
