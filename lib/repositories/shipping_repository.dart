import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/carriers_response.dart';
import 'package:active_ecommerce_flutter/data_model/check_response_model.dart';
import 'package:active_ecommerce_flutter/data_model/delivery_info_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';


class ShippingRepository{
  Future<dynamic> getDeliveryInfo() async {
    String url =
    ("${AppConfig.BASE_URL}/delivery-info");
    print(url.toString());
    final response = await ApiRequest.get(
      url:url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );


    return deliveryInfoResponseFromJson(response.body);
  }

}