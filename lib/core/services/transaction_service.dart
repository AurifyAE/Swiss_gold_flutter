import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class TransactionService {
  final String userId = '67c2d55c396a819a08684dad';

  Future<TransactionResponse?> fetchTransactions({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$newBaseUrl/fetch-transtion/$userId?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'x-secret-key': 'IfiuH/ko+rh/gekRvY4Va0s+=uucP3xwIfo0e8YTN1INF',
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