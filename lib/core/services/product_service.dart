import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:http/http.dart' as http;
import 'package:socket_io_common/src/util/event_emitter.dart';
import 'package:swiss_gold/core/models/commodiy_model.dart';
import 'package:swiss_gold/core/models/market_model.dart';
import 'package:swiss_gold/core/models/prodcuts/product_model.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';

class ProductService {
  static final client = http.Client();

  static IO.Socket? _socket;

  static Future<void> initializeSocketConnection(
      Function(MarketModel) onDataReceived) async {
    final link = await getServer();
    log(link.toString());
    _socket = IO.io(link, {
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'secret': 'aurify@123',
      },
    });
    print('Connecting to WebSocket: $link');

    // Debugging connection lifecycle events
    _socket?.on('connect', (_) async {
      List<String> commodityArray = await fetchCommodityArray();

      requestMarketData(commodityArray);

      print('Connected to WebSocket!');
    });

    _socket?.on('connect_error', (error) {
      print('Connection failed: $error');
    });

    _socket?.on('connect_timeout', (_) {
      print('Connection timeout!');
    });

    _socket?.on('disconnect', (_) {
      print('Disconnected from WebSocket');
    });

    // Handle incoming messages
    _socket?.on('market-data', (data) async {
      // print('Received market-data event: $data');

      if (data is Map<String, dynamic>) {
        final marketData = await handleMarketData(data);
        // log('from websocket ${marketData.symbol}');
        // log('symbol is ${marketData!.symbol} ${marketData.bid}');
        onDataReceived(marketData!);
        // print('Parsed market-data: ${data['symbol']}');
      } else {
        print('Invalid market-data format received');
      }
    });

    // Other events (optional)
    _socket?.on('error', (error) {
      print('Received error event: $error');
    });

    // Start the connection
    await _socket?.connect();
  }

  static Future<MarketModel?> handleMarketData(
      Map<String, dynamic>? data) async {
    try {
      // Parse the incoming data with the simplified model
      MarketModel marketData = MarketModel.fromJson(data!);

      // Handle the market data based on the symbol
      // print("Received data for ${marketData.symbol}:");
      // print("Bid: ${marketData.bid}");

      // log(marketData.toString());

      return MarketModel.fromJson(data);

      // You can add additional logic here based on symbol if needed
    } catch (e) {
      return null;
    }
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
    // print("HERE IS THE SYMBOLS");
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    // print(symbols);
    _socket?.emit('request-data', [symbols]);
  }

  static Future<ProductModel?> showTopRated() async {
    try {
      var response = await client.get(
        Uri.parse(topRatedurl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return ProductModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
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
      log(e.toString());
      return [];
    }
  }

  static Future<String?> getServer() async {
    try {
      var response = await client.get(
        Uri.parse(getServerUrl),
        headers: {
          'X-Secret-Key': secreteKey,
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
      return null;
    }
  }

  static Future<ProductModel?> showNewArrival() async {
    try {
      var response = await client.get(
        Uri.parse(newArrivalurl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return ProductModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<ProductModel?> showBestSeller() async {
    try {
      var response = await client.get(
        Uri.parse(bestSellerUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return ProductModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<ProductModel?> listProductsFromCategory(
      Map<String, dynamic> payload) async {
    try {
      final url = listProductFromCategoryUrl
          .replaceFirst('{index}', payload['index'])
          .replaceFirst('{cId}', payload['cId']);
      log(url.toString());
      var response = await client.get(
        Uri.parse(url),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return ProductModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<ProductModel?> listProductsFromTag(
      Map<String, dynamic> payload) async {
    try {
      final url = listProductFromTagUrl
          .replaceFirst('{index}', payload['index'])
          .replaceFirst('{tag}', payload['tag']);
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
        return null;
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
