import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/models/product_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';

class DeliveryDetailsView extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final Function(Map<String, dynamic>) onConfirm;

  const DeliveryDetailsView({
    Key? key,
    required this.orderData,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<DeliveryDetailsView> createState() => _DeliveryDetailsViewState();
}

class _DeliveryDetailsViewState extends State<DeliveryDetailsView> {
  // Calculate total weight from booking data with real product weights
  double calculateTotalWeight(ProductViewModel productViewModel) {
    double totalWeight = 0.0;
    List bookingData = widget.orderData["bookingData"] as List;
    
    for (var item in bookingData) {
      String productId = item["productId"];
      int quantity = item["quantity"] ?? 1;
      
      // Find product in product list by ID
      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
        // orElse: () => null,
      );
      
      if (product != null) {
        // Use real product weight from the product model
        double productWeight = product.weight.toDouble();
        totalWeight += productWeight * quantity;
      }
    }
    
    return totalWeight;
  }

  // Calculate total amount for cash payment using product price directly
  double calculateTotalAmount(ProductViewModel productViewModel) {
    double totalAmount = 0.0;
    List bookingData = widget.orderData["bookingData"] as List;
    
    for (var item in bookingData) {
      String productId = item["productId"];
      int quantity = item["quantity"] ?? 1;
      
      // Find product in product list by ID
      Product? product = productViewModel.productList.firstWhere(
        (p) => p.pId == productId,
        // orElse: () => null,
      );
      
      if (product != null) {
        // Use product price directly instead of calculating from gold rate
        double productPrice = product.price.toDouble();
        double makingCharge = product.makingCharge.toDouble();
        
        // Add product price + making charge
        double productTotal = productPrice + makingCharge;
        totalAmount += productTotal * quantity;
      }
    }
    
    // Apply discount/premium based on payment method
    if (widget.orderData["paymentMethod"] != 'Gold' && 
        widget.orderData.containsKey('discount')) {
      String discountStr = widget.orderData['discount'] ?? '0';
      double discount = double.tryParse(discountStr) ?? 0.0;
      totalAmount -= discount;
    }
    
    if (widget.orderData["paymentMethod"] == 'Gold' && 
        widget.orderData.containsKey('premium')) {
      String premiumStr = widget.orderData['premium'] ?? '0';
      double premium = double.tryParse(premiumStr) ?? 0.0;
      totalAmount += premium;
    }
    
    return totalAmount > 0 ? totalAmount : 0.0;
  }

  // Get product details by ID
  Product? getProductById(String productId, ProductViewModel productViewModel) {
    try {
      return productViewModel.productList.firstWhere((p) => p.pId == productId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    
    final isGoldPayment = widget.orderData["paymentMethod"] == 'Gold';
    final totalWeight = calculateTotalWeight(productViewModel);
    final totalAmount = calculateTotalAmount(productViewModel);
    
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
              
              // Display important information based on payment method
              if (isGoldPayment)
                // Gold Payment Display
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
                        'Total Gold: ${totalWeight.toStringAsFixed(2)} g',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Cash Payment Display
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
                        'Total Amount: AED ${totalAmount.toStringAsFixed(2)}',
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
              
              // Order details card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: UIColor.gold),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment method
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
                    
                    // Delivery date
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
                    
                    // Total items
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
                    
                    // Show total gold weight only for Gold payment
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
                            '${totalWeight.toStringAsFixed(2)} g',
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
                    
                    // Show total amount only for Cash payment
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
                            'AED ${totalAmount.toStringAsFixed(2)}',
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
                    
                    // Show any applicable discount for cash payment
                    if (!isGoldPayment && widget.orderData.containsKey('discount')) ...[
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
                            'AED ${widget.orderData['discount']}',
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
                    
                    // Show any applicable premium for gold payment
                    if (isGoldPayment && widget.orderData.containsKey('premium')) ...[
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
                            'AED ${widget.orderData['premium']}',
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
              
              // Product details section
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
              
              // Product list with more details
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: (widget.orderData["bookingData"] as List).length,
                itemBuilder: (context, index) {
                  final item = (widget.orderData["bookingData"] as List)[index];
                  final productId = item["productId"];
                  final quantity = item["quantity"] ?? 1;
                  
                  // Get actual product info
                  final product = getProductById(productId, productViewModel);
                  final productWeight = product?.weight.toDouble() ?? 0.0;
                  final productPrice = product?.price.toDouble() ?? 0.0;
                  final makingCharge = product?.makingCharge.toDouble() ?? 0.0;
                  final productTitle = product?.title ?? 'Product #$productId';
                  
                  // Calculate cost using product price directly
                  final itemValue = (productPrice * quantity) + (makingCharge * quantity);
                  
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
                              '${productWeight.toStringAsFixed(2)} g',
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
                              '${(productWeight * quantity).toStringAsFixed(2)} g',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Show unit price from product model
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
                              'AED ${productPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontFamily: 'Familiar',
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        // Making charge
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
                                'AED ${makingCharge.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Show per-item cash value only for Cash payment
                        if (!isGoldPayment) ...[
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
                                'AED ${itemValue.toStringAsFixed(2)}',
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
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 30.h),
              
              // Summary card with display relevant to payment method
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: isGoldPayment ? UIColor.gold.withOpacity(0.15) : UIColor.gold.withOpacity(0.1),
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
                    
                    // For Gold payment, show total gold weight prominently
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
                            '${totalWeight.toStringAsFixed(2)} g',
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
                    
                    // For Cash payment, show total cash amount prominently
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
                            'AED ${totalAmount.toStringAsFixed(2)}',
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
              
              // Confirm button
              Center(
                child: CustomOutlinedBtn(
                  borderRadius: 12.sp,
                  borderColor: UIColor.gold,
                  padH: 12.w,
                  padV: 12.h,
                  width: 200.w,
                  onTapped: () {
                    // Call the onConfirm callback with an empty map
                    widget.onConfirm({});
                    
                    // Reset product quantities in the ProductViewModel
                    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
                    productViewModel.clearQuantities();
                    
                    Navigator.pop(context);
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