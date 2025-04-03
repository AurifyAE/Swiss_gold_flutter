// import 'dart:developer';

// import 'package:swiss_gold/core/models/market_model.dart';
// import 'package:swiss_gold/core/models/message.dart';
// import 'package:swiss_gold/core/models/product_model.dart';
// import 'package:swiss_gold/core/services/local_storage.dart';
// import 'package:swiss_gold/core/services/product_service.dart';
// import 'package:swiss_gold/core/utils/enum/view_state.dart';
// import 'package:swiss_gold/core/view_models/base_model.dart';

// class ProductViewModel extends BaseModel {
//   final List<Product> _productList = [];
//   List<Product> get productList => _productList;
//   ProductModel? _productModel;
//   ProductModel? get productModle => _productModel;
//   bool hasMoreData = true;
//   bool isLoading = false;
//   int currentPage = 1;
//   bool? _isGuest;
//   num _totalQuantity = 0;
//   num get totalQuantity => _totalQuantity;
//   bool? get isGuest => _isGuest;

//   MessageModel? _messageModel;
//   MessageModel? get messageModel => _messageModel;

//   ViewState _marketPriceState = ViewState.idle;
//   ViewState get marketPriceState => _marketPriceState;

//   MarketModel? _marketModel;
//   MarketModel? get marketModel => _marketModel;

//   List<String> _banners = [];
//   List<String> get banners => _banners;

//   Map<String, dynamic>? _marketData;
//   Map<String, dynamic>? get marketData => _marketData;

//   ViewState _bannerState = ViewState.idle;
//   ViewState get bannerState => _bannerState;

//   double? _goldSpotRate;
//   double? get goldSpotRate => _goldSpotRate;

//   Future<void> getBanners() async {
//     _bannerState = ViewState.loading;
//     notifyListeners();
//     _banners = await ProductService.getBanner();
//     _bannerState = ViewState.idle;
//     notifyListeners();
//   }

//   Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
//     setState(ViewState.loading);
//     _messageModel = await ProductService.fixPrice(payload);

//     setState(ViewState.idle);
//     notifyListeners();

//     return _messageModel;
//   }

//   void getTotalQuantity(Map productQuantities) {
//     _totalQuantity =
//         productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
//     log(_totalQuantity.toString());
//   }

//   Future<MessageModel?> bookProducts(Map<String, dynamic> payload) async {
//     setState(ViewState.loading);
//     _messageModel = await ProductService.bookProducts(payload);
//     log(payload.toString());

//     setState(ViewState.idle);
//     notifyListeners();

//     return _messageModel;
//   }

//   void updateMarketData(Map<String, dynamic> data) {
//     final symbol = data['symbol'];
//     final bid = data['bid']?.toDouble();
//     if (symbol != null && bid != null) {
//       _marketModel?.updateBid(symbol, bid);
//       notifyListeners();
//     }
//   }

//   void getSpotRate() async {
//     _goldSpotRate = await ProductService.getSpotRate();
//     notifyListeners();
//   }

//   Future<void> getRealtimePrices() async {
//     _marketPriceState = ViewState.loading;
//     notifyListeners();

//     _marketData = await ProductService.initializeSocketConnection();

//     ProductService.marketDataStream.listen((data) {
//       _marketData = data;
//       // log('here we go ${_marketData.toString()}');
//       notifyListeners();
//     });

//     _marketPriceState = ViewState.idle;
//     notifyListeners();
//   }

//   checkGuestMode() async {
//     _isGuest = await LocalStorage.getBool('isGuest');
//     notifyListeners();
//   }

//   Future<void> listProducts(Map<String, dynamic> payload) async {
//     setState(ViewState.loading);
//     _productModel = await ProductService.listProducts(payload);
//     _productList.clear();

//     if (_productModel != null) {
//       _productList.addAll(_productModel!.data);
//     }

//     setState(ViewState.idle);
//     notifyListeners();
//   }

//   Future<void> loadMoreProducts(Map<String, dynamic> payload) async {
//     try {
//       if (_productModel!.page!.currentPage < _productModel!.page!.totalPage) {
//         setState(ViewState.loadingMore); // Optional: track loading more state
//         _productModel = await ProductService.listProducts(payload);
//         _productList.addAll(_productModel!.data);
//         setState(ViewState.loadingMore); // Reset state
//         notifyListeners();
//       }
//     } catch (e) {
//       // log(e.toString());
//     } finally {
//       setState(ViewState.idle); // Reset state
//     }
//   }
// }



