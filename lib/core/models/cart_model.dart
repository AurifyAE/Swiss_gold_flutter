class CartModel {
  final bool success;
  final String message;
  final List<CartInfo> data;

  CartModel({required this.success, required this.message, required this.data});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      success: json['success'],
      message: json['message'],
      data: (json['info'] as List).map((data) => CartInfo.fromJson(data)).toList(),
    );
  }
}

class CartInfo {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final String updatedAt;

  CartInfo({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.updatedAt,
  });

  factory CartInfo.fromJson(Map<String, dynamic> json) {
    return CartInfo(
      id: json['_id'],
      userId: json['userId'],
      items: (json['items'] as List).map((i) => CartItem.fromJson(i)).toList(),
      totalPrice: json['totalPrice'].toDouble(),
      updatedAt: json['updatedAt'],
    );
  }
}

class CartItem {
  final String productId;
  int quantity;
  final ProductDetails productDetails;
  final double itemTotal;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.productDetails,
    required this.itemTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'],
      productDetails: ProductDetails.fromJson(json['productDetails']),
      itemTotal: json['itemTotal'].toDouble(),
    );
  }
}

class ProductDetails {
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final double purity;
  final String sku;
  final String type;
  final String tags;
  final double weight;
  final String subCategory;
  final String mainCategory;

  ProductDetails({
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.purity,
    required this.sku,
    required this.type,
    required this.tags,
    required this.weight,
    required this.subCategory,
    required this.mainCategory,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      title: json['title'],
      description: json['description'],
      images: List<String>.from(json['images']),
      price: json['price'].toDouble(),
      purity: json['purity'].toDouble(),
      sku: json['sku'],
      type: json['type'],
      tags: json['tags'],
      weight: json['weight'].toDouble(),
      subCategory: json['subCategory'],
      mainCategory: json['mainCategory'],
    );
  }
}
