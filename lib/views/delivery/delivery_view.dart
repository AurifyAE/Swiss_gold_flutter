// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/models/product_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/services/server_provider.dart';

import '../../core/utils/money_format_heper.dart';
import '../../core/utils/widgets/snakbar.dart';

class DeliveryDetailsView extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final Function(Map<String, dynamic>) onConfirm;

  const DeliveryDetailsView({
    super.key,
    required this.orderData,
    required this.onConfirm,
  });

  @override
  State<DeliveryDetailsView> createState() => _DeliveryDetailsViewState();
}

class _DeliveryDetailsViewState extends State<DeliveryDetailsView> {
  double calculateTotalWeight(ProductViewModel productViewModel) {
  double totalWeight = 0.0;
  List bookingData = widget.orderData["bookingData"] as List;
  
  dev.log("Starting total weight calculation...");

  for (var item in bookingData) {
    String productId = item["productId"];
    int quantity = item["quantity"] ?? 1;

    Product? product = productViewModel.productList.firstWhere(
      (p) => p.pId == productId,
    );

    double productWeight = product.weight.toDouble();
    totalWeight += productWeight * quantity;
    
    dev.log("Product $productId: weight=${productWeight}g × quantity=$quantity = ${productWeight * quantity}g");
  }

  dev.log("Final total weight calculation: ${totalWeight}g");
  return totalWeight;
}

double calculatePurityPower(dynamic purity) {
  String purityStr = purity.toString();
  int digitCount = purityStr.length;
  double powerOfTen = pow(10, digitCount).toDouble();
  double result = purity / powerOfTen;
  
  dev.log('🧮 Purity calculation: purity=$purity, digits=$digitCount, power=$powerOfTen, result=$result');
  return result;
}

