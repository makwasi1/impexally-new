import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/login_response.dart';
import 'package:active_ecommerce_flutter/data_model/profile_image_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/user_info_response.dart';
import 'dart:convert';
import 'package:active_ecommerce_flutter/data_model/profile_counters_response.dart';
import 'package:active_ecommerce_flutter/data_model/profile_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/device_token_update_response.dart';
import 'package:active_ecommerce_flutter/data_model/phone_email_availability_response.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';

import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<dynamic> getProfileCountersResponse() async {
    String url = ("${AppConfig.BASE_URL}/profile/counters");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    return profileCountersResponseFromJson(response.body);
  }

  Future<dynamic> getProfileUpdateResponse({required String post_body}) async {
    String url = ("${AppConfig.BASE_URL}/profile/update");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return profileUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getDeviceTokenUpdateResponse(String device_token) async {
    LoginResponse res = await AuthHelper().getUserDetailsFromSharedPref();
    String? user_id = res.user!.id.toString();
    var post_body =
        jsonEncode({"fcm_token": "${device_token}", "id": "${user_id}"});

    String url = ("${AppConfig.BASE_URL}/setTokenUser");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    if (response.statusCode == 200) {
      return new DeviceTokenUpdateResponse(
          result: true, message: "Device token updated successfully");
    } else {
      return new DeviceTokenUpdateResponse(
          result: false, message: "Device token update failed");
    }
  }

  Future<dynamic> getProfileImageUpdateResponse(
      String image, String filename) async {
    var post_body = jsonEncode({"image": "${image}", "filename": "$filename"});
    print(post_body.toString());

    String url = ("${AppConfig.BASE_URL}/profile/update-image");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return profileImageUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getPhoneEmailAvailabilityResponse() async {
    //var post_body = jsonEncode({"user_id":"${user_id.$}"});

    String url = ("${AppConfig.BASE_URL}/profile/check-phone-and-email");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: '');

    return phoneEmailAvailabilityResponseFromJson(response.body);
  }

  Future<dynamic> getUserInfoResponse() async {
    String url = ("${AppConfig.BASE_URL}/customer/info");

    final response = await ApiRequest.get(url: url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
    });

    return userInfoResponseFromJson(response.body);
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieve verification code
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        // Handle other errors
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Save the verification ID for future use
        String smsCode = 'xxxxxx'; // Code input by the user
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        // Sign the user in with the credential
        await _auth.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: Duration(seconds: 60),
    );
  }

  
}
