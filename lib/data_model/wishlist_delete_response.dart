// To parse this JSON data, do
//
//     final wishlistDeleteResponse = wishlistDeleteResponseFromJson(jsonString);
//https://app.quicktype.io/

import 'dart:convert';

WishlistDeleteResponse wishlistDeleteResponseFromJson(String str) => WishlistDeleteResponse.fromJson(json.decode(str));

String wishlistDeleteResponseToJson(WishlistDeleteResponse data) => json.encode(data.toJson());

class WishlistDeleteResponse {
  WishlistDeleteResponse({
    this.message
  });

  String? message;

  factory WishlistDeleteResponse.fromJson(Map<String, dynamic> json) => WishlistDeleteResponse(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}