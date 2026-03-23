class Gender {
  String? id;
  String? name;

  Gender({
    this.id,
    this.name,
  });

  Map toJson() => {
        'id': id,
        'name': name,
      };
}
