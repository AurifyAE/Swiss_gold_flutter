import 'dart:developer';

import 'package:swiss_gold/core/models/market_model.dart';
import 'package:swiss_gold/core/models/prodcuts/product_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class ProductViewModel extends BaseModel {
  ProductModel? _topRatedModel;
  ProductModel? get topRatedModel => _topRatedModel;
  ProductModel? _newArrivalModel;
  ProductModel? get newArrivalModel => _newArrivalModel;
  ProductModel? _bestSellerModel;
  ProductModel? get bestSellerModel => _bestSellerModel;
  ViewState _topRatedState = ViewState.idle;
  ViewState get topRatedState => _topRatedState;
  ViewState _newArrivalState = ViewState.idle;
  ViewState get newArrivalState => _newArrivalState;
  ViewState _bestSellerState = ViewState.idle;
  ViewState get bestSellerState => _bestSellerState;
  List<Product> _productList = [];
  List<Product> get productList => _productList;
  ProductModel? _productModel;
  bool? _isGuest;
  bool? get isGuest => _isGuest;

  ViewState _marketPriceState = ViewState.idle;
  ViewState get marketPriceState => _marketPriceState;

  MarketModel? _marketModel;
  MarketModel? get marketModel => _marketModel;

  List<String> _banners = [];
  List<String> get banners => _banners;

  ViewState _bannerState = ViewState.idle;
  ViewState get bannerState => _bannerState;

  Future<void> getToprated() async {
    _topRatedState = ViewState.loading;
    notifyListeners();
    _topRatedModel = await ProductService.showTopRated();
    _topRatedState = ViewState.idle;
    notifyListeners();
  }

  Future<void> getBanners() async {
    _bannerState = ViewState.loading;
    notifyListeners();
    _banners = await ProductService.getBanner();
    _bannerState = ViewState.idle;
    notifyListeners();
  }

  Future<void> getNewArrival() async {
    _newArrivalState = ViewState.loading;
    notifyListeners();
    _newArrivalModel = await ProductService.showNewArrival();
    _newArrivalState = ViewState.idle;

    notifyListeners();
  }

  Future<void> getBestSeller() async {
    _bestSellerState = ViewState.loading;
    notifyListeners();
    _bestSellerModel = await ProductService.showBestSeller();
    _bestSellerState = ViewState.idle;

    notifyListeners();
  }

  Future<void> listProductsFromTag(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    _productModel = await ProductService.listProductsFromTag(payload);

    _productList.addAll(_productModel!.data);

    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> getRealtimePrices() async {
    _marketPriceState = ViewState.loading;
    notifyListeners();

    await ProductService.initializeSocketConnection((MarketModel marketData) {
      // When data is received, update the marketData and notify listeners
      _marketModel = marketData;
      notifyListeners();
      log('from viewmodel ${_marketModel!.symbol.toString()} ${_marketModel!.bid.toString()}');
    });

    _marketPriceState = ViewState.idle;
    notifyListeners();
  }

  checkGuestMode() async {
    _isGuest = await LocalStorage.getBool('isGuest');
    notifyListeners();
  }

  Future<void> listProductsFromCategory(Map<String, dynamic> payload) async {
    setState(ViewState.loading);
    _productModel = await ProductService.listProductsFromCategory(payload);

    _productList.addAll(_productModel!.data);

    // log(_productList.toString());
    setState(ViewState.idle);
    notifyListeners();
  }
}
