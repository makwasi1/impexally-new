import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/common_response.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:active_ecommerce_flutter/data_model/confirm_code_response.dart';
import 'package:active_ecommerce_flutter/data_model/login_response.dart';
import 'package:active_ecommerce_flutter/data_model/logout_response.dart';
import 'package:active_ecommerce_flutter/data_model/password_confirm_response.dart';
import 'package:active_ecommerce_flutter/data_model/password_forget_response.dart';
import 'package:active_ecommerce_flutter/data_model/resend_code_response.dart';
import 'package:active_ecommerce_flutter/data_model/signup_response.dart';
import 'package:active_ecommerce_flutter/data_model/user_by_token.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<LoginResponse> getLoginResponse(String? email, String password,String loginBy) async {
    var post_body = jsonEncode({
      "email": "${email}",
      "password": "$password",
    });

    String url = ("${AppConfig.BASE_URL}/login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json",
        },
        body: post_body);

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> getSocialLoginResponse(
    String social_provider,
    String? name,
    String? email,
    String? provider, {
    access_token = "",
    secret_token = "",
  }) async {
    email = email == ("null") ? "" : email;

    var post_body = jsonEncode({
      "name": name,
      "email": email,
      "provider": "$provider",
      "social_provider": "$social_provider",
      "access_token": "$access_token",
      "secret_token": "$secret_token"
    });

    // print(post_body);
    String url = ("${AppConfig.BASE_URL}/auth/social-login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);
    // print(post_body);
    // print(response.body.toString());
    return loginResponseFromJson(response.body);
  }

  Future<void> getLogoutResponse() async {
    AuthHelper().clearUserData();
  }

  Future<CommonResponse> getAccountDeleteResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/account-deletion");

    // print(url.toString());

    print("Bearer ${access_token.$}");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    // print(response.body);
    return commonResponseFromJson(response.body);
  }

  Future<LoginResponse> getSignupResponse(
    String name,
    String? email_or_phone,
    String password,
  ) async {
    var post_body = jsonEncode({
      "username": "$name",
      "email": "${email_or_phone}",
      "password": "$password",
      "first_name": "$name",
      "last_name": "$name",
      // "register_by": "$register_by",
      // "g-recaptcha-response": "$capchaKey",
    });

    String url = ("${AppConfig.BASE_URL}/register");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    return loginResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getResendCodeResponse() async {
    String url = ("${AppConfig.BASE_URL}/auth/resend_code");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },);
    return resendCodeResponseFromJson(response.body);
  }

  Future<ConfirmCodeResponse> getConfirmCodeResponse(String verification_code) async {
    var post_body = jsonEncode({ "verification_code": "$verification_code"});

    String url = ("${AppConfig.BASE_URL}/auth/confirm_code");
    // print(url);
    // print(post_body);
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },
        body: post_body);

    return confirmCodeResponseFromJson(response.body);
  }

  Future<PasswordForgetResponse> getPasswordForgetResponse(
      String? email_or_phone, String send_code_by) async {
    var post_body = jsonEncode(
        {"email_or_phone": "$email_or_phone", "send_code_by": "$send_code_by"});

    String url = ("${AppConfig.BASE_URL}/auth/password/forget_request");

    // print(url.toString());
    // print(post_body.toString());

    final response = await ApiRequest.post(url:url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return passwordForgetResponseFromJson(response.body);
  }

  Future<PasswordConfirmResponse> getPasswordConfirmResponse(
      String verification_code, String password) async {
    var post_body = jsonEncode(
        {"verification_code": "$verification_code", "password": "$password"});

    String url = ("${AppConfig.BASE_URL}/auth/password/confirm_reset");
    final response = await ApiRequest.post(url:url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return passwordConfirmResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getPasswordResendCodeResponse(
      String? email_or_code, String verify_by) async {
    var post_body = jsonEncode(
        {"email_or_code": "$email_or_code", "verify_by": "$verify_by"});

    String url = ("${AppConfig.BASE_URL}/auth/password/resend_code");
    final response = await ApiRequest.post(url:url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return resendCodeResponseFromJson(response.body);
  }

  Future<LoginResponse> getUserByTokenResponse() async {
    var post_body = jsonEncode({"access_token": "${access_token.$}"});

    String url = ("${AppConfig.BASE_URL}/auth/info");
    if (access_token.$!.isNotEmpty) {
      final response = await ApiRequest.post(url:url,
          headers: {
            "Content-Type": "application/json",
            "App-Language": app_language.$!,
          },
          body: post_body);

      return loginResponseFromJson(response.body);
    }
    return LoginResponse();
  }
}
