import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data_model/login_response.dart';

class AuthHelper {
  final storage = FlutterSecureStorage();

  setUserData(LoginResponse loginResponse) {
    if (loginResponse.result == true) {
      SystemConfig.systemUser= loginResponse.user;
      is_logged_in.$ = true;
      is_logged_in.save();
      user_id.$ = loginResponse.user?.id;
      user_id.save();
      user_name.$ = loginResponse.user?.name;
      user_name.save();
      user_email.$ = loginResponse.user?.email??"";
      user_email.save();
      user_phone.$ = loginResponse.user?.phone??"";
      user_phone.save();
      avatar_original.$ = loginResponse.user?.avatar_original??"";
      avatar_original.save();
    }
  }

  clearUserData() {
    SystemConfig.systemUser= null;
      is_logged_in.$ = false;
      is_logged_in.save();
      user_id.$ = 0;
      user_id.save();
      user_name.$ = "";
      user_name.save();
      user_email.$ = "";
      user_email.save();
      user_phone.$ = "";
      user_phone.save();
      avatar_original.$ = "";
      avatar_original.save();
  }


  fetch_and_set() async {
    var userByTokenResponse = await AuthRepository().getUserByTokenResponse();
    if (userByTokenResponse.result == true) {
      setUserData(userByTokenResponse);
    }else{
      // clearUserData();
    }
  }

  saveUserDetailsToSharedPref(LoginResponse loginResponse) {
    if (loginResponse.result == true) {
      storage.write(key: 'is_logged_in', value: "true");
      storage.write(key: 'user_id', value: loginResponse.user?.id.toString());
      storage.write(key: 'user_name', value: loginResponse.user?.name);
      storage.write(key: 'user_email', value: loginResponse.user?.email);
      storage.write(key: 'user_phone', value: loginResponse.user?.phone);
      storage.write(key: 'avatar_original', value: loginResponse.user?.avatar_original);
    }
  }

  //read the user details from the shared pref
  Future<LoginResponse> getUserDetailsFromSharedPref() async {
    LoginResponse loginResponse = new LoginResponse();
    loginResponse.result = false;
    loginResponse.user = new User();
    loginResponse.user!.id = 0;
    loginResponse.user!.name = "";
    loginResponse.user!.email = "";
    loginResponse.user!.phone = "";
    loginResponse.user!.avatar_original = "";

    String? is_logged_in = await storage.read(key: 'is_logged_in');
    if (is_logged_in == "true") {
      String? user_id = await storage.read(key: 'user_id');
      loginResponse.result = true;
      loginResponse.user!.id = int.tryParse(user_id!);
      loginResponse.user!.name = await storage.read(key: 'user_name');
      loginResponse.user!.email = await storage.read(key: 'user_email');
      loginResponse.user!.phone = await storage.read(key: 'user_phone');
      loginResponse.user!.avatar_original = await storage.read(key: 'avatar_original');
    }
    return loginResponse;
  }

  //clear the user details from the shared pref
  clearUserDetailsFromSharedPref() {
    storage.deleteAll();
  }
}
