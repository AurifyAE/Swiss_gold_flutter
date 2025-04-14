import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';
import 'package:swiss_gold/core/models/user_model.dart'; // Add this import

class TransactionService {
  final UserModel user;
  
  TransactionService({required this.user});

  Future<TransactionResponse?> fetchTransactions({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$newBaseUrl/fetch-transtion/${user.userId}?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return TransactionResponse.fromJson(decodedResponse);
      } else {
        print('Failed to fetch transactions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      return null;
    }
  }
}