import 'dart:developer';

import 'package:swiss_gold/core/models/market_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/models/product_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class ProductViewModel extends BaseModel {
  final List<Product> _productList = [];
  List<Product> get productList => _productList;
  ProductModel? _productModel;
  ProductModel? get productModle => _productModel;
  bool hasMoreData = true;
  bool isLoading = false;
  int currentPage = 1;
  bool? _isGuest;
  num _totalQuantity = 0;
  num get totalQuantity => _totalQuantity;
  bool? get isGuest => _isGuest;
  
  // Add this map to persist product quantities
  Map<int, int> _productQuantities = {};
  Map<int, int> get productQuantities => _productQuantities;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  ViewState _marketPriceState = ViewState.idle;
  ViewState get marketPriceState => _marketPriceState;

  MarketModel? _marketModel;
  MarketModel? get marketModel => _marketModel;

  List<String> _banners = [];
  List<String> get banners => _banners;

  Map<String, dynamic>? _marketData;
  Map<String, dynamic>? get marketData => _marketData;

  ViewState _bannerState = ViewState.idle;
  ViewState get bannerState => _bannerState;

  double? _goldSpotRate;
  double? get goldSpotRate => _goldSpotRate;

  Future<void> getBanners() async {
    _bannerState = ViewState.loading;
    notifyListeners();
    _banners = await ProductService.getBanner();
    _bannerState = ViewState.idle;
    notifyListeners();
  }

  Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    _messageModel = await ProductService.fixPrice(payload);

    setState(ViewState.idle);
    notifyListeners();

    return _messageModel;
  }

  // Update this method to store the quantities map
  void getTotalQuantity(Map<int, int> productQuantities) {
    // Store a copy of the quantities map
    _productQuantities = Map<int, int>.from(productQuantities);
    
    // Calculate total quantity as before
    _totalQuantity = productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
    log("Total quantity: $_totalQuantity");
    notifyListeners();
  }

  // Add a method to clear quantities (useful when order is placed)
  void clearQuantities() {
    _productQuantities.clear();
    _totalQuantity = 0;
    notifyListeners();
  }

  Future<MessageModel?> bookProducts(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    _messageModel = await ProductService.bookProducts(payload);
    log(payload.toString());

    setState(ViewState.idle);
    notifyListeners();

    return _messageModel;
  }

  void updateMarketData(Map<String, dynamic> data) {
    final symbol = data['symbol'];
    final bid = data['bid']?.toDouble();
    if (symbol != null && bid != null) {
      _marketModel?.updateBid(symbol, bid);
      notifyListeners();
    }
  }

  void getSpotRate() async {
    _goldSpotRate = await ProductService.getSpotRate();
    notifyListeners();
  }

  Future<void> getRealtimePrices() async {
    _marketPriceState = ViewState.loading;
    notifyListeners();

    _marketData = await ProductService.initializeSocketConnection();

    ProductService.marketDataStream.listen((data) {
      _marketData = data;
      // log('here we go ${_marketData.toString()}');
      notifyListeners();
    });

    _marketPriceState = ViewState.idle;
    notifyListeners();
  }

  checkGuestMode() async {
    _isGuest = await LocalStorage.getBool('isGuest');
    notifyListeners();
  }

  Future<void> listProducts(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    _productModel = await ProductService.listProducts(payload);
    _productList.clear();

    if (_productModel != null) {
      _productList.addAll(_productModel!.data);
    }

    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> loadMoreProducts(Map<String, dynamic> payload) async {
    try {
      if (_productModel!.page!.currentPage < _productModel!.page!.totalPage) {
        setState(ViewState.loadingMore); // Optional: track loading more state
        _productModel = await ProductService.listProducts(payload);
        _productList.addAll(_productModel!.data);
        setState(ViewState.loadingMore); // Reset state
        notifyListeners();
      }
    } catch (e) {
      // log(e.toString());
    } finally {
      setState(ViewState.idle); // Reset state
    }
  }
}