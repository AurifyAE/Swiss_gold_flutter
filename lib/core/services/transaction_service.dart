// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:swiss_gold/core/models/transaction_model.dart';
// import 'package:swiss_gold/core/services/secrete_key.dart';
// import 'package:swiss_gold/core/utils/endpoint.dart';
// import 'package:swiss_gold/core/models/user_model.dart'; // Add this import

// class TransactionService {
//   final UserModel user;
  
//   TransactionService({required this.user});

//   Future<TransactionResponse?> fetchTransactions({int page = 1}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$newBaseUrl/fetch-transtion/${user.userId}?page=$page'),
//         headers: {
//           'Content-Type': 'application/json',
//           'x-secret-key': secreteKey,
//         },
//       );

//       if (response.statusCode == 200) {
//         final decodedResponse = jsonDecode(response.body);
//         return TransactionResponse.fromJson(decodedResponse);
//       } else {
//         print('Failed to fetch transactions: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Error fetching transactions: $e');
//       return null;
//     }
//   }
// }


import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/models/user_model.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class TransactionService {
  final UserModel user;
  
  TransactionService({required this.user}) {
    log('TransactionService initialized with user ID: ${user.userId}');
  }

  Future<TransactionResponse?> fetchTransactions({int page = 1, int limit = 10}) async {
    if (user.userId.isEmpty) {
      log('Cannot fetch transactions: User ID is empty');
      return null;
    }
    
    try {
      log('Fetching transactions for user: ${user.userId}, page: $page');
      
      final Uri uri = Uri.parse('$newBaseUrl/fetch-transtion/${user.userId}')
        .replace(queryParameters: {
          'page': '$page',
          'limit': '$limit'
        });
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${user.token ?? ""}',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        log('Transaction response received successfully');
        return TransactionResponse.fromJson(decodedResponse);
      } else {
        log('Failed to fetch transactions: ${response.statusCode}');
        log('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error fetching transactions: $e');
      return null;
    }
  }
  
  // Method to fetch a specific transaction by ID
  Future<Transaction?> fetchTransactionById(String transactionId) async {
    if (user.userId.isEmpty || transactionId.isEmpty) {
      log('Cannot fetch transaction: User ID or Transaction ID is empty');
      return null;
    }
    
    try {
      log('Fetching transaction details for ID: $transactionId');
      
      final response = await http.get(
        Uri.parse('$newBaseUrl/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${user.token ?? ""}',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] != null) {
          return Transaction.fromJson(decodedResponse['data']);
        }
        return null;
      } else {
        log('Failed to fetch transaction details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching transaction details: $e');
      return null;
    }
  }
  
  // Method to fetch user balance
  Future<BalanceInfo?> fetchBalance() async {
    if (user.userId.isEmpty) {
      log('Cannot fetch balance: User ID is empty');
      return null;
    }
    
    try {
      log('Fetching balance for user: ${user.userId}');
      
      final response = await http.get(
        Uri.parse('$newBaseUrl/user-balance/${user.userId}'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${user.token ?? ""}',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] != null) {
          return BalanceInfo.fromJson(decodedResponse['data']);
        }
        return null;
      } else {
        log('Failed to fetch balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching balance: $e');
      return null;
    }
  }
  
  // Method to get transaction summary
  Future<Summary?> fetchTransactionSummary() async {
    if (user.userId.isEmpty) {
      log('Cannot fetch transaction summary: User ID is empty');
      return null;
    }
    
    try {
      log('Fetching transaction summary for user: ${user.userId}');
      
      final response = await http.get(
        Uri.parse('$newBaseUrl/transaction-summary/${user.userId}'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${user.token ?? ""}',
          'x-secret-key': secreteKey,
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == true && decodedResponse['data'] != null) {
          return Summary.fromJson(decodedResponse['data']);
        }
        return null;
      } else {
        log('Failed to fetch transaction summary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching transaction summary: $e');
      return null;
    }
  }
}