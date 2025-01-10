class CategoryModel {
  final bool success;
  final List<Category> data;

  CategoryModel({required this.success, required this.data});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
        success: json['success'],
        data: List<Category>.from(
            json['data'].map((data) => Category.fromJson(data))));
  }
}

class Category {
  final String cId;
  final String cImg;
  final String name;

  Category({required this.cId, required this.cImg, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(cId: json['_id'], cImg: json['image'], name: json['name']);
  }
}
