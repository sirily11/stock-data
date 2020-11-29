// To parse this JSON data, do
//
//     final stockData = stockDataFromJson(jsonString);

import 'dart:convert';

StockData stockDataFromJson(String str) => StockData.fromJson(json.decode(str));

String stockDataToJson(StockData data) => json.encode(data.toJson());

class StockData {
  StockData({
    this.price,
    this.stock,
    this.time,
    this.volumn,
  });



  double price;
  String stock;
  DateTime time;
  double volumn;

  StockData copyWith({
    double price,
    String stock,
    DateTime time,
    double volumn,
  }) =>
      StockData(
        price: price ?? this.price,
        stock: stock ?? this.stock,
        time: time ?? this.time,
        volumn: volumn ?? this.volumn,
      );

  factory StockData.fromJson(Map<String, dynamic> json) => StockData(
        price: json["price"] == null ? null : double.tryParse(json["price"]),
        stock: json["stock"] == null ? null : json["stock"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        volumn: json["volumn"] == null ? null : double.tryParse(json["volumn"]),
      );

  Map<String, dynamic> toJson() => {
        "price": price == null ? null : price,
        "stock": stock == null ? null : stock,
        "time": time == null ? null : time.toIso8601String(),
        "volumn": volumn == null ? null : volumn,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockData &&
          runtimeType == other.runtimeType &&
          time == other.time;

  @override
  int get hashCode => time.hashCode;
}
