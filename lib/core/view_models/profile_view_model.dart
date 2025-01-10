import 'dart:developer';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class ProfileViewModel extends BaseModel {
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  Future<void> getProfile() async {
    setState(ViewState.loading);

    try {
      // Fetch data from local storage
      final  userName = await LocalStorage.getString('userName') ?? "Guest";
      String category = await LocalStorage.getString('category') ?? "";
      String mobile = await LocalStorage.getString('mobile') ?? "";
      String location = await LocalStorage.getString('location') ?? "";
      log(userName);

      // Update the user model
      _userModel = UserModel(
        category: category,
        userName: userName,
        mobile: mobile,
        location: location,
      );

      log('User Profile: $_userModel');
    } catch (e) {
      log('Error fetching profile: $e');
    } finally {
      setState(ViewState.idle);
      notifyListeners();
    }
  }
}

class UserModel {
  final String userName;
  final String category;
  final String mobile;
  final String location;

  UserModel({
    required this.category,
    required this.userName,
    required this.mobile,
    required this.location,
  });

  @override
  String toString() {
    return 'UserModel(userName: $userName, category: $category, mobile: $mobile, location: $location)';
  }
}
