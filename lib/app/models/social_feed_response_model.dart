import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';

class SocialFeedResponseModel {
  final String? status;
  final SocialFeeds? socialFeeds;
  final List<SocialPostModel>? feeds;

  SocialFeedResponseModel({
    this.status,
    this.socialFeeds,
    this.feeds,
  });

  factory SocialFeedResponseModel.fromRawJson(String str) =>
      SocialFeedResponseModel.fromJson(json.decode(str));

  factory SocialFeedResponseModel.fromJson(Map<String, dynamic> json) {
    var model = SocialFeedResponseModel(
      status: json["status"],
      socialFeeds: json["socialFeeds"] == null
          ? null
          : SocialFeeds.fromJson(json["socialFeeds"]),
      feeds: json["feeds"] == null
          ? []
          : List<SocialPostModel>.from(
              json["feeds"]!.map((x) => SocialPostModel.fromJson(x))),
    );

    // Process videos for all feeds
    // if (model.feeds != null) {
    //   for (var feed in model.feeds!) {
    //     if (feed.media != null) {
    //       Media.processBatch(feed.media??[]);
    //       // for (var media in feed.media!) {
    //       //   media.processVideo().then((_) => print('Feed video processed for ${media.url}'));
    //       // }
    //     }
    //   }
    // }
    //
    // // Process videos for socialFeeds posts
    // if (model.socialFeeds?.posts != null) {
    //   for (var post in model.socialFeeds!.posts!) {
    //     if (post.media != null) {
    //       Media.processBatch(post.media??[]);
    //       // for (var media in post.media!) {
    //       //   media.processVideo().then((_) => print('SocialFeeds video processed for ${media.url}'));
    //       // }
    //     }
    //   }
    // }

    return model;
  }
}

class SocialFeeds {
  int? total;
  final List<SocialPostModel>? posts;

  SocialFeeds({
    this.total,
    this.posts,
  });

  factory SocialFeeds.fromRawJson(String str) =>
      SocialFeeds.fromJson(json.decode(str));

  factory SocialFeeds.fromJson(Map<String, dynamic> json) => SocialFeeds(
        total: json['total'],
        posts: json["posts"] == null
            ? []
            : List<SocialPostModel>.from(
                json["posts"]!.map((x) => SocialPostModel.fromJson(x))),
      );
}

class SocialPostModel {
  final String? id;
  final String? content;
  final List<Media>? media;
  final bool? active;
  final int? views;
  final SocialUser? user;
  final List<Comment>? comments;
  final List<SocialUser>? recommendation;
  List<SocialUser>? likes;
  final List<Report>? reports;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final bool? liked;
  final Repost? repost;

  SocialPostModel(
      {this.id,
      this.content,
      this.media,
      this.active,
      this.views,
      this.user,
      this.comments,
      this.recommendation,
      this.likes,
      this.reports,
      this.createdAt,
      this.repost,
      this.updatedAt,
      this.v,
      this.liked = false});

  factory SocialPostModel.fromRawJson(String str) =>
      SocialPostModel.fromJson(json.decode(str));

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    var model = SocialPostModel(
      id: json["_id"],
      repost: json["repost"] == null || json["repost"] is String
          ? null
          : (json["repost"] is Map<String, dynamic> &&
                  json["repost"]["user"] is Map<String, dynamic> &&
                  json["repost"]["user"].isEmpty)
              ? null
              : Repost.fromJson(json["repost"]),
      content: json["content"],
      media: json["media"] == null
          ? []
          : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      active: json["active"],
      views: json["views"] ?? 0,
      user: json["user"] == null ? null : SocialUser.fromJson(json["user"]),
      comments: json["comments"] == null
          ? []
          : List<Comment>.from(
              json["comments"]!.map((x) => Comment.fromJson(x))),
      recommendation: json["recommendation"] == null
          ? []
          : List<SocialUser>.from(
              json["recommendation"]!.map((x) => SocialUser.fromJson(x))),
      likes: json["likes"] == null
          ? []
          : List<SocialUser>.from(
              json["likes"]!.map((x) => SocialUser.fromJson(x))),
      createdAt:
          json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      updatedAt:
          json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      v: json["__v"],
    );

