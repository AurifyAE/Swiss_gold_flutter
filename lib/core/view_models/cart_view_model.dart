import 'dart:developer';

import 'package:swiss_gold/core/models/cart_model.dart';
import 'package:swiss_gold/core/models/message.dart';
import 'package:swiss_gold/core/services/cart_service.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class CartViewModel extends BaseModel {
  bool? _isGuest;
  bool? get isGuest => _isGuest;

  CartModel? _cartModel;
  CartModel? get cartModel => _cartModel;

  ViewState? _quantityState;
  ViewState? get quantityState => _quantityState;

  final List<CartItem> _cartItemList = [];
  List<CartItem> get cartList => _cartItemList;

  MessageModel? _messageModel;
  MessageModel? get messageModel => _messageModel;

  Future<void> getCart() async {
    setState(ViewState.loading);
    _cartModel = await CartService.getCart();
    _cartItemList.clear();

    if (_cartModel != null) {
      for (var cartItem in cartModel!.data) {
        for (var item in cartItem.items) {
          _cartItemList.add(item);
        }
      }
    }

    setState(ViewState.idle);
    notifyListeners();
  }

  Future<void> updatePrice() async {
    _cartModel = await CartService.getCart();
    _cartItemList.clear();

    for (var cartItem in cartModel!.data) {
      for (var item in cartItem.items) {
        _cartItemList.add(item);
      }
    }

    notifyListeners();
  }

  Future<MessageModel?> updateQuantityFromHome(String pId,
      Map<String, dynamic> payload) async {
    log('payload from view model $payload');
    setState(ViewState.loading);
    _messageModel = await CartService.updateQuantityFromHome(pId,payload);

    setState(ViewState.idle);
    notifyListeners();

    return _messageModel;
  }

  Future<void> checkGuestMode() async {
    _isGuest = await LocalStorage.getBool('isGuest');
    notifyListeners();
  }

  Future<void> confirmQuantity(bool action) async {
    CartService.confirmQuantity({'action': action});
  }

  Future<MessageModel?> deleteFromCart(Map<String, dynamic> payload) async {
    _messageModel = await CartService.deleteFromCart(payload);
    notifyListeners();
    return _messageModel;
  }

  // Future<MessageModel?> addToCart(Map<String, dynamic> payload) async {
  //   setState(ViewState.loading);
  //   _messageModel = await CartService.addToCart(payload);
  //   setState(ViewState.idle);
  //   notifyListeners();
  //   return _messageModel;
  // }

Future incrementQuantity(Map<String, dynamic> payload, {index}) async {
  _quantityState = ViewState.loading;
  notifyListeners();
  _messageModel = await CartService.incrementQuantity(payload);
  
  // Add null check before accessing _messageModel!.success
  if (_messageModel != null && _messageModel!.success == true && index != null) {
    _cartItemList[index].quantity = _cartItemList[index].quantity + 1;
  }

  _quantityState = ViewState.idle;
  notifyListeners();
  return _messageModel; // Return the message model for proper error handling
}

Future decrementQuantity(Map<String, dynamic> payload, {index}) async {
  _quantityState = ViewState.loading;
  notifyListeners();
  _messageModel = await CartService.decrementQuantity(payload);
  
  // Add null check before accessing _messageModel!.success
  if (_messageModel != null && _messageModel!.success == true && index != null) {
    _cartItemList[index].quantity = _cartItemList[index].quantity - 1;
  }
  
  _quantityState = ViewState.idle;
  notifyListeners();
  return _messageModel;
}
}
