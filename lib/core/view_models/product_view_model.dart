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
//   ProductModel? get productModel => _productModel;
  
//   bool hasMoreData = true;
//   bool isLoading = false;
//   int currentPage = 1;
//   bool? _isGuest;
//   num _totalQuantity = 0;
//   num get totalQuantity => _totalQuantity;
//   bool? get isGuest => _isGuest;
  
//   // Store product quantities
//   Map<int, int> _productQuantities = {};
//   Map<int, int> get productQuantities => _productQuantities;

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

//   // Initialize admin and category IDs
//   String? _adminId;
//   String? _categoryId;

//   // Constructor to initialize the service
//   ProductViewModel() {
//     _initializeIds();
//   }

//   // Initialize required IDs from local storage
//   Future<void> _initializeIds() async {
//     _adminId = await LocalStorage.getString('adminId');
//     _categoryId = await LocalStorage.getString('categoryId');
    
//     log('Initialized ProductViewModel with adminId: $_adminId, categoryId: $_categoryId');
    
//     // Check if IDs are valid and show appropriate warnings
//     if (_adminId == null || _adminId!.isEmpty) {
//       log('Warning: adminId is not set in local storage');
//     }
    
//     if (_categoryId == null || _categoryId!.isEmpty) {
//       log('Warning: categoryId is not set in local storage');
//     }
    
//     notifyListeners();
//   }

//   Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
//     setState(ViewState.loading);
//     _messageModel = await ProductService.fixPrice(payload);

//     setState(ViewState.idle);
//     notifyListeners();

//     return _messageModel;
//   }

//   // Update this method to store the quantities map
//   void getTotalQuantity(Map<int, int> productQuantities) {
//     // Store a copy of the quantities map
//     _productQuantities = Map<int, int>.from(productQuantities);
    
//     // Calculate total quantity as before
//     _totalQuantity = productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
//     log("Total quantity: $_totalQuantity");
//     notifyListeners();
//   }

//   // Add a method to clear quantities (useful when order is placed)
//   void clearQuantities() {
//     _productQuantities.clear();
//     _totalQuantity = 0;
//     notifyListeners();
//   }

//   Future<MessageModel?> bookProducts(Map<String, dynamic> payload) async {
//     setState(ViewState.loading);
//     _messageModel = await ProductService.bookProducts(payload);
//     log('Book products payload: ${payload.toString()}');

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

//   Future<void> getRealtimePrices() async {
//     _marketPriceState = ViewState.loading;
//     notifyListeners();

//     try {
//       _marketData = await ProductService.initializeSocketConnection();

//       ProductService.marketDataStream.listen((data) {
//         _marketData = data;
//         notifyListeners();
//       });
//     } catch (e) {
//       log('Error getting realtime prices: ${e.toString()}');
//     } finally {
//       _marketPriceState = ViewState.idle;
//       notifyListeners();
//     }
//   }

//   Future<void> checkGuestMode() async {
//     try {
//       _isGuest = await LocalStorage.getBool('isGuest');
//       log('Guest mode: $_isGuest');
//     } catch (e) {
//       log('Error checking guest mode: ${e.toString()}');
//       _isGuest = false;
//     }
//     notifyListeners();
//   }

//   Future<void> fetchAdminAndCategoryIds() async {
//     try {
//       _adminId = await LocalStorage.getString('adminId');
//       _categoryId = await LocalStorage.getString('categoryId');
      
//       log('Fetched adminId: $_adminId, categoryId: $_categoryId');
      
//       if (_adminId == null || _adminId!.isEmpty) {
//         log('Warning: adminId is not set in local storage');
//       }
      
//       if (_categoryId == null || _categoryId!.isEmpty) {
//         log('Warning: categoryId is not set in local storage');
//       }
      
//       notifyListeners();
//     } catch (e) {
//       log('Error fetching IDs: ${e.toString()}');
//     }
//   }

//   // Future<void> listProducts(Map<String, dynamic> payload) async {
//   //   setState(ViewState.loading);
    
//   //   try {
//   //     log('Listing products with payload: ${payload.toString()}');
//   //     _productModel = await ProductService.listProducts(payload);
//   //     _productList.clear();

//   //     if (_productModel != null && _productModel!.data.isNotEmpty) {
//   //       _productList.addAll(_productModel!.data);
//   //       log('Retrieved ${_productList.length} products');
//   //     } else {
//   //       log('No products found or product model is null');
//   //     }
//   //   } catch (e) {
//   //     log('Error listing products: ${e.toString()}');
//   //   } finally {
//   //     setState(ViewState.idle);
//   //     notifyListeners();
//   //   }
//   // }

