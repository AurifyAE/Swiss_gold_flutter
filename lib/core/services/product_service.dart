import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class ProductService {
  static final client = http.Client();
  static final _marketDataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get marketDataStream =>
      _marketDataStreamController.stream;

  static IO.Socket? _socket;

  static Future<Map<String, dynamic>?> initializeSocketConnection() async {
    final link = await getServer();
    _socket = IO.io(link, {
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'secret': 'aurify@123',
      },
    });

    // Debugging connection lifecycle events
    _socket?.on('connect', (_) async {
      List<String> productSymbols = await fetchProductSymbols();
      requestMarketData(productSymbols);
    });

    _socket?.on('connect_error', (error) {
      log('Connection failed: $error');
    });

    _socket?.on('connect_timeout', (_) {
      log('Connection timeout!');
    });

    _socket?.on('disconnect', (_) {
      log('Disconnected from WebSocket');
    });

    // Handle incoming messages
    _socket?.on('market-data', (data) async {
      if (data is Map<String, dynamic>) {
        _marketDataStreamController.add(data);
      }
    });

    // Other events (optional)
    _socket?.on('error', (error) {
      log('Received error event: $error');
    });

    // Start the connection
    _socket?.connect();
    return null;
  }

  static Future<double?> getSpotRate() async {
    try {
      var response = await client.get(
        Uri.parse(getSpotRateUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        num goldSpotRate = responseData['info']['goldBidSpread'];
        // log(goldSpotRate.toString());
        // log(response.body);
        return goldSpotRate.toDouble();
      } else {
        // log(response.body);
        return null;
      }
    } catch (e) {
      // print(e.toString());
      return null;
    }
  }

  static Future<List<String>> fetchProductSymbols() async {
    try {
      // Get adminId and categoryId from storage
      final adminId = await LocalStorage.getString('adminId') ?? '';
      final categoryId = await LocalStorage.getString('categoryId') ?? '';

      log('Fetching product symbols with adminId: $adminId, categoryId: $categoryId');

      // Fetch products using the flexible fetching method
      final products = await fetchProducts(adminId, categoryId);

      // Extract product identifiers (using SKU as symbols)
      return products.map((product) => product['sku'].toString()).toList();
    } catch (e) {
      log('Error fetching product symbols: ${e.toString()}');
      return [];
    }
  }

  static void requestMarketData(List<String> symbols) {
    if (symbols.isEmpty) {
      log('Warning: No symbols provided for market data request');
    }
    _socket?.emit('request-data', [symbols]);
  }

  static Future<String> getServer() async {
    try {
      var response = await client.get(
        Uri.parse('https://api.aurify.ae/user/get-server'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['info'] != null) {
          String? serverUrl = responseData['info']['serverURL'];
          if (serverUrl == null || serverUrl.isEmpty) {
            log('Server URL is empty or null');
          }
          return serverUrl ?? ''; // Ensure a string is returned
        }
      }
      log('Failed to get server URL, status: ${response.statusCode}');
      return ''; // Return an empty string if the response isn't valid
    } catch (e) {
      log('Error getting server: ${e.toString()}');
      return ''; // Ensure no null values are returned
    }
  }

  static Future<List<dynamic>> fetchProducts(
      [String? adminId, String? categoryId]) async {
    try {
      // Use provided parameters or fetch from storage if not provided
      adminId = '67f37dfe4831e0eb637d09f1';
      categoryId ??= await LocalStorage.getString('categoryId') ?? '';

      log('Fetching products with adminId: $adminId, categoryId: $categoryId');

      // Construct the URL based on the custom logic
      String baseUrl = 'https://api.nova.aurify.ae/user/get-product';
      String url;

      if (adminId.isNotEmpty && categoryId.isNotEmpty) {
        // Both adminId and categoryId are present
        url = '$baseUrl/$adminId/$categoryId';
      } else if (adminId.isNotEmpty) {
        // Only adminId is present
        url = '$baseUrl/$adminId';
      } else if (categoryId.isNotEmpty) {
        // Only categoryId is present
        url = '$baseUrl/null/$categoryId';
      } else {
        // Neither is present, do not make the request
        log('Error: Both adminId and categoryId are empty');
        throw Exception('Missing required parameters');
      }

      log('Making request to URL: $url');

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json',
        },
      );

      log('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log('Response data: ${responseData.toString()}');

        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        } else {
          log('API returned success=false or null data');
          return [];
        }
      } else {
        log('API returned error status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching products: ${e.toString()}');
      return [];
    }
  }

  static Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
    try {
      log('Fixing price with payload: ${payload.toString()}');
      var response = await client.put(Uri.parse(fixPriceUrl),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload));

      if (response.statusCode == 200) {
        return MessageModel.fromJson({'success': true});
      } else {
        log('Failed to fix price, status: ${response.statusCode}');
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error fixing price: ${e.toString()}');
      return null;
    }
  }

  static Future<MessageModel?> bookProducts(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');
      if (id == null || id.isEmpty) {
        log('Error: userId is empty');
        return MessageModel.fromJson(
            {'success': false, 'message': 'User ID is missing'});
      }

      final url = bookingUrl.replaceFirst('{userId}', id.toString());
      log('Booking products with URL: $url');
      log('Booking payload: ${payload.toString()}');

      var response = await client.post(Uri.parse(url),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload));

      log('Booking response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      } else {
        log('Booking error response: ${response.body}');
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      log('Error booking products: ${e.toString()}');
      return null;
    }
  }

  static void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _marketDataStreamController.close();
  }
}