    // Process videos for all media immediately
    // if (model.media != null) {
    //   for (var media in model.media!) {
    //     media.processVideo().then((_) => print('Video processed for ${media.url}'));
    //   }
    // }
    //
    // // Process videos in repost if exists
    // if (model.repost?.media != null) {
    //   for (var media in model.repost!.media!) {
    //     media.processVideo().then((_) => print('Repost video processed for ${media.url}'));
    //   }
    // }

    return model;
  }
}

class Repost {
  final String? id;
  final String? content;
  final List<Media>? media;
  final bool? active;
  final SocialUser? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Repost(
      {this.id,
      this.content,
      this.media,
      this.active,
      this.user,
      this.createdAt,
      this.updatedAt,
      this.v});

  factory Repost.fromRawJson(String str) => Repost.fromJson(json.decode(str));

  factory Repost.fromJson(Map<String, dynamic> json) {
    var repost = Repost(
      id: json["_id"],
      content: json["content"],
      media: json["media"] == null
          ? []
          : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      active: json["active"],
      user: json["user"] == null ? null : SocialUser.fromJson(json["user"]),
      createdAt:
          json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      updatedAt:
          json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
      v: json["__v"],
    );

    // Process videos for all media
    // for (var media in repost.media ?? []) {
    //   media.processVideo();
    // }

    return repost;
  }
}

