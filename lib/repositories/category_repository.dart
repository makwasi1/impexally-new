import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:http/http.dart' as http;
import 'package:active_ecommerce_flutter/data_model/category_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

import '../data_model/category_mini_response.dart';

class CategoryRepository {

  Future<CategoryListResponse> getCategories({parent_id = 0}) async {
    String url=("${AppConfig.BASE_URL}/categories?parent_id=${parent_id}");
    final response =
    await ApiRequest.get(url: url,headers: {
      "Content-Type": "application/json",
    });
    // print("${AppConfig.BASE_URL}/categories?parent_id=${parent_id}");
    print(response.body.toString());
    CategoryListResponse categoryList = CategoryListResponse.fromJson(json.decode(response.body));
    print(categoryList.categories);
    return categoryList;
  }

  Future<CategoryListResponse> getFeturedCategories() async {
    String url=("${AppConfig.BASE_URL}/categories");
    final response =
        await ApiRequest.get(url: url,headers: {
          "Content-Type": "application/json",
        });
    //print(response.body.toString());
    print("--featured cat--");
    CategoryListResponse categoryList = CategoryListResponse.fromJson(json.decode(response.body));
    return categoryList;
  }

  Future<CategoryResponse> getCategoryInfo(slug) async {
    String url=("${AppConfig.BASE_URL}/category/info/$slug");
    final response =
        await ApiRequest.get(url: url,headers: {
          "Content-Type": "application/json",
        });
    //print(response.body.toString());
    //print("--featured cat--");
    return categoryResponseFromJson(response.body);
  }

  Future<CategoryListResponse> getTopCategories() async {
    String url=("${AppConfig.BASE_URL}/categories");
    final response =
    await ApiRequest.get(url: url,headers: {
      "Content-Type": "application/json",
    });
    CategoryListResponse categoryList = CategoryListResponse.fromJson(json.decode(response.body));
    return categoryList;
  }

  Future<CategoryResponse> getFilterPageCategories() async {
    String url=("${AppConfig.BASE_URL}/filter/categories");
    final response =
    await ApiRequest.get(url: url,headers: {
      "App-Language": app_language.$!,
    });
    return categoryResponseFromJson(response.body);
  }


}
