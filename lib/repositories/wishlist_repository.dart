import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/wishlist_check_response.dart';
import 'package:active_ecommerce_flutter/data_model/wishlist_delete_response.dart';
import 'package:active_ecommerce_flutter/data_model/wishlist_response.dart';
// import 'package:active_ecommerce_flutter/data_model/wishlist_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../helpers/main_helpers.dart';

class WishListRepository {
  Future<dynamic> getUserWishlist() async {
    const storage = FlutterSecureStorage();
    var user = await storage.read(key: "user_id");

    String url = ("${AppConfig.BASE_URL}/wishlist/${user}");
    Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(url: url, headers: header);

    if (response.statusCode == 200) {
      return wishlistResponseFromJson(response.body);
    }
  }

  Future<dynamic> delete({
    int? wishlist_id = 0,
  }) async {
    String url = ("${AppConfig.BASE_URL}/wishlist/remove");

    const storage = FlutterSecureStorage();
    var user_id = await storage.read(key: "user_id");

    //parse to int
    int? userId = int.tryParse(user_id!);

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "product_id": wishlist_id,
        "user_id": userId,
      }),
    );

    if (response.statusCode == 200) {
      WishlistDeleteResponse wishlistDeleteResponse =
          WishlistDeleteResponse.fromJson({
        "success": true,
        "status": 200,
      });
      return wishlistDeleteResponse;
    }
  }

  Future<dynamic> isProductInUserWishList({product_id = 0}) async {
    String url =
        ("${AppConfig.BASE_URL}/wishlists-check-product?product_id=${product_id}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());

    return wishListChekResponseFromJson(response.body);
  }

  Future<dynamic> add({product_id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/wishlist/add");

    const storage = FlutterSecureStorage();
    var user_id = await storage.read(key: "user_id");

    //parse to int
    int? userId = int.tryParse(user_id!);
    int? productId = int.tryParse(product_id.toString());

    print(url.toString());
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "product_id": productId,
        "user_id": userId,
      }),
    );

    return wishListChekResponseFromJson(response.body);
  }

  Future<dynamic> remove({product_id = 0}) async {
    String url =
        ("${AppConfig.BASE_URL}/wishlists-remove-product?product_id=${product_id}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());

    return wishListChekResponseFromJson(response.body);
  }
}
