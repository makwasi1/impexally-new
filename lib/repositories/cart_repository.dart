import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/cart_add_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_count_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_delete_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_process_response.dart';
import 'package:active_ecommerce_flutter/data_model/cart_summary_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../data_model/new_cart.dart';

class CartRepository {
  
  Future<CartModel?> getCartResponseList(
  int? user_id
) async {
  const storage = FlutterSecureStorage();
  String? cart_id = await storage.read(key: 'cart_id');

  String url = ("${AppConfig.BASE_URL}/cart/$cart_id/$user_id");
  final response = await ApiRequest.get(
    url: url,
    headers: {"Content-Type": "application/json"}
  );
  //get cart response and use the cart model to parse the response
  CartModel cart = CartModel.fromJson(json.decode(response.body));
  return cart;
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
    int? user_id,
  ) async {
    var post_body = jsonEncode({"cart_item_id": cart_id, "user_id": user_id});
    String url = ("${AppConfig.BASE_URL}/cart/remove");
    final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json"
        },
        body: post_body);

    if(response.statusCode == 200){
      return new CartDeleteResponse(result: true, message: "Item removed from cart");
    } else {
      return new CartDeleteResponse(result: false, message: "Failed to remove item from cart");
    } 
  }

  Future<dynamic> getCartProcessResponse(
      String cart_ids, String cart_quantities) async {
    var post_body = jsonEncode(
        {"cart_item_id": "${cart_ids}", "quantity": "$cart_quantities"});

    String url = ("${AppConfig.BASE_URL}/cart/item/update");
    final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body,
);
    if(response.statusCode == 200){
      return new CartProcessResponse(result: true, message: "Cart updated successfully");
    } else {
      return new CartProcessResponse(result: false, message: "Failed to update cart");
    }
  }

  Future<String?> getCartCreateResponse(int? user_id) async {
    var post_body = jsonEncode({"user_id": user_id});

    const storage = FlutterSecureStorage();

    // "cost_matrix": AppConfig.purchase_code
    String url = ("${AppConfig.BASE_URL}/cart/create");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    var jsonResponse = jsonDecode(response.body);
    print("cart_id: ${jsonResponse['cart']['id']}");
    String cart_id = (jsonResponse['cart']['id']).toString();
    storage.write(key: 'cart_id', value: cart_id);
    return cart_id;
  }

  Future<String?> removeUserCart(int? user_id) async {
    var post_body = jsonEncode({"user_id": user_id});

    const storage = FlutterSecureStorage();

    // "cost_matrix": AppConfig.purchase_code
    String url = ("${AppConfig.BASE_URL}/cart/delete");
    final response = await ApiRequest.delete(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    if(response.statusCode == 200){
      storage.delete(key: "cart_id");
      return "Deleted";
    } else {
      return "Failed to delete cart";
    }
  }

  Future<dynamic> getCartAddResponse(int? id, int? user_id,
      int? quantity, List<Map<String, dynamic>> itemSelectedVariations ) async {
    var post_body;
    const storage = FlutterSecureStorage();

    //read the cart_id from the storage
    String? cart_id = await storage.read(key: 'cart_id');

    if (cart_id == null) {
      cart_id = await getCartCreateResponse(user_id);
    }

    //update the body to include the cart_id
    post_body = jsonEncode({
      "product_id": id,
      "variations": itemSelectedVariations,
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
        body: post_body);

        if(response.statusCode == 200){
          return cartAddResponseFromJson(response.body);
        } else if(response.statusCode == 404){ 
          await getCartCreateResponse(user_id); 
        } else {
          return new CartAddResponse(result: false, message: "Failed to add item to cart");
        }

    
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
