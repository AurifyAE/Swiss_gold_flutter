import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/services/secrete_key.dart';

import '../utils/endpoint.dart';

class GoldRateProvider extends ChangeNotifier {
  IO.Socket? _socket;
  Map<String, dynamic>? _goldData;
  String _serverLink = 'https://capital-server-gnsu.onrender.com';
  bool _isConnected = false;
  bool _isLoading = false;

  // Getters
  Map<String, dynamic>? get goldData => _goldData;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;

  // Constructor
  GoldRateProvider() {
    initializeConnection();
  }

  // Initialize the connection to the Socket.IO server
  Future<void> initializeConnection() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final link = await fetchServerLink();
      if (link.isNotEmpty) {
        _serverLink = link;
      }
      await connectToSocket(link: _serverLink);
    } catch (e) {
      log("Error initializing connection: $e");
      await connectToSocket(link: _serverLink);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch server link from API
  Future<String> fetchServerLink() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/get-server'),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('info') && data['info'].containsKey('serverUrl')) {
          return data['info']['serverUrl'];
        }
      }
      return _serverLink;
    } catch (e) {
      log("Error fetching server link: $e");
      return _serverLink;
    }
  }

  // Connect to socket and start listening for gold data
  Future<void> connectToSocket({required String link}) async {
    try {
      _socket = IO.io(link, {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'reconnection': true,
        'query': {'secret': 'aurify@123'},
      });

      _socket?.onConnect((_) {
        log("Socket connected successfully");
        _isConnected = true;
        notifyListeners();
        
        // Request only gold data
        requestGoldData();
      });

      _socket?.on('market-data', (data) {
        handleGoldData(data);
      });

      _socket?.onConnectError((data) {
        log("Socket connection error: $data");
        _isConnected = false;
        notifyListeners();
      });

      _socket?.onDisconnect((_) {
        log("Socket disconnected");
        _isConnected = false;
        attemptReconnection();
        notifyListeners();
      });

      _socket?.connect();
    } catch (e) {
      log("Error connecting to socket: $e");
      attemptReconnection();
    }
  }

  // Handle market data specifically for Gold
  void handleGoldData(dynamic data) {
    try {
      if (data is Map<String, dynamic> && 
          data['symbol'] is String && 
          data['symbol'] == 'Gold') {
        
        // Process numerical values to ensure they're doubles
        Map<String, dynamic> processedData = Map<String, dynamic>.from(data);
        processedData.forEach((key, value) {
          if (value is num && value is! double) {
            processedData[key] = value.toDouble();
          }
        });
        
        _goldData = processedData;
        
        // // Log gold data details
        // log('Gold Rate Details:');
        // log('Bid: ${_goldData!['bid'] ?? 'N/A'}');
        // log('Ask: ${_goldData!['ask'] ?? 'N/A'}');
        // log('High: ${_goldData!['high'] ?? 'N/A'}');
        // log('Low: ${_goldData!['low'] ?? 'N/A'}');
        // log('Symbol: ${_goldData!['symbol'] ?? 'N/A'}');
        // log('Last Updated: ${_goldData!['timestamp'] ?? 'N/A'}');
        
        notifyListeners();
      }
    } catch (e) {
      log("Error handling gold data: $e");
    }
  }

  // Request only gold data from the server
  void requestGoldData() {
    try {
      _socket?.emit('request-data', [["Gold"]]);
      log('Requested Gold data only');
    } catch (e) {
      log('Error requesting Gold data: $e');
    }
  }

  // Attempt to reconnect if connection is lost
  void attemptReconnection() {
    if (!_isConnected) {
      Future.delayed(Duration(seconds: 5), () {
        log("Attempting to reconnect...");
        initializeConnection();
      });
    }
  }

  // Manual reconnect method
  void reconnect() {
    try {
      _socket?.disconnect();
      initializeConnection();
    } catch (e) {
      log("Error during manual reconnection: $e");
    }
  }

  // Refresh gold data
  Future<Map<String, dynamic>?> refreshGoldData() async {
    if (!_isConnected) {
      log('Socket not connected. Initializing connection...');
      await initializeConnection();
      // Wait for the connection to establish
      await Future.delayed(Duration(seconds: 2));
    }
    
    requestGoldData();
    
    // Wait a moment for data to arrive
    await Future.delayed(Duration(seconds: 2));
    return _goldData;
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }
}