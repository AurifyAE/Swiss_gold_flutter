class UserModel {
  final String message;
  final bool success;
  final String userId;

  UserModel({
    required this.message,
    required this.success,
    this.userId = '67f384f05038ae3d6fa621f6',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      message: json['message'],
      success: json['success'],
      userId: json['_id'] ?? '67f384f05038ae3d6fa621f6',
    );
  }

  factory UserModel.withError(Map<String, dynamic> json) {
    return UserModel(
      message: json['message'],
      success: json['success'],
      userId: '67f384f05038ae3d6fa621f6',
    );
  }
}
