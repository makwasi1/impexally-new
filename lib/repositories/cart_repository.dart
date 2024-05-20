import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/cart_add_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_count_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_delete_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_process_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_summary_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepository {
  Future<dynamic> getCartResponseList(
    int? user_id,
  ) async {
    String url = ("${AppConfig.BASE_URL}/carts");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,

        },
        body: '',
        middleware: BannedUser());

    return cartResponseFromJson(response.body);
  }

  Future<dynamic> getCartCount() async {
    if (is_logged_in.$) {
      String url = ("${AppConfig.BASE_URL}/cart-count");
      final response = await ApiRequest.get(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
      );
      return cartCountResponseFromJson(response.body);
    } else {
      return CartCountResponse(count: 0, status: false);
    }
  }

  Future<dynamic> getCartDeleteResponse(
    int? cart_id,
  ) async {
    String url = ("${AppConfig.BASE_URL}/carts/$cart_id");
    final response = await ApiRequest.delete(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());
    return cartDeleteResponseFromJson(response.body);
  }

  Future<dynamic> getCartProcessResponse(
      String cart_ids, String cart_quantities) async {
    var post_body = jsonEncode(
        {"cart_ids": "${cart_ids}", "cart_quantities": "$cart_quantities"});

    String url = ("${AppConfig.BASE_URL}/carts/process");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return cartProcessResponseFromJson(response.body);
  }


  Future<int> getCartCreateResponse(
    int? user_id) async {
    var post_body = jsonEncode({
      "user_id": user_id
    });
    
    const storage = FlutterSecureStorage();
    
    // "cost_matrix": AppConfig.purchase_code
    String url = ("${AppConfig.BASE_URL}/cart/create");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body
    );

    var jsonResponse = jsonDecode(response.body);
    print("cart_id: ${jsonResponse['cart']['id']}");
    storage.write(key: 'cart_id', value:jsonResponse['cart']['id']);
    return jsonResponse['cart']['id'];
  }

  Future<dynamic> getCartAddResponse(
      int? id, String? variant, int? user_id, int? quantity, int? variation_option_id) async {
    var post_body;
    const storage = FlutterSecureStorage();
 
    //read the cart_id from the storage
    dynamic cart_id = await storage.read(key: 'cart_id');  

    print("cart_id: $cart_id");

    if(cart_id == null){
      cart_id = await getCartCreateResponse(user_id);
    }

    //update the body to include the cart_id
    post_body = jsonEncode({
      "product_id": id,
      "variation_id": int.tryParse(variant!),
      "user_id": user_id,
      "quantity": quantity,
      "cart_id": cart_id
    });

    String url = ("${AppConfig.BASE_URL}/cart/add");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body
        );

    return cartAddResponseFromJson(response.body);
  }

  Future<dynamic> getCartSummaryResponse() async {
    String url = ("${AppConfig.BASE_URL}/cart-summary");
    print(" cart summary");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
          

        },
        middleware: BannedUser());

    return cartSummaryResponseFromJson(response.body);
  }
}
