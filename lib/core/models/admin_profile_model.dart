class CompanyProfileModel {
  final String message;
  final bool success;
  final Data data;

  CompanyProfileModel({
    required this.message,
    required this.success,
    required this.data,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    return CompanyProfileModel(
      message: json['message'],
      success: json['success'],
      data: Data.fromJson(json['info']),
    );
  }
}

class Data {
  final String id;
  final String userName;
  final String companyName;
  final String address;
  final String email;
  final int contact;
  final int whatsapp;

  Data({
    required this.id,
    required this.userName,
    required this.companyName,
    required this.address,
    required this.email,
    required this.contact,
    required this.whatsapp,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['_id'],
      userName: json['userName'],
      companyName: json['companyName'],
      address: json['address'],
      email: json['email'],
      contact: json['contact'],
      whatsapp: json['whatsapp'],
    );
  }
}
