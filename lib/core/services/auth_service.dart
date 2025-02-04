import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/models/user_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class AuthService {
  static final client = http.Client();

  static Future<UserModel?> login(Map<String, dynamic> payload) async {
    try {
      var response = await client.post(
        Uri.parse(loginUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload), // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
      
        Future.wait([
          LocalStorage.setString({'userId': responseData['userId']}),
          LocalStorage.setString(
              {'userName': responseData['userDetails']['name']}),
          LocalStorage.setString(
              {'mobile': responseData['userDetails']['contact'].toString()}),
          LocalStorage.setString(
              {'location': responseData['userDetails']['location']}),
          LocalStorage.setString(
              {'category': responseData['userDetails']['categoryName']}),
        ]);


        return UserModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return UserModel.withError(responseData);
      }
    } catch (e) {
      return null;
    }
  }

  static Future<MessageModel?> changePassword(
      Map<String, dynamic> payload) async {
    try {
      var response = await client.put(
        Uri.parse(changePassUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(payload), // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return MessageModel.fromJson(responseData);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return MessageModel.withError(responseData);
      }
    } catch (e) {
      return null;
    }
  }
}
