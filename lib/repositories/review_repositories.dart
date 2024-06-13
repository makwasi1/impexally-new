import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'dart:convert';

import 'package:active_ecommerce_flutter/data_model/review_response.dart';
import 'package:active_ecommerce_flutter/data_model/review_submit_response.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';

import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter/foundation.dart';

import '../data_model/login_response.dart';

class ReviewRepository {
  Future<dynamic> getReviewResponse(String? product_id, {page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/reviews/product/${product_id}");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      ReviewResponse reviewResponse = ReviewResponse.fromJson({
        "data": responseBody,
        "success": true,
        "status": 200,
      });
      return reviewResponse;
    } else {
      return ReviewResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<dynamic> getReviewSubmitResponse(
    String? product_id,
    int rating,
    String comment,
  ) async {
    AuthHelper authHelper = AuthHelper();
    LoginResponse loginUser = await authHelper.getUserDetailsFromSharedPref();

    var post_body = jsonEncode({
      "product_id": int.tryParse(product_id!),
      "user_id": loginUser.user?.id,
      "rating": rating,
      "review": "$comment",
      "ip_address": "192.168.1.1"
    });

    String url = ("${AppConfig.BASE_URL}/reviews");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    if (response.statusCode == 201) {
      var responseBody = jsonDecode(response.body);

      ReviewSubmitResponse reviewSubmitResponse =
          ReviewSubmitResponse.fromJson({
        "data": responseBody,
        "success": true,
        "status": 200,
      });
      return reviewSubmitResponse;
    } else {
      return ReviewSubmitResponse.fromJson(jsonDecode(response.body));
    }
  }
}
