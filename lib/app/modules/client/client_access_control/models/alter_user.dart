class AlterUser {
  AlterUser({
      this.name, 
      this.email, 
      this.password, 
      this.plainPassword, 
      this.id,});

  AlterUser.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    password = json['plainPassword'];
    plainPassword = json['plainPassword'];
    id = json['_id'];
  }
  String? name;
  String? email;
  String? password;
  String? plainPassword;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['password'] = password;
    map['plainPassword'] = plainPassword;
    map['_id'] = id;
    return map;
  }

}