  double calculateTotalAmount(
    ProductViewModel productViewModel, GoldRateProvider goldRateProvider) {
  double totalAmount = 0.0;
  List bookingData = widget.orderData["bookingData"] as List;
  
  dev.log("Starting total amount calculation...");

  double bidPrice = goldRateProvider.goldData != null
      ? (double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0) /
          31.103 *
          3.674
      : 0.0;
      
  dev.log("Current bid price: $bidPrice AED/g (conversion from troy oz)");

  for (var item in bookingData) {
    String productId = item["productId"];
    int quantity = item["quantity"] ?? 1;

    Product? product = productViewModel.productList.firstWhere(
      (p) => p.pId == productId,
    );

    double productPrice = 0.0;
    double purityFactor = calculatePurityPower(product.purity);

    productPrice = bidPrice * purityFactor * product.weight.toDouble();
    
    dev.log("Product $productId base calculation: bidPrice=$bidPrice × purityFactor=$purityFactor × weight=${product.weight.toDouble()}g = $productPrice AED");

    double makingCharge = product.makingCharge.toDouble();
    dev.log("Product $productId making charge: $makingCharge AED");

    double productTotal = productPrice * quantity;
    dev.log("Product $productId price × quantity($quantity): $productPrice × $quantity = $productTotal AED");

    if (makingCharge > 0) {
      productTotal += makingCharge * quantity;
      dev.log("Product $productId with making charge: $productTotal + (${makingCharge * quantity}) = ${productTotal + (makingCharge * quantity)} AED");
    }

    totalAmount += productTotal;
    dev.log("Running total after adding product $productId: $totalAmount AED");
  }

  if (widget.orderData.containsKey('premium')) {
    String premiumStr = widget.orderData['premium'] ?? '0';
    double premium = double.tryParse(premiumStr) ?? 0.0;
    totalAmount += premium;
    dev.log("Adding premium: $premium AED. New total: $totalAmount AED");
  }

  if (widget.orderData.containsKey('discount')) {
    String discountStr = widget.orderData['discount'] ?? '0';
    double discount = double.tryParse(discountStr) ?? 0.0;
    totalAmount -= discount;
    dev.log("Subtracting discount: $discount AED. New total: $totalAmount AED");
  }

  dev.log("Final total amount: ${totalAmount > 0 ? totalAmount : 0.0} AED");
  return totalAmount > 0 ? totalAmount : 0.0;
}

Product? getProductById(String productId, ProductViewModel productViewModel) {
  try {
    Product product = productViewModel.productList.firstWhere((p) => p.pId == productId);
    dev.log("Retrieved product ID: $productId - Title: ${product.title}, Weight: ${product.weight}g, Purity: ${product.purity}");
    return product;
  } catch (e) {
    dev.log("Failed to retrieve product ID: $productId - Error: ${e.toString()}");
    return null;
  }
}

@override
void initState() {
  super.initState();
  dev.log("Initializing DeliveryDetailsView");

  Future.microtask(() {
    final goldRateProvider =
        Provider.of<GoldRateProvider>(context, listen: false);
    if (!goldRateProvider.isConnected || goldRateProvider.goldData == null) {
      dev.log("Initializing gold rate connection - Current status: isConnected=${goldRateProvider.isConnected}, hasData=${goldRateProvider.goldData != null}");
      goldRateProvider.initializeConnection();
    } else {
      dev.log("Gold rate already connected - Current bid: ${goldRateProvider.goldData!['bid']}");
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final goldRateProvider = Provider.of<GoldRateProvider>(context);

    final isGoldPayment = widget.orderData["paymentMethod"] == 'Gold';
    final totalWeight = calculateTotalWeight(productViewModel);
    final totalAmount =
        calculateTotalAmount(productViewModel, goldRateProvider);

    dev.log("Payment method: ${isGoldPayment ? 'Gold' : 'Cash'}");
  dev.log("Total weight summary: $totalWeight g");
  dev.log("Total amount summary: $totalAmount AED");

    final bidPrice = goldRateProvider.goldData != null
        ? (double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0) /
            31.103 *
            3.674
        : 0.0;

    dev.log("Current bid price for display: $bidPrice AED/g");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Order Confirmation',
          style: TextStyle(
            color: UIColor.gold,
            fontFamily: 'Familiar',
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: UIColor.gold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              if (isGoldPayment)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: UIColor.gold),
                    color: UIColor.gold.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Gold Payment',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Total Gold: ${formatNumber(totalWeight)} g',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Bid Price: ${formatNumber(bidPrice)}',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: UIColor.gold),
                    color: UIColor.gold.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Cash Payment',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Live rate: ${bidPrice > 0 ? formatNumber(bidPrice) : "2,592.97"}',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Total Amount: AED ${formatNumber(totalAmount)}',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: UIColor.gold),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method:',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          widget.orderData["paymentMethod"] ?? 'Not specified',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Date:',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          widget.orderData["deliveryDate"] ?? 'Not specified',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          '${(widget.orderData["bookingData"] as List).length}',
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (isGoldPayment) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Gold Weight:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            '${formatNumber(totalWeight)} g',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gold Bid Price:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            bidPrice > 0 ? formatNumber(bidPrice) : 'N/A',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isGoldPayment) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            'AED ${formatNumber(totalAmount)}',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.orderData.containsKey('discount')) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount Applied:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            'AED ${double.tryParse(widget.orderData['discount'] ?? '0') != null ? formatNumber(double.parse(widget.orderData['discount'])) : widget.orderData['discount']}',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.orderData.containsKey('premium')) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Premium Applied:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            'AED ${double.tryParse(widget.orderData['premium'] ?? '0') != null ? formatNumber(double.parse(widget.orderData['premium'])) : widget.orderData['premium']}',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Product Details',
                style: TextStyle(
                  color: UIColor.gold,
                  fontFamily: 'Familiar',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: (widget.orderData["bookingData"] as List).length,
                itemBuilder: (context, index) {
                  final item = (widget.orderData["bookingData"] as List)[index];
  final productId = item["productId"];
  final quantity = item["quantity"] ?? 1;

  final product = getProductById(productId, productViewModel);
  final productWeight = product?.weight.toDouble() ?? 0.0;
  final productPurity = product?.purity.toDouble() ?? 0.0;
  final makingCharge = product?.makingCharge.toDouble() ?? 0.0;
  final productTitle = product?.title ?? 'Product #$productId';

  dev.log("Product #$index - ID: $productId, Title: $productTitle");
  dev.log("Product #$index - Weight: $productWeight g, Purity: $productPurity, Making Charge: $makingCharge AED");

  final purityFactor = calculatePurityPower(productPurity);
  dev.log("Product #$index - Purity factor: $purityFactor (calculated from $productPurity)");
  
  final basePrice = totalAmount;
  dev.log("Product #$index - Base price calculation: $bidPrice × $productWeight × $purityFactor = $basePrice AED");
  
  final itemValue = (totalAmount * quantity) + (makingCharge * quantity);
  dev.log("Product #$index - Item value: ($basePrice × $quantity) + ($makingCharge × $quantity) = $itemValue AED");

                      dev.log("Product #$index - Item value: ($basePrice × $quantity) + ($makingCharge × $quantity) = $itemValue AED");

                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: UIColor.gold.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productTitle,
                          style: TextStyle(
                            color: UIColor.gold,
                            fontFamily: 'Familiar',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weight per Unit:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              '${formatNumber(productWeight)} g',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Purity:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              '${formatNumber(productPurity)}K',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Weight:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              '${formatNumber(productWeight * quantity)} g',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Unit Price:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              'AED ${formatNumber(totalAmount)}',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        if (makingCharge > 0) ...[
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Making Charge:',
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                ),
                              ),
                              Text(
                                'AED ${formatNumber(makingCharge)}',
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Item Value:',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              'AED ${formatNumber(itemValue)}',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 30.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: isGoldPayment
                      ? UIColor.gold.withOpacity(0.15)
                      : UIColor.gold.withOpacity(0.1),
                  border: Border.all(color: UIColor.gold),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        color: UIColor.gold,
                        fontFamily: 'Familiar',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (isGoldPayment) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Gold Payment:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${formatNumber(totalWeight)} g',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'At Bid Price:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            bidPrice > 0 ? formatNumber(bidPrice) : 'N/A',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isGoldPayment) ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Cash Payment:',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'AED ${formatNumber(totalAmount)}',
                            style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              // Center(
              //   child: CustomOutlinedBtn(
              //     borderRadius: 12.sp,
              //     borderColor: UIColor.gold,
              //     padH: 12.w,
              //     padV: 12.h,
              //     width: 200.w,
              //     onTapped: () {
              //       widget.onConfirm({});

              //       final productViewModel =
              //           Provider.of<ProductViewModel>(context, listen: false);
              //       productViewModel.clearQuantities();

              //       Navigator.pop(context);
              //     },
              //     btnTextColor: UIColor.gold,
              //     btnText: 'Confirm Order',
              //   ),
              // ),

              Center(
                child: CustomOutlinedBtn(
                  borderRadius: 12.sp,
                  borderColor: UIColor.gold,
                  padH: 12.w,
                  padV: 12.h,
                  width: 200.w,
             onTapped: () async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(UIColor.gold),
        ),
      );
    },
  );
  
  try {
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
    final goldRateProvider = Provider.of<GoldRateProvider>(context, listen: false);
    
    // Get the latest gold price
    final double bidPrice = goldRateProvider.goldData != null
      ? (double.tryParse('${goldRateProvider.goldData!['bid']}') ?? 0.0) / 31.103 * 3.674
      : 0.0;

      dev.log("Final order submission - Current bid price: $bidPrice AED/g");
    
    // Create bookingData with fixed prices for each product
    List<Map<String, dynamic>> bookingDataWithFixedPrices = [];
    List bookingData = widget.orderData["bookingData"] as List;
    
     for (var item in bookingData) {
    String productId = item["productId"];
    int quantity = item["quantity"] ?? 1;
    
    Product product = productViewModel.productList.firstWhere(
      (p) => p.pId == productId,
    );
    
    // Calculate the fixed price for this product
    double productWeight = product.weight.toDouble();
    double productPurity = product.purity.toDouble();
    double purityFactor = calculatePurityPower(productPurity);
    double makingCharge = product.makingCharge.toDouble();
    
    dev.log("Order item - Product ID: $productId, Weight: $productWeight g, Purity: $productPurity, PurityFactor: $purityFactor, Making: $makingCharge AED");
    
    // Calculate base price using the current bid price
    double basePrice = bidPrice * purityFactor * productWeight;
    dev.log("Order item - Base price calculation: $bidPrice × $purityFactor × $productWeight = $basePrice AED");
    
    double fixedPrice = basePrice + makingCharge;
  dev.log("Order item - Fixed price: $basePrice + $makingCharge = $fixedPrice AED");
      //  orderTotal += fixedPrice * quantity;
      
      // Add to booking data with fixed price
      bookingDataWithFixedPrices.add({
        "productId": productId,
        "quantity": quantity,
        "fixedPrice": fixedPrice.round(),
      });
      dev.log("Order item - Final price (rounded): ${fixedPrice.round()} AED × $quantity");

    }
    // log("Order submission - Total value: $orderTotal AED");
    
    // Create payload for fixing the price
    Map<String, dynamic> fixPricePayload = {
      "bookingData": bookingDataWithFixedPrices,
      "goldRate": bidPrice,
    };
    
    dev.log("Fix price payload: ${jsonEncode(fixPricePayload)}");
    
    // Fix the price first
    final fixPriceResult = await productViewModel.fixPrice(fixPricePayload);
    
    if (fixPriceResult != null && fixPriceResult.success!) {
      // If price fixing is successful, proceed with booking
      // Create the final booking payload
      final bookingPayload = {
        ...widget.orderData,
        "bookingData": bookingDataWithFixedPrices, // Use the bookingData with fixed prices
        "goldRate": bidPrice,
        "fixedAt": DateTime.now().toIso8601String(),
      };
      
      // Book the products - ONLY MAKE THIS CALL ONCE
      final bookingResult = await productViewModel.bookProducts(bookingPayload);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (bookingResult != null && bookingResult.success!) {
        // CLEAR CART DATA HERE AFTER SUCCESSFUL BOOKING
        productViewModel.clearQuantities();
        
        // Call the function from HomeView to clear booking data
        widget.onConfirm({
          "success": true, 
          "bookingData": bookingResult
        });
        
        // Show success message
        showOrderStatusSnackBar(
          context: context,
          isSuccess: true,
          message: 'Booking success',
        );

        // Navigate back to previous screen
        Navigator.pop(context);
      } else {
        // Show error message
        showOrderStatusSnackBar(
          context: context,
          isSuccess: false,
          message: 'Booking failed',
        );
      }
    } else {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message for price fixing
       showOrderStatusSnackBar(
        context: context,
        isSuccess: false,
        message: 'Booking failed',
      );
    }
  } catch (e) {
    // Close loading dialog
    Navigator.of(context).pop();
    
    // Show general error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'An error occurred: ${e.toString()}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
},
                  btnTextColor: UIColor.gold,
                  btnText: 'Confirm Order',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
