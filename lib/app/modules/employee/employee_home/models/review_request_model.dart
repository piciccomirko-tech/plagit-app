class ReviewRequestModel {
  final double rating;
  final String reviewForId;
  final String comment;
  final String hiredId;

  ReviewRequestModel({required this.rating, required this.reviewForId, required this.comment, required this.hiredId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['reviewForId'] = reviewForId;
    data['comment'] = comment;
    data['hiredId'] = hiredId;
    return data;
  }
}
