class ProductModel {
  final List<Product> data;
  final Pagination? page;

  ProductModel({
    required this.data,
    this.page,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      data: List<Product>.from(
        json['info'].map(
          (data) => Product.fromJson(data),
        ),
      ),
      page: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Pagination {
  final num totalCount;
  final num totalPage;
  final num currentPage;

  Pagination(
      {required this.currentPage,
      required this.totalCount,
      required this.totalPage});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
        currentPage: json['currentPage'],
        totalCount: json['totalCount'],
        totalPage: json['totalPages']);
  }
}

class Product {
  final String pId;
  final String title;
  final num price;
  final bool stock;
  final num makingCharge;
  final String type;
  final String tags;
  final String desc;
  final num weight;
  final num purity;
  final List<String> prodImgs;

  Product(
      {required this.pId,
      required this.title,
      required this.price,
      required this.stock,
      required this.type,
      required this.desc,
      required this.prodImgs,
      required this.makingCharge,
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
      makingCharge: json['makingCharge'],
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
