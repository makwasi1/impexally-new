// To parse this JSON data, do
//
//     final wishListChekResponse = wishListChekResponseFromJson(jsonString);
// https://app.quicktype.io/
import 'dart:convert';

WishListChekResponse wishListChekResponseFromJson(String str) => WishListChekResponse.fromJson(json.decode(str));

String wishListChekResponseToJson(WishListChekResponse data) => json.encode(data.toJson());

class WishListChekResponse {
  WishListChekResponse({
    this.message
  });

  String? message;


  factory WishListChekResponse.fromJson(Map<String, dynamic> json) => WishListChekResponse(
    message: json["message"]
  );

  Map<String, dynamic> toJson() => {
    "message": message
  };
}