import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/data_model/conversation_response.dart';
import 'package:active_ecommerce_flutter/data_model/message_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/middlewares/banned_user.dart';
import 'package:active_ecommerce_flutter/repositories/api-request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data_model/conversation_create_response.dart';

class ChatRepository {
  Future<dynamic> getConversationResponse({page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/chat/conversations?page=${page}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return conversationResponseFromJson(response.body);
  }

  //start chat conversation

  Future<dynamic> getMessageResponse(
      {required conversation_id, page = 1}) async {
    String url = ("${AppConfig.BASE_URL}/chats/${conversation_id}");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);

      MessageResponse messageResponse = MessageResponse.fromJson({
        "data": responseJson["messages"],
        "success": true,
        "status": 200,
      });
      return messageResponse;
    } else {
      return null;
    }
  }

  Future<dynamic> getInserMessageResponse(
      {required conversation_id,
      required String message,
      String? receiver_id}) async {
    const storage = FlutterSecureStorage();
    String? user_id = await storage.read(key: "user_id");

    var post_body = jsonEncode({
      "sender_id": "${user_id}",
      "receiver_id": "${receiver_id}",
      "message": "${message}"
    });

    String url = ("${AppConfig.BASE_URL}/chats/$conversation_id/messages");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
      body: post_body,
    );
    if (response.statusCode == 201) {
      var responseJson = jsonDecode(response.body);
      MessageResponse msgResponse = MessageResponse.fromJson({
        "data": [responseJson],
        "success": true,
        "status": 200,
      });
      return msgResponse;
    }
  }

  Future<String> startChatSession({int? product_id}) async {
    const storage = FlutterSecureStorage();
    String? user_id = await storage.read(key: "user_id");
    var post_body = jsonEncode({
      "sender_id": "${user_id}",
      "receiver_id": "1", //hardcoded admin id
      "subject": "Product Inquiry",
      "product_id": product_id ?? 0
    });

    String url = ("${AppConfig.BASE_URL}/chats");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
      },
      body: post_body,
    );
    //get the id from the json response
    int conversation_id = jsonDecode(response.body)["id"];

    debugPrint("conversation_id repository: $conversation_id");

    // await storage.write(key: "conversation_id", value: conversation_id);
   
    return conversation_id.toString();
  }

  Future<dynamic> getNewMessageResponse(
      {required conversation_id, required last_message_id}) async {
    String url =
        ("${AppConfig.BASE_URL}/chat/get-new-messages/${conversation_id}/${last_message_id}");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());
    return messageResponseFromJson(response.body);
  }

  Future<dynamic> getCreateConversationResponse(
      {required product_id,
      required String title,
      required String message}) async {
    var post_body = jsonEncode({
      "user_id": "${user_id.$}",
      "product_id": "${product_id}",
      "title": "${title}",
      "message": "${message}"
    });
    String url = ("${AppConfig.BASE_URL}/chat/create-conversation");
    print("Bearer ${access_token.$}");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: post_body,
        middleware: BannedUser());
    return conversationCreateResponseFromJson(response.body);
  }
}
