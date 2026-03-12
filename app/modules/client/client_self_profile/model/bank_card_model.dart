import 'dart:convert';

class BankCardModel {
  final Provided? provided;
  final String? type;

  BankCardModel({
    this.provided,
    this.type,
  });

  factory BankCardModel.fromRawJson(String str) => BankCardModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BankCardModel.fromJson(Map<String, dynamic> json) => BankCardModel(
    provided: json["provided"] == null ? null : Provided.fromJson(json["provided"]),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "provided": provided?.toJson(),
    "type": type,
  };
}

class Provided {
  final Card? card;

  Provided({
    this.card,
  });

  factory Provided.fromRawJson(String str) => Provided.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Provided.fromJson(Map<String, dynamic> json) => Provided(
    card: json["card"] == null ? null : Card.fromJson(json["card"]),
  );

  Map<String, dynamic> toJson() => {
    "card": card?.toJson(),
  };
}

class Card {
  final String? brand;
  final Expiry? expiry;
  final String? fundingMethod;
  final String? nameOnCard;
  final String? number;
  final String? scheme;
  final String? storedOnFile;

  Card({
    this.brand,
    this.expiry,
    this.fundingMethod,
    this.nameOnCard,
    this.number,
    this.scheme,
    this.storedOnFile,
  });

  factory Card.fromRawJson(String str) => Card.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Card.fromJson(Map<String, dynamic> json) => Card(
    brand: json["brand"],
    expiry: json["expiry"] == null ? null : Expiry.fromJson(json["expiry"]),
    fundingMethod: json["fundingMethod"],
    nameOnCard: json["nameOnCard"],
    number: json["number"],
    scheme: json["scheme"],
    storedOnFile: json["storedOnFile"],
  );

  Map<String, dynamic> toJson() => {
    "brand": brand,
    "expiry": expiry?.toJson(),
    "fundingMethod": fundingMethod,
    "nameOnCard": nameOnCard,
    "number": number,
    "scheme": scheme,
    "storedOnFile": storedOnFile,
  };
}

class Expiry {
  final String? month;
  final String? year;

  Expiry({
    this.month,
    this.year,
  });

  factory Expiry.fromRawJson(String str) => Expiry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Expiry.fromJson(Map<String, dynamic> json) => Expiry(
    month: json["month"],
    year: json["year"],
  );

  Map<String, dynamic> toJson() => {
    "month": month,
    "year": year,
  };
}
