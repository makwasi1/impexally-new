import 'dart:async';

import 'package:active_ecommerce_flutter/data_model/login_response.dart';
import 'package:active_ecommerce_flutter/data_model/new_cart.dart';
import 'package:active_ecommerce_flutter/data_model/order_mini_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:active_ecommerce_flutter/repositories/order_repository.dart';
import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';

class CartCounter extends ChangeNotifier {
  int cartCounter = 0;
  int orderCounter = 0;

  getCount() async {
    LoginResponse user = await AuthHelper().getUserDetailsFromSharedPref();
    var res = await CartRepository().getCartCount();
    CartModel? cartResponseList =
        await CartRepository().getCartResponseList(user.user!.id);

    if (cartResponseList != null) {
      cartCounter = cartResponseList.cart!.items!.length;
    } else {
      cartCounter = 0;
    }
    notifyListeners();
    return cartCounter;
  }

  getOrderCount() async {
    LoginResponse user = await AuthHelper().getUserDetailsFromSharedPref();

    OrderMiniResponse? orderResponseList =
        await OrderRepository().getOrderList(user.user!.id.toString());

    if (orderResponseList != null) {
      orderCounter = orderResponseList.orders!.length;
    } else {
      orderCounter = 0;
    }
    notifyListeners();
    return orderCounter;
  }
}