class Comment {
  final String? id;
  String? text;
  final List<Comment>? children;
  final SocialUser? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Comment({
    this.id,
    this.text,
    this.children,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Comment.fromRawJson(String str) => Comment.fromJson(json.decode(str));

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["_id"],
        text: json["text"],
        children: json["children"] == null
            ? []
            : List<Comment>.from(
                json["children"]!.map((x) => Comment.fromJson(x))),
        user: json["user"] == null ? null : SocialUser.fromJson(json["user"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );
}

// "recommendation": [
//                     {
//                         "_id": "6746d6d02e1f90079159df16",
//                         "name": "Aisha Ahmed",
//                         "positionId": "66601214ada066c5fbcc45ae",
//                         "email": "aisha.ahmed@yahoo.com",
//                         "countryName": "United Arab Emirates",
//                         "certified": false,
//                         "role": "EMPLOYEE",
//                         "rating": 0,
//                         "hourlyRate": 180,
//                         "employeeExperience": "5",
//                         "nationality": "Emirati",
//                         "positionName": "Hostess",
//                         "profilePicture": "2difP0bhg-Screenshot-2024-11-27-122638.png"
//                     },
//                 ]
class SocialUser {
  final String? id;
  final String? name;
  final String? positionId;
  final String? positionName;
  final String? email;
  final String? role;
  final String? profilePicture;
  final String? countryName;
  final String? employeeExperience;
  final double? hourlyRate;

  SocialUser(
      {this.id,
      this.name,
      this.positionId,
      this.positionName,
      this.email,
      this.role,
      this.profilePicture,
      this.countryName,
      this.employeeExperience,
      this.hourlyRate});

  factory SocialUser.fromRawJson(String str) =>
      SocialUser.fromJson(json.decode(str));

  factory SocialUser.fromJson(Map<String, dynamic> json) => SocialUser(
        id: json["_id"],
        name: json["name"] ?? json["restaurantName"],
        positionId: json["positionId"],
        positionName: json["positionName"],
        email: json["email"],
        role: json["role"],
        countryName: json["countryName"] ?? '',
        employeeExperience: json["employeeExperience"] ?? "0",
        hourlyRate: json["hourlyRate"] == null
            ? 0.0
            : double.parse(json["hourlyRate"].toString()),
        profilePicture: json["profilePicture"].toString() == "undefined"
            ? ""
            : json["profilePicture"],
      );
}

class Report {
  final SocialUser? user;
  final String? reason;
  final DateTime? createdAt;
  final String? id;

  Report({
    this.user,
    this.reason,
    this.createdAt,
    this.id,
  });

  factory Report.fromRawJson(String str) => Report.fromJson(json.decode(str));

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        user: json["user"] == null ? null : SocialUser.fromJson(json["user"]),
        reason: json["reason"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        id: json["_id"],
      );
}

class _CompressionQueueItem {
  final String url;
  final Completer<String?> completer;

  _CompressionQueueItem(this.url, this.completer);
}

class Media {
  final String? url;
  final String? type;
  String? localPath;
  bool _isProcessing = false;
  final String? thumbnail;

  // Cache configuration
  static const int MAX_CACHE_SIZE_MB = 500; // 500MB max cache size
  static const int MAX_FILE_AGE_DAYS =
      7; // Files older than 7 days will be removed
  static const int MIN_CACHE_SIZE_MB =
      100; // Keep at least 100MB of recent cache

  Media({
    this.url,
    this.type,
    this.localPath,
  }) : thumbnail = url?.replaceAll('.mp4', '_thumb.png');

  // Method to extract dimensions from URL
  Map<String, double> getDimensionsFromUrl() {
    try {
      if (url == null) return {'width': 16, 'height': 9};

      // Look for the pattern [WxH] in the URL
      final RegExp dimensionPattern = RegExp(r'\[(\d+)x(\d+)\]');
      final match = dimensionPattern.firstMatch(url!);

      if (match != null) {
        final width = double.parse(match.group(1)!);
        final height = double.parse(match.group(2)!);
        return {'width': width, 'height': height};
      }
    } catch (e) {
      print('Error parsing dimensions from URL: $e');
    }
    return {'width': 16, 'height': 9}; // Default dimensions
  }

  // Getter for aspect ratio using URL dimensions
  double get aspectRatio {
    final dimensions = getDimensionsFromUrl();
    return dimensions['width']! / dimensions['height']!;
  }

  // Getters for dimensions from URL
  double get width => getDimensionsFromUrl()['width']!;
  double get height => getDimensionsFromUrl()['height']!;

  // Screen-based scaled dimensions
  double get screenWidth => Get.width;
  double get screenHeight => Get.height - 120; // Account for AppBar and indicator

  // Get scaled dimensions based on screen
  Map<String, double> get scaledDimensions {
    // Get original dimensions
    final originalWidth = width;
    final originalHeight = height;

    // Calculate scale factors
    double scaleFactorWidth = screenWidth / originalWidth;
    double scaleFactorHeight = screenHeight / originalHeight;

    // Use smaller scale factor to fit screen
    double scaleFactor = scaleFactorWidth < scaleFactorHeight
        ? scaleFactorWidth
        : scaleFactorHeight;

    // Return scaled dimensions
    return {
      'width': originalWidth * scaleFactor,
      'height': originalHeight * scaleFactor,
    };
  }

  // Convenience getters for scaled dimensions
  double get scaledWidth => scaledDimensions['width']!;
  double get scaledHeight => scaledDimensions['height']!;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        url: json["url"],
        type: json["type"],
      );

  // static Future<void> processBatch(List<Media> mediaList) async {
  //   final videoMedias = mediaList.where((m) => m.type == "video" && m.url != null).toList();
  //   if (videoMedias.isEmpty) return;
  //
  //   print('Starting batch processing of ${videoMedias.length} videos');
  //
  //   await Future.wait(
  //     videoMedias.map((media) => media.processVideo()),
  //     eagerError: true,
  //   );
  //
  //   print('Batch processing completed');
  // }

  // Main cache cleanup method
  // static Future<void> cleanCache() async {
  //   try {
  //     final cacheDir = await getApplicationCacheDirectory();
  //     if (!cacheDir.existsSync()) return;
  //
  //     final files = cacheDir.listSync()
  //         .whereType<File>()
  //         .toList();
  //
  //     // Skip if no files
  //     if (files.isEmpty) return;
  //
  //     await _performTimeBasedCleanup(files);
  //     await _performSizeBasedCleanup(files);
  //
  //   } catch (e) {
  //     print('Error during cache cleanup: $e');
  //   }
  // }
  //
  // // Clean files based on age
  // static Future<void> _performTimeBasedCleanup(List<File> files) async {
  //   try {
  //     final now = DateTime.now();
  //
  //     for (var file in files) {
  //       try {
  //         final fileAge = now.difference(file.lastModifiedSync());
  //         if (fileAge.inDays > MAX_FILE_AGE_DAYS) {
  //           print('Deleting old file: ${file.path}');
  //           await file.delete();
  //         }
  //       } catch (e) {
  //         print('Error deleting old file ${file.path}: $e');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error during time-based cleanup: $e');
  //   }
  // }
  //
  // // Clean files based on total cache size
  // static Future<void> _performSizeBasedCleanup(List<File> files) async {
  //   try {
  //     // Calculate total size and sort files by last accessed time
  //     int totalSize = 0;
  //     var sizedFiles = <MapEntry<File, int>>[];
  //
  //     for (var file in files) {
  //       try {
  //         final size = await file.length();
  //         totalSize += size;
  //         sizedFiles.add(MapEntry(file, size));
  //       } catch (e) {
  //         print('Error getting file size for ${file.path}: $e');
  //       }
  //     }
  //
  //     // Sort by last accessed time (oldest first)
  //     sizedFiles.sort((a, b) {
  //       return a.key.lastAccessedSync().compareTo(b.key.lastAccessedSync());
  //     });
  //
  //     // If total size exceeds MAX_CACHE_SIZE_MB, start deleting oldest files
  //     if (totalSize > MAX_CACHE_SIZE_MB * 1024 * 1024) {
  //       print('Cache size ($totalSize bytes) exceeds limit, cleaning up...');
  //
  //       for (var entry in sizedFiles) {
  //         // Stop if we're under the minimum cache size
  //         if (totalSize <= MIN_CACHE_SIZE_MB * 1024 * 1024) break;
  //
  //         try {
  //           await entry.key.delete();
  //           totalSize -= entry.value;
  //           print('Deleted file: ${entry.key.path}, freed ${entry.value} bytes');
  //         } catch (e) {
  //           print('Error deleting file ${entry.key.path}: $e');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Error during size-based cleanup: $e');
  //   }
  // }
  //
  // // Get current cache size in MB
  // static Future<double> getCacheSizeMB() async {
  //   try {
  //     final cacheDir = await getApplicationCacheDirectory();
  //     if (!cacheDir.existsSync()) return 0.0;
  //
  //     int totalSize = 0;
  //     for (var file in cacheDir.listSync()) {
  //       if (file is File) {
  //         totalSize += await file.length();
  //       }
  //     }
  //     return totalSize / (1024 * 1024); // Convert to MB
  //   } catch (e) {
  //     print('Error calculating cache size: $e');
  //     return 0.0;
  //   }
  // }
  //
  // Future<void> processVideo() async {
  //   if (_isProcessing || url == null || type != "video") return;
  //   _isProcessing = true;
  //
  //   try {
  //     // Clean cache before processing new video
  //     await Media.cleanCache();
  //
  //     final cacheDir = await getApplicationCacheDirectory();
  //     final fileName = url!.split('/').last;
  //     final filePath = '${cacheDir.path}/$fileName';
  //
  //     // Check if file already exists
  //     final file = File(filePath);
  //     if (await file.exists()) {
  //       print('Found existing file at: $filePath');
  //       localPath = filePath;
  //       // Update last accessed time to mark as recently used
  //       await file.setLastModified(DateTime.now());
  //       return;
  //     }
  //
  //     // Construct the complete URL
  //     final fullUrl = "$url".socialMediaUrl;
  //     print('Processing video with full URL: $fullUrl');
  //
  //     // Download the file
  //     final response = await http.get(Uri.parse(fullUrl));
  //     if (response.statusCode == 200) {
  //       await file.writeAsBytes(response.bodyBytes);
  //       localPath = filePath;
  //       print('Video downloaded and saved to: $filePath');
  //     }
  //
  //   } catch (e) {
  //     print('Error processing video: $e');
  //     localPath = null;
  //   } finally {
  //     _isProcessing = false;
  //   }
  // }
  //
  // File? getVideoFile() {
  //   if (localPath != null && localPath!.isNotEmpty) {
  //     final file = File(localPath!);
  //     if (file.existsSync()) {
  //       // Update last accessed time when file is accessed
  //       try {
  //         file.setLastModified(DateTime.now());
  //       } catch (e) {
  //         print('Error updating file access time: $e');
  //       }
  //       print('Media.getVideoFile: ${file.path} exists');
  //       return file;
  //     }
  //     print('Media.getVideoFile: File does not exist at ${localPath}');
  //     localPath = null;
  //   } else {
  //     print('Media.getVideoFile: localPath is null or empty for url: $url');
  //   }
  //   return null;
  // }
}