//   // Future<void> loadMoreProducts(Map<String, dynamic> payload) async {
//   //   try {
//   //     if (_productModel != null && 
//   //         _productModel!.page != null && 
//   //         _productModel!.page!.currentPage < _productModel!.page!.totalPage) {
        
//   //       setState(ViewState.loadingMore);
        
//   //       // Update page number in payload
//   //       payload['page'] = _productModel!.page!.currentPage + 1;
//   //       log('Loading more products, page: ${payload['page']}');
        
//   //       // ProductModel? moreProducts = await ProductService.listProducts(payload);
        
//   //       if (moreProducts != null && moreProducts.data.isNotEmpty) {
//   //         _productList.addAll(moreProducts.data);
//   //         _productModel = moreProducts; // Update the model with new page info
//   //         log('Added ${moreProducts.data.length} more products, total: ${_productList.length}');
//   //       } else {
//   //         log('No additional products found');
//   //       }
        
//   //       notifyListeners();
//   //     } else {
//   //       // No more pages to load
//   //       hasMoreData = false;
//   //       log('No more products to load');
//   //       notifyListeners();
//   //     }
//   //   } catch (e) {
//   //     log("Error loading more products: ${e.toString()}");
//   //   } finally {
//   //     setState(ViewState.idle);
//   //   }
//   // }
  
//   @override
//   void dispose() {
//     // Clean up any resources
//     ProductService.dispose();
//     super.dispose();
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
  ProductModel? get productModel => _productModel;

  bool hasMoreData = true;
  bool isLoading = false;
  bool? _isGuest;
  num _totalQuantity = 0;
  num get totalQuantity => _totalQuantity;
  bool? get isGuest => _isGuest;

  Map<int, int> _productQuantities = {};
  Map<int, int> get productQuantities => _productQuantities;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  ViewState _marketPriceState = ViewState.idle;
  ViewState get marketPriceState => _marketPriceState;

  MarketModel? _marketModel;
  MarketModel? get marketModel => _marketModel;

  Map<String, dynamic>? _marketData;
  Map<String, dynamic>? get marketData => _marketData;

  double? _goldSpotRate;
  double? get goldSpotRate => _goldSpotRate;

  String? _adminId;
  String? _categoryId;

  String? get adminId => _adminId;
  String? get categoryId => _categoryId;

  ProductViewModel() {
    _initializeIds();
    checkGuestMode();
  }
  

  Future<void> _initializeIds() async {
    try {
      _adminId = '67c1a8978399ea3181f5cad9';
      _categoryId = await LocalStorage.getString('categoryId') ?? '';
      
      log('Initialized ProductViewModel with adminId: $_adminId, categoryId: $_categoryId');
    } catch (e) {
      log('Error initializing IDs: ${e.toString()}');
      _adminId = '';
      _categoryId = '';
    }
    notifyListeners();
  }

  Future<MessageModel?> fixPrice(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    try {
      _messageModel = await ProductService.fixPrice(payload);
    } catch (e) {
      log('Error fixing price: ${e.toString()}');
    }
    setState(ViewState.idle);
    notifyListeners();
    return _messageModel;
  }

  void getTotalQuantity(Map<int, int> productQuantities) {
    _productQuantities = Map<int, int>.from(productQuantities);
    _totalQuantity = productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
    log("Total quantity: $_totalQuantity");
    notifyListeners();
  }

  void clearQuantities() {
    _productQuantities.clear();
    _totalQuantity = 0;
    notifyListeners();
  }

  Future<MessageModel?> bookProducts(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    try {
      _messageModel = await ProductService.bookProducts(payload);
      log('Book products payload: ${payload.toString()}');
    } catch (e) {
      log('Error booking products: ${e.toString()}');
    }
    setState(ViewState.idle);
    notifyListeners();
    return _messageModel;
  }

  void updateMarketData(Map<String, dynamic> data) {
    _marketData = data;
    final symbol = data['symbol'];
    final bid = data['bid']?.toDouble();

    if (symbol != null && bid != null) {
      if (symbol.toString().toLowerCase().contains('gold')) {
        _goldSpotRate = bid;
      }

      if (_marketModel != null) {
        _marketModel!.updateBid(symbol.toString(), bid);
      }
    }

    notifyListeners();
  }

  // Future<void> getRealtimePrices() async {
  //   _marketPriceState = ViewState.loading;
  //   notifyListeners();

  //   try {
  //     await ProductService.initializeSocketConnection();
  //     ProductService.marketDataStream.listen((data) {
  //       updateMarketData(data);
  //     });
  //   } catch (e) {
  //     log('Error getting realtime prices: ${e.toString()}');
  //   } finally {
  //     _marketPriceState = ViewState.idle;
  //     notifyListeners();
  //   }
  // }

  void getSpotRate() async {
    _goldSpotRate = await ProductService.getSpotRate();
    notifyListeners();
  }

  Future<void> checkGuestMode() async {
    try {
      _isGuest = await LocalStorage.getBool('isGuest') ?? false;
      log('Guest mode: $_isGuest');
    } catch (e) {
      log('Error checking guest mode: ${e.toString()}');
      _isGuest = false;
    }
    notifyListeners();
  }
  // Map<int, int> productQuantities = {};

