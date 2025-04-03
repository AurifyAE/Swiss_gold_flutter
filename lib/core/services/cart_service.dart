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

        // log(responseData.toString());
        return CartModel.fromJson(responseData);
      } else {
        //  Map<String, dynamic> responseData = jsonDecode(response.body);

        // log(responseData.toString());
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<MessageModel?> updateQuantityFromHome(
      String pId, Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');
      log(payload.toString());
      log(id.toString());

      final url = updateQuantityFromHomeUrl
          .replaceFirst('{userId}', id.toString())
          .replaceFirst('{pId}', pId);
      log(url);
      var response = await client.put(Uri.parse(url),
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
        log(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        log(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<void> confirmQuantity(Map<String, dynamic> payload) async {
    try {
      var response = await client.post(Uri.parse(confirmQuantityUrl),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          }, // Encoding payload to JSON
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        // log(response.body);
      } else {
        // log(response.body);
      }
    } catch (e) {
      // log(e.toString());
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
