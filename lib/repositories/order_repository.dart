import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/common_response.dart';
import 'package:active_ecommerce_flutter/data_model/order_detail_response.dart';
import 'package:active_ecommerce_flutter/data_model/order_item_response.dart';
import 'package:active_ecommerce_flutter/data_model/order_mini_response.dart';
import 'package:active_ecommerce_flutter/data_model/purchased_ditital_product_response.dart';
import 'package:active_ecommerce_flutter/helpers/main_helpers.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data_model/reorder_response.dart';

class OrderRepository {
  Future<dynamic> getOrderList(String? user_id) async {
    String url = ("${AppConfig.BASE_URL}/orders/user/" + "$user_id");

    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      OrderMiniResponse orderMiniResponse = OrderMiniResponse.fromJson({
        "data": jsonResponse, // Directly use the decoded JSON if it's already an array.
        "success": true,
        "status": 200, // Add appropriate value for meta
      });

      return orderMiniResponse;
    }
  }

  //create order
  Future<dynamic> createOrder(
      String? price_subtotal, String? price_shipping) async {
    String url = ("${AppConfig.BASE_URL}/order");
    const storage = FlutterSecureStorage();
    String? cart_id = await storage.read(key: 'cart_id');
    String? order_number = await storage.read(key: 'order_id');
    var bodyObj = {
      "cart_id": cart_id,
      "price_subtotal": price_subtotal,
      "price_shipping": price_shipping,
      "order_number": order_number
    };
    var body = jsonEncode(bodyObj);
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body);

    if (response.statusCode == 200) {
      return commonResponseFromJson(response.body);
    }
  }

  Future<dynamic> getOrderDetails({int? id = 0}) async {
    String url =
        ("${AppConfig.BASE_URL}/purchase-history-details/" + id.toString());

    Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());
    return orderDetailResponseFromJson(response.body);
  }

  Future<ReOrderResponse> reOrder({int? id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/re-order/$id");

    print(url);
    print("Bearer ${access_token.$}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return reOrderResponseFromJson(response.body);
  }

  Future<CommonResponse> cancelOrder({int? id = 0}) async {
    String url = "${AppConfig.BASE_URL}/order/cancel/$id";

    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return commonResponseFromJson(response.body);
  }

  Future<dynamic> getOrderItems({int? id = 0}) async {
    String url =
        ("${AppConfig.BASE_URL}/purchase-history-items/" + id.toString());
    Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    return orderItemlResponseFromJson(response.body);
  }

  Future<dynamic> getPurchasedDigitalProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/digital/purchased-list?page=$page");
    Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    return purchasedDigitalProductResponseFromJson(response.body);
  }
}