// Method to update product quantities
// void updateProductQuantities(Map<int, int> quantities) {
//   productQuantities = quantities;
//   notifyListeners();
// }

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

  // checkGuestMode() async {
  //   _isGuest = await LocalStorage.getBool('isGuest');
  //   notifyListeners();
  // }

  // Future<void> listProducts(Map<String, dynamic> payload) async {
  //   setState(ViewState.loading);
  //   _productModel = await ProductService.listProducts(payload);
  //   _productList.clear();

  //   if (_productModel != null) {
  //     _productList.addAll(_productModel!.data);
  //   }

  //   setState(ViewState.idle);
  //   notifyListeners();
  // }

  // Future<void> loadMoreProducts(Map<String, dynamic> payload) async {
  //   try {
  //     if (_productModel!.page!.currentPage < _productModel!.page!.totalPage) {
  //       setState(ViewState.loadingMore); // Optional: track loading more state
  //       _productModel = await ProductService.listProducts(payload);
  //       _productList.addAll(_productModel!.data);
  //       setState(ViewState.idle); // Reset state
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     // log(e.toString());
  //   } finally {
  //     setState(ViewState.idle); // Reset state
  //   }
  // }

  // Simplified product fetch method with proper error handling
//  class ProductViewModel extends BaseModel {
  // Existing properties...
  
  // Add a flag to prevent duplicate fetches in progress
  bool _fetchInProgress = false;

  // Modified fetch method to prevent duplicate calls
Future<void> fetchProducts([String? adminId, String? categoryId, String pageIndex = "0"]) async {
  // Skip if a fetch is already in progress
  if (_fetchInProgress) {
    log('Fetch already in progress, skipping duplicate request');
    return;
  }
  
  _fetchInProgress = true;
  
  // Set appropriate state based on whether this is first page or pagination
  if (pageIndex == "0") {
    setState(ViewState.loading);
    _productList.clear();
    hasMoreData = true;
  } else {
    setState(ViewState.loadingMore);
  }
  
  isLoading = true;
  
  try {
    // Use provided IDs or fall back to stored IDs
    final String finalAdminId = adminId ?? _adminId ?? '';
    final String finalCategoryId = categoryId ?? _categoryId ?? '';
    
    log('Fetching products with adminId: $finalAdminId, categoryId: $finalCategoryId, page: $pageIndex');
    
    final productsData = await ProductService.fetchProducts(finalAdminId, finalCategoryId);
    log('API returned ${productsData.length} products');
    
    if (productsData is List) {
      // Only clear products if this is the first page
      if (pageIndex == "0") {
        _productList.clear();
      }
      
      // Parse products and add to list
      for (var item in productsData) {
        try {
          final product = Product.fromJson(item);
          _productList.add(product);
        } catch (e) {
          log('Error parsing product: ${e.toString()}');
        }
      }
      
      _productModel = ProductModel(
        success: _productList.isNotEmpty,
        data: List.from(_productList),
        page: Page(currentPage: int.parse(pageIndex), totalPage: productsData.isNotEmpty ? 2 : 1),
      );
      
      hasMoreData = _productModel!.page!.currentPage < _productModel!.page!.totalPage;
    } else {
      log('API returned unexpected data format');
      hasMoreData = false;
    }
  } catch (e) {
    log('Error fetching products: ${e.toString()}');
    hasMoreData = false;
  } finally {
    setState(ViewState.idle);
    isLoading = false;
    _fetchInProgress = false;
    notifyListeners();
    }
  }
}

  // @override
  // void dispose() {
  //   ProductService.dispose();
  //   super.dispose();
  // }
// }