import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/commodiy_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/models/product_model.dart';
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
    // print('Connecting to WebSocket: $link');

    // Debugging connection lifecycle events
    _socket?.on('connect', (_) async {
      List<String> commodityArray = await fetchCommodityArray();

      requestMarketData(commodityArray);

      // print('Connected to WebSocket!');
    });

    _socket?.on('connect_error', (error) {
      // print('Connection failed: $error');
    });

    _socket?.on('connect_timeout', (_) {
      // print('Connection timeout!');
    });

    _socket?.on('disconnect', (_) {
      // print('Disconnected from WebSocket');
    });

    // Handle incoming messages
    _socket?.on('market-data', (data) async {
      // print('Received market-data event: $data');

      if (data is Map<String, dynamic>) {
        // log(data.toString());
        _marketDataStreamController.add(data);
        // Map<String, dynamic> marketData = data;
        // log(marketData['bid'].toString());
      }
    });

    // Other events (optional)
    _socket?.on('error', (error) {
      // print('Received error event: $error');
    });

    // Start the connection
    _socket?.connect();
    return null;
  }

  static Future<List<String>> fetchCommodityArray() async {
    final response = await http.get(
      Uri.parse(commoditiesUrl),
      headers: {
        'X-Secret-Key': secreteKey,
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // List<dynamic> data = json.decode(response.body);
      final commudity = CommodityModel.fromJson(json.decode(response.body));
      // return data.map((item) => item.toString()).toList();

      return commudity.commodities;
    } else {
      throw Exception('Failed to load commodity data');
    }
  }

  static void requestMarketData(List<String> symbols) {
    _socket?.emit('request-data', [symbols]);
  }

  static Future<List<String>> getBanner() async {
    try {
      var response = await client.get(
        Uri.parse(getBannerUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<String> banners = (responseData['banners'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();

        return banners;
      } else {
        return [];
      }
    } catch (e) {
      // log(e.toString());
      return [];
    }
  }

  static Future<String?> getServer() async {
    try {
      var response = await client.get(
        Uri.parse(getServerUrl),
        headers: {
          'X-Secret-Key': 'IfiuH/ko+rh/gekRvY4Va0s+=uucP3xwIfo0e8YTN1INF',
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String serverUrl = responseData['info']['serverURL'];
        return serverUrl;
      } else {
        return null;
      }
    } catch (e) {
      // print(e.toString());
      return null;
    }
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

  static Future<ProductModel?> listProducts(
      Map<String, dynamic> payload) async {
    try {
      final url = listProductUrl.replaceFirst('{index}', payload['index']);
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        // log(responseData.toString());

        return ProductModel.fromJson(responseData);
      } else {
        // Map<String, dynamic> responseData = jsonDecode(response.body);

        // log(responseData.toString());

        return null;
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
    try {
      var response = await client.put(Uri.parse(fixPriceUrl),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          }, // Encoding payload to JSON
          body: jsonEncode(payload));

      // log(payload.toString());

      if (response.statusCode == 200) {
        return MessageModel.fromJson({'success': true});
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        // log(responseData.toString());
        return MessageModel.fromJson(responseData);
      }
    } catch (e) {
      // log(e.toString());
      return null;
    }
  }

  static Future<MessageModel?> bookProducts(
      Map<String, dynamic> payload) async {
    try {
      final id = await LocalStorage.getString('userId');

      final url = bookingUrl.replaceFirst('{userId}', id.toString());
      var response = await client.post(Uri.parse(url),
          headers: {
            'X-Secret-Key': secreteKey,
            'Content-Type': 'application/json'
          },
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
}
