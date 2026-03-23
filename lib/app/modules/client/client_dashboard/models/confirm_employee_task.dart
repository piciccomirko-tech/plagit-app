class ConfirmEmployeeTaskModel {
  List<String>? currentHiredEmployeeIds;
  bool? hasReview;

  ConfirmEmployeeTaskModel({
    this.currentHiredEmployeeIds,
    this.hasReview,
  });

  Map<String, dynamic> toJson() => {
        "currentHiredEmployeeIds": currentHiredEmployeeIds,
        "hasReview": hasReview,
      };
}
