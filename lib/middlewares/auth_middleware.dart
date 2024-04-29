import 'package:active_ecommerce_flutter/helpers/main_helpers.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/middlewares/route_middleware.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class AuthMiddleware extends RouteMiddleware{

  Widget _goto;


  AuthMiddleware(this._goto);

  @override
  Widget next() {
    if(!userIsLogedIn){
      return Login();
    }
    return _goto;

  }

}