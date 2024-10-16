import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/category.dart';
import 'package:active_ecommerce_flutter/data_model/product_details_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_mini_response.dart';
import 'package:active_ecommerce_flutter/data_model/variant_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../data_model/product_detail.dart';
import '../data_model/products_model.dart';
import '../data_model/variant_price_response.dart';
import '../data_model/vendor_response.dart';

class ProductRepository {
  Future<CatResponse> getCategoryRes() async {
    String url = ("${AppConfig.BASE_URL}/seller/products/categories");

    var reqHeader = {
      "App-Language": app_language.$!,
      "Authorization": "Bearer ${access_token.$}",
      "Content-Type": "application/json"
    };

    final response = await ApiRequest.get(url: url, headers: reqHeader);

    return catResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getFeaturedProducts({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/featured?page=${page}");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    print(response.body);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getBestSellingProducts() async {
    String url = ("${AppConfig.BASE_URL}/products/best-seller");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Currency-Code": SystemConfig.systemCurrency!.code!,
      "Currency-Exchange-Rate":
          SystemConfig.systemCurrency!.exchangeRate.toString(),
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getInHouseProducts({page}) async {
    String url = ("${AppConfig.BASE_URL}/products/inhouse?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTodaysDealProducts() async {
    String url = ("${AppConfig.BASE_URL}/products/todays-deal");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getFlashDealProducts(id) async {
    String url = ("${AppConfig.BASE_URL}/flash-deal-products/$id");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductResponse> getCategoryProducts(
      {String? id = "", name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/category/${id.toString()}/products/");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      // Assuming jsonResponse is a list of products
      List<Products> products = (jsonResponse as List)
          .map((product) => Products.fromJson(product))
          .toList();
      return ProductResponse(products: products);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<ProductMiniResponse> getShopProducts(
      {int? id = 0, name = "", page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/seller/" +
        id.toString() +
        "?page=${page}&name=${name}");

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getBrandProducts(
      {required String slug, name = "", page = 1}) async {
    String url =
        ("${AppConfig.BASE_URL}/products/brand/$slug?page=${page}&name=${name}");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(url.toString());
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductResponse> getFilteredProducts(
      {name = "",
      sort_key = "",
      page = 1,
      brands = "",
      categories = "",
      min = "",
      max = ""}) async {
    String url = ("${AppConfig.BASE_URL}/products?page=$page");

    print(url.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
    });
    return productResponseFromJson(response.body);
  }

  Future<ProductResponse> getFilteredProductsFromSeller(
      String? seller_id) async {
    debugPrint("Seller ID: $seller_id");
    String url = ("${AppConfig.BASE_URL}/products/user/$seller_id");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return ProductResponse.fromJson(jsonResponse["products"]);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<ProductMiniResponse> getFilteredProducts2(
      {name = "",
      sort_key = "",
      page = 1,
      brands = "",
      categories = "",
      min = "",
      max = ""}) async {
    String url = ("${AppConfig.BASE_URL}/products" +
        "?page=$page&name=${name}&sort_key=${sort_key}&brands=${brands}&categories=${categories}&min=${min}&max=${max}");

    print(url.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getDigitalProducts({
    page = 1,
  }) async {
    String url = ("${AppConfig.BASE_URL}/products/digital?page=$page");
    print(url.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });
    // print(response.body);
    return productMiniResponseFromJson(response.body);
  }

  Future<ProductMiniDetail> getProductDetails({String? slug = ""}) async {
    String url = "${AppConfig.BASE_URL}/product/$slug";
    print("Product Url: $url");

    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
    });

    print(response.body);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      return ProductMiniDetail(
        products: Products.fromJson(jsonResponse['product']),
        productDetails: (jsonResponse['productDetails'] as List)
            .map((i) => ProductDetail.fromJson(i))
            .toList(),
        image: (jsonResponse['image'] as List)
            .map((i) => Photos.fromJson(i))
            .toList(),
      );
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<ProductDetailsResponse> getDigitalProductDetails({int id = 0}) async {
    String url = ("${AppConfig.BASE_URL}/products/" + id.toString());
    print(url.toString());
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    //print(response.body.toString());
    return productDetailsResponseFromJson(response.body);
  }

  Future<ProductResponse> getRelatedProducts({required String slug}) async {
    String url = ("${AppConfig.BASE_URL}/category/$slug/products");
    final response = await ApiRequest.get(url: url, headers: {
      "content-type": "application/json",
    });
    return productResponseFromJson(response.body);
  }

  Future<ProductMiniResponse> getTopFromThisSellerProducts(
      {required String slug}) async {
    String url = ("${AppConfig.BASE_URL}/products/top-from-seller/$slug");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    // print("top selling product url ${url.toString()}");
    // print("top selling product ${response.body.toString()}");

    return productMiniResponseFromJson(response.body);
  }

  Future<VariantResponse> getVariantWiseInfo(
      {required String slug, color = '', variants = '', qty = 1}) async {
    String url = ("${AppConfig.BASE_URL}/products/variant/price");

    var postBody = jsonEncode(
        {'slug': slug, "color": color, "variants": variants, "quantity": qty});

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "App-Language": app_language.$!,
          "Content-Type": "application/json",
        },
        body: postBody);

    return variantResponseFromJson(response.body);
  }

  Future<VariantPriceResponse> getVariantPrice({id, quantity}) async {
    String url = ("${AppConfig.BASE_URL}/varient-price");

    var post_body = jsonEncode({"id": id, "quantity": quantity});
    print(url.toString());
    print(post_body.toString());
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "App-Language": app_language.$!,
          "Content-Type": "application/json",
        },
        body: post_body);

    return variantPriceResponseFromJson(response.body);
  }

  //get vendor
  Future<VendorDetails> getVendorDetails({String? id}) async {
    String url = ("${AppConfig.BASE_URL}/user/" + id.toString());

    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      return VendorDetails.fromJson(jsonResponse['user']);
    } else {
      throw Exception('Failed to load vendor details');
    }
  }
}
