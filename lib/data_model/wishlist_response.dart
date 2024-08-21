// To parse this JSON data, do
//
//     final wishlistResponse = wishlistResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';
import 'package:active_ecommerce_flutter/data_model/order_item_response.dart';


WishlistResponse wishlistResponseFromJson(String str) =>
    WishlistResponse.fromJson(json.decode(str));

String wishlistResponseToJson(WishlistResponse data) =>
    json.encode(data.toJson());

class WishlistResponse {
  WishlistResponse({
    this.wishlist_items,
    this.success,
    this.status,
  });

  List<WishlistItem>? wishlist_items;
  bool? success;
  int? status;

  WishlistResponse.fromJson(Map<String, dynamic> json) {
    if (json["wishlist"] != null) {
      wishlist_items = [];
      json["wishlist"].forEach((v) {
        wishlist_items!.add(WishlistItem.fromJson(v));
      });
    }
    success = json["success"];
    status = json["status"];
  }

  Map<String, dynamic> toJson() => {
        "wishlist": List<dynamic>.from(wishlist_items!.map((x) => x.toJson())),
        "success": success,
        "status": status,
      };
}

class WishlistItem {
  WishlistItem({
    this.id,
    this.product,
  });

  int? id;
  Product? product;

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json["id"],
        product: Product.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product": product!.toJson(),
      };
}

class Product {
  Product(
      {this.id,
      this.name,
      this.thumbnail_image,
      this.base_price,
      this.rating,
      this.slug,
      this.image,
      this.discount,
      this.stock,
      this.productDetails
      });

  int? id;
  String? name;
  String? thumbnail_image;
  String? base_price;
  String? rating;
  String? slug;
  Image? image;
  ProductDetail? productDetails;
  String? discount;
  String? stock;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        thumbnail_image: json["thumbnail_image"],
        base_price: json["price"],
        rating: json["rating"],
        slug: json["slug"],
        discount: json["price_discounted"],
        stock: json["stock"],
        image: Image.fromJson(json["image"]),
        productDetails: ProductDetail.fromJson(json["product_detail"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "thumbnail_image": thumbnail_image,
        "base_price": base_price,
        "rating": rating,
        "slug": slug,
      };
}
