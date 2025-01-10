import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/cart_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class CartService {
  static final client = http.Client();

  static Future<CartModel?> getCart() async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = getCartUrl.replaceFirst('{userId}', id.toString());
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return CartModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<MessageModel?> addToCart(Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = addToCartUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', payload['pId']);
      var response = await client.post(Uri.parse(url),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          }, // Encoding payload to JSON
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<MessageModel?> incrementQuantity(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = incrementQuantityUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', payload['pId']);
      var response = await client.patch(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );


      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<MessageModel?> decrementQuantity(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = decrementQuantityUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', payload['pId']);
      var response = await client.patch(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<MessageModel?> deleteFromCart(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = deleteFromCartUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', payload['pId']);
      var response = await client.delete(Uri.parse(url),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          }, // Encoding payload to JSON
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }
}
