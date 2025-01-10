class UserModel {
  final String message;
  final bool success;
  final String? userId;

  UserModel(
      {required this.message, required this.success, this.userId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        message: json['message'],
        success: json['success'],
        userId: json['_id']);
  }

  factory UserModel.withError(Map<String, dynamic> json) {
    return UserModel(
      message: json['message'],
      success: json['success'],
    );
  }
}
