class OrderModel {
  final bool success;
  final String message;
  final List<OrderData> data;
  final Pagination? pagination;

  OrderModel({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      data: json['data'] != null
          ? List<OrderData>.from(
              json['data'].map((x) => OrderData.fromJson(x)),
            )
          : [],
    );
  }
}

class OrderData {
  final String id;
  final num totalPrice;
  final String? pricingOption;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final num? premiumAmount;
  final num? discountAmount;
  final String deliveryDate;
  final String transactionId;
  final String? orderRemark;
  final String orderDate;
  final List<Item> item;

  OrderData( {
    required this.id,
    required this.orderRemark,
    this.premiumAmount, this.discountAmount,
   this.pricingOption,
    required this.totalPrice,
   required this.paymentMethod,
    required this.orderStatus,
    required this.paymentStatus,
    required this.deliveryDate,
    required this.transactionId,
    required this.orderDate,
    required this.item,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['_id'],
      totalPrice: json['totalPrice'],
      orderRemark: json['orderRemark'],
      orderStatus: json['orderStatus'],
      paymentStatus: json['paymentStatus'],
      deliveryDate: json['deliveryDate'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      orderDate: json['orderDate'],
      item: json['items'] != null
          ? List<Item>.from(json['items'].map((x) => Item.fromJson(x)))
          : [], 

          premiumAmount: json['premiumAmount'],
          pricingOption: json['pricingOption'],
          discountAmount: json['discountAmount']

    );
  }
}

class Item {
  final String id;
  final String status;
  final int quantity;
  final ProductData? product;

  Item({
    required this.id,
    required this.status,
    required this.quantity,
    this.product,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? '',
      status: json['itemStatus'] ?? '',
      quantity: json['quantity'],
      product: json['product'] != null
          ? ProductData.fromJson(json['product'])
          : null,
    );
  }
}

class ProductData {
  final String title;
  final String type;
  final num price;
  final num purity;
  final num weight;
  final List<String> images;

  ProductData({
    required this.title,
    required this.type,
    required this.weight,
    required this.purity,
    required this.price,
    required this.images,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      price: json['price'] ?? '',
      purity: json['purity'] ?? '',
      weight: json['weight'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'].map((x) => x))
          : [],
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
        totalCount: json['totalOrders'],
        totalPage: json['totalPages']);
  }
}
