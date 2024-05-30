import 'dart:async';

import 'package:active_ecommerce_flutter/data_model/new_cart.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/cart_repository.dart';
import 'package:flutter/material.dart';

class CartCounter extends ChangeNotifier {
  int cartCounter = 0;

  getCount() async {
    var res = await CartRepository().getCartCount();
    CartModel? cartResponseList =
        await CartRepository().getCartResponseList(user_id.$);

    if (cartResponseList != null) {
      cartCounter = cartResponseList.cart!.items!.length;
    } else {
      cartCounter = 0;
    }
    notifyListeners();
  }
}
