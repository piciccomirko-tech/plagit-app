class MediaFileInfo {
  final String url;
  final double width;
  final double height;

  MediaFileInfo({
    required this.url,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'width': width,
        'height': height,
      };

  factory MediaFileInfo.fromJson(Map<String, dynamic> json) => MediaFileInfo(
        url: json['url'],
        width: json['width'],
        height: json['height'],
      );
}

class PostUpload {
  final List<MediaFileInfo> mediaFiles;
  final String caption;

  PostUpload({
    required this.mediaFiles,
    required this.caption,
  });

  factory PostUpload.fromJson(Map<String, dynamic> json) {
    return PostUpload(
      mediaFiles: json["mediaFiles"] == null
          ? []
          : List<MediaFileInfo>.from(
              json["mediaFiles"]!.map((x) => MediaFileInfo.fromJson(x))),
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaFiles': mediaFiles.map((x) => x.toJson()).toList(),
      'caption': caption,
    };
  }
}

// class PostUpload {
//   final List<String> mediaFiles;
//   final String caption;
//
//   PostUpload({required this.mediaFiles, required this.caption});
//
//   factory PostUpload.fromJson(Map<String, dynamic> json) {
//     return PostUpload(
//       mediaFiles: List<String>.from(json['mediaFiles']),
//       caption: json['caption'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'mediaFiles': mediaFiles,
//       'caption': caption,
//     };
//   }
// }
