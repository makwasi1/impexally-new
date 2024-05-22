import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:active_ecommerce_flutter/data_model/address_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_add_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_delete_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_make_default_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_update_in_cart_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_update_location_response.dart';
import 'package:active_ecommerce_flutter/data_model/address_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/data_model/city_response.dart';
import 'package:active_ecommerce_flutter/data_model/country_response.dart';
import 'package:active_ecommerce_flutter/data_model/shipping_cost_response.dart';
import 'package:active_ecommerce_flutter/data_model/state_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AddressRepository {
  Future<dynamic> getAddressList() async {
    String url = ("${AppConfig.BASE_URL}/shipping-address/18");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse =
          jsonDecode(response.body); // Decode the JSON string to a Map.

      // Create a new JSON structure that matches what your AddressResponse expects.
      var data = jsonEncode({
        "data":
            [jsonResponse], // Directly use the decoded JSON if it's already an array.
        "success": true,
        "status": 200
      });
      return addressResponseFromJson(data);
    } else {
      return new AddressResponse(
          addresses: []); //return an empty list if there is an error
    }
  }

  Future<dynamic> getHomeDeliveryAddress() async {
    String url = ("${AppConfig.BASE_URL}/get-home-delivery-address");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return addressResponseFromJson(response.body);
  }

  Future<dynamic> getAddressAddResponse(
      {required String address,
      required int? country_id,
      required int? state_id,
      required String? city_id,
      required String postal_code,
      required String email,
      required String phone}) async {
    var post_body = jsonEncode({
      "title": "$address",
      "first_name": "$address",
      "last_name": "$address",
      "user_id": 18,
      "address": "$address",
      "country_id": "$country_id",
      "state_id": "$state_id",
      "city": "$city_id",
      "postal_code": "$postal_code",
      "phone_number": "$phone",
      "email": "$email",
      "is_billing_address": false,
      "zip_code": "1234",
    });

    String url = ("${AppConfig.BASE_URL}/shipping-address");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json"
        // "Authorization": "Bearer ${access_token.$}",
        // "App-Language": app_language.$!
      },
      body: post_body,
    );
    //create new response with a new model class and return it
    if (response.statusCode == 201) {
      return new AddressAddResponse(
          result: true, message: "Address added successfully");
    } else {
      return new AddressAddResponse(
          result: false, message: "Failed to add address");
    }
  }

  Future<dynamic> getAddressUpdateResponse(
      {required int? id,
      required String address,
      required int? country_id,
      required int? state_id,
      required int? city_id,
      required String postal_code,
      required String phone}) async {
    var post_body = jsonEncode({
      "id": "${id}",
      "user_id": "${user_id.$}",
      "address": "$address",
      "country_id": "$country_id",
      "state_id": "$state_id",
      "city_id": "$city_id",
      "postal_code": "$postal_code",
      "phone": "$phone"
    });

    String url = ("${AppConfig.BASE_URL}/user/shipping/update");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return addressUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateLocationResponse(
    int? id,
    double? latitude,
    double? longitude,
  ) async {
    var post_body = jsonEncode({
      "id": "${id}",
      "user_id": "${user_id.$}",
      "latitude": "$latitude",
      "longitude": "$longitude"
    });

    String url = ("${AppConfig.BASE_URL}/user/shipping/update-location");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return addressUpdateLocationResponseFromJson(response.body);
  }

  Future<dynamic> getAddressMakeDefaultResponse(
    int? id,
  ) async {
    var post_body = jsonEncode({
      "id": "$id",
    });

    String url = ("${AppConfig.BASE_URL}/user/shipping/make_default");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}"
        },
        body: post_body,
        middleware: BannedUser());
    return addressMakeDefaultResponseFromJson(response.body);
  }

  Future<dynamic> getAddressDeleteResponse(
    int? id,
  ) async {
    String url = ("${AppConfig.BASE_URL}/user/shipping/delete/$id");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());

    return addressDeleteResponseFromJson(response.body);
  }

  Future<dynamic> getCityListByState({state_id = 0, name = ""}) async {
    String url =
        ("${AppConfig.BASE_URL}/cities-by-state/${state_id}?name=${name}");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return cityResponseFromJson(response.body);
  }

  Future<dynamic> getStateListByCountry({country_id = 0, name = ""}) async {
    String url =
        ("${AppConfig.BASE_URL}/states-by-country/${country_id}?name=${name}");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return myStateResponseFromJson(response.body);
  }

  Future<dynamic> getCountryList({name = ""}) async {
    String url = ("${AppConfig.BASE_URL}/countries?name=${name}");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return countryResponseFromJson(response.body);
  }

  Future<dynamic> getShippingCostResponse({shipping_type = ""}) async {
    var post_body = jsonEncode({"seller_list": shipping_type});

    String url = ("${AppConfig.BASE_URL}/shipping_cost");

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: post_body,
        middleware: BannedUser());
    return shippingCostResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateInCartResponse(
      {int? address_id = 0, int pickup_point_id = 0}) async {
    var post_body = jsonEncode({
      "address_id": "${address_id}",
      "pickup_point_id": "${pickup_point_id}",
      "user_id": "${user_id.$}"
    });

    String url = ("${AppConfig.BASE_URL}/update-address-in-cart");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());

    return addressUpdateInCartResponseFromJson(response.body);
  }

  Future<dynamic> getShippingTypeUpdateInCartResponse(
      {required int shipping_id, shipping_type = "home_delivery"}) async {
    var post_body = jsonEncode({
      "shipping_id": "${shipping_id}",
      "shipping_type": "$shipping_type",
    });

    String url = ("${AppConfig.BASE_URL}/update-shipping-type-in-cart");

    print(url.toString());
    print(post_body.toString());
    print(access_token.$.toString());
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());

    return addressUpdateInCartResponseFromJson(response.body);
  }
}
