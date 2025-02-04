import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/order_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';


class OrderHistoryService {
   static final client = http.Client();
     static Future<OrderModel?> getOrderHistory() async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = getOrderHistoryUrl.replaceFirst('{userId}', id.toString());
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return OrderModel.fromJson(responseData);
      } else {

        return null;
      }
    } catch (e) {
      return null;
    }
  }
}