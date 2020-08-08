// To parse this JSON data, do
//
//     final getSetPrice = getSetPriceFromJson(jsonString);

import 'dart:convert';

GetSetPrice getSetPriceFromJson(String str) =>
    GetSetPrice.fromJson(json.decode(str));

String getSetPriceToJson(GetSetPrice data) => json.encode(data.toJson());

class GetSetPrice {
  GetSetPrice({
    this.userpass,
    this.method = 'setprice',
    this.base,
    this.rel,
    this.price,
    this.max,
    this.cancelPrevious,
    this.volume,
    this.baseNota,
    this.baseConfs,
    this.relNota,
    this.relConfs,
  });

  factory GetSetPrice.fromJson(Map<String, dynamic> json) => GetSetPrice(
        userpass: json['userpass'],
        method: json['method'],
        base: json['base'],
        rel: json['rel'],
        price: json['price'],
        max: json['max'],
        cancelPrevious: json['cancel_previous'],
        volume: json['volume'],
        baseNota: json['base_nota'],
        baseConfs: json['base_confs'],
        relNota: json['rel_nota'],
        relConfs: json['rel_confs'],
      );

  String userpass;
  String method;
  String base;
  String rel;
  String price;
  bool max;
  bool cancelPrevious;
  String volume;
  bool baseNota;
  int baseConfs;
  bool relNota;
  int relConfs;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass,
        'method': method,
        'base': base,
        'rel': rel,
        'price': price,
        'max': max,
        'cancel_previous': cancelPrevious,
        'volume': volume,
        'base_nota': baseNota,
        'base_confs': baseConfs,
        'rel_nota': relNota,
        'rel_confs': relConfs,
      };
}
