import 'dart:developer';

import 'package:swiss_gold/core/models/order_model.dart';
import 'package:swiss_gold/core/models/pricing_method_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/order_history.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class OrderHistoryViewModel extends BaseModel {
  OrderModel? _orderModel;
  OrderModel? get orderModel => _orderModel;

  PricingMethodModel? _bankPricingModel;
  PricingMethodModel? get bankPricingModel => _bankPricingModel;

   PricingMethodModel? _cashPricingModel;
  PricingMethodModel? get cashPricingModel => _cashPricingModel;

  ViewState? _moreHistoryState;
  ViewState? get moreHistoryState => _moreHistoryState;

  final List<OrderData> _allOrders = [];
  List<OrderData> get allOrders => _allOrders;

  bool? _isGuest;
  bool? get isGuest => _isGuest;

  Future<void> getOrderHistory(String index,String status) async {
    setState(ViewState.loading);
    _allOrders.clear();
    _orderModel = await OrderHistoryService.getOrderHistory(index,status);
    if (_orderModel != null) {
      _allOrders.addAll(_orderModel!.data);
    }
    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> getMoreOrderHistory(String index,String status) async {
    setState(ViewState.loadingMore);

    _orderModel = await OrderHistoryService.getOrderHistory(index,status);
    _allOrders.addAll(_orderModel!.data);
    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> getBankPricing(String type) async {
    _bankPricingModel = await OrderHistoryService.getPricing(type);

    notifyListeners();

  
  }

    Future<void> getCashPricing(String type) async {
    _cashPricingModel = await OrderHistoryService.getPricing(type);

    notifyListeners();

 
  }

  Future<void> checkGuestMode() async {
    _isGuest = await LocalStorage.getBool('isGuest');
    notifyListeners();
  }
}
