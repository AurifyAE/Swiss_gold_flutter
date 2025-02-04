import 'package:swiss_gold/core/models/order_model.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/services/order_history.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class OrderHistoryViewModel extends BaseModel {
  OrderModel? _orderModel;
  OrderModel? get orderModel => _orderModel;

    bool? _isGuest;
  bool? get isGuest => _isGuest;

  Future<void> getOrderHistory() async {
    setState(ViewState.loading);
    _orderModel = await OrderHistoryService.getOrderHistory();
    setState(ViewState.idle);
    notifyListeners();
  }

    Future<void> checkGuestMode() async {
    _isGuest = await LocalStorage.getBool('isGuest');
    notifyListeners();
  }
}
