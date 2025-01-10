class ProductModel {
  final List<Product> data;

  ProductModel({required this.data});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      data: List<Product>.from(
        json['info'].map(
          (data) => Product.fromJson(data),
        ),
      ),
    );
  }
}

class Product {
  final String pId;
  final String title;
  final int price;
  final bool stock;
  final String type;
  final String tags;
  final String desc;
  final int weight;
  final int purity;
  final List<String> prodImgs;

  Product(
      {required this.pId,
      required this.title,
      required this.price,
      required this.stock,
      required this.type,
      required this.desc,
      required this.prodImgs,
      required this.weight, 
      required this.purity, 
      required this.tags});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      pId: json['_id'],
      title: json['title'],
      price: json['price'],
      stock: json['stock'],
      type: json['type'],
      desc: json['description'],
      tags: json['tags'],
      weight: json['weight'],
      purity: json['purity'],
      prodImgs: List<String>.from(
        json['images'].map(
          (data) => data.toString(),
        ),
      ),
    );
  }
}
