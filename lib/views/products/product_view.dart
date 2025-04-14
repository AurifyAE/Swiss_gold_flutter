// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_alert.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';

class ProductView extends StatefulWidget {
  final List<String> prodImg;
  final String title;
  final String desc;
  final String pId;
  final num purity;
  final num weight;
  final bool stock;
  final String type;
  final num makingCharge;
  const ProductView({
    super.key,
    required this.prodImg,
    required this.title,
    required this.desc,
    required this.pId,
    required this.purity,
    required this.weight,
    required this.stock,
    required this.type,
    required this.makingCharge,
  });

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  int page2Index = 0;
  double price = 0;
  double goldBid = 0;
  double silverBid = 0;
  double copperBid = 0;
  double platinumBid = 0;
  double goldPrice = 0;
  double silverPrice = 0;
  double platinumPrice = 0;
  double copperPrice = 0;
  String selectedValue = '';
  DateTime? selectedDate = DateTime.now();
  final PageController pageController = PageController();
  final PageController pageController2 = PageController();

  AnimationController? animationController;
  Animation<double>? animation;

  Future<void> selectDate(
      {String? paymentMethod, String? pricingOption, String? amount}) async {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Theme(
              data: Theme.of(context).copyWith(
                primaryColor: UIColor.gold,
                colorScheme: ColorScheme.dark(
                  onPrimary: UIColor.black, // header text color
                  onSurface: UIColor.gold, // body text color
                ),
              ),
              child: Material(
                child: Scaffold(
                  body: Container(
                    color: UIColor.black,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          'Select delivery date ',
                          style: TextStyle(
                              color: UIColor.gold,
                              fontFamily: 'Familiar',
                              fontSize: 17.sp,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          height: 50.h,
                        ),
                        CalendarDatePicker(
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            onDateChanged: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                            }),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: Row(
                            children: [
                              Text(
                                'Selected date : ',
                                style: TextStyle(
                                    color: UIColor.gold,
                                    fontFamily: 'Familiar',
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                selectedDate.toString().split(' ')[0],
                                style: TextStyle(
                                    color: UIColor.gold,
                                    fontFamily: 'Familiar',
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: Row(
                            children: [
                              CustomOutlinedBtn(
                                  borderRadius: 12.sp,
                                  fontSize: 18.sp,
                                  borderColor: UIColor.gold,
                                  padH: 4.w,
                                  padV: 8.h,
                                  width: 100.w,
                                  btnText: 'Cancel',
                                  btnTextColor: UIColor.gold,
                                  onTapped: () {
                                    Navigator.pop(context);
                                  }),
                              Spacer(),
                              CustomOutlinedBtn(
                                borderRadius: 12.sp,
                                width: 100.w,
                                fontSize: 18.sp,
                                borderColor: UIColor.gold,
                                padH: 4.w,
                                padV: 8.h,
                                onTapped: () {
                                  if (selectedDate != null) {
                                    Map<String, dynamic> finalPayload = {
                                      "bookingData": [
                                        {
                                          "productId": widget.pId,
                                          "quantity": 1,
                                        }
                                      ],
                                      "paymentMethod": selectedValue != 'Gold'
                                          ? paymentMethod
                                          : 'Gold',
                                      if (selectedValue != 'Gold')
                                        "pricingOption": pricingOption,
                                      "deliveryDate":
                                          selectedDate.toString().split(' ')[0]
                                    };

                                    if (selectedValue == 'Gold' &&
                                        (pricingOption == 'Premium')) {
                                      finalPayload['premium'] = amount;
                                    }
                                    if (selectedValue == 'Gold' &&
                                        (pricingOption == 'Discount')) {
                                      finalPayload['discount'] = amount;
                                    }
                                    context
                                        .read<ProductViewModel>()
                                        .bookProducts(finalPayload)
                                        .then((response) {
                                      if (response!.success == true) {
                                        Navigator.pop(context);
                                        selectedDate = null;
                                        selectedValue = '';
                                        customSnackBar(
                                            bgColor: UIColor.gold,
                                            titleColor: UIColor.white,
                                            width: 130.w,
                                            context: context,
                                            title: 'Booking success');

                                        Navigator.pop(context);
                                      } else {
                                        customSnackBar(
                                            bgColor: UIColor.gold,
                                            titleColor: UIColor.white,
                                            width: 130.w,
                                            context: context,
                                            title: 'Booking failed');
                                        Navigator.pop(context);
                                      }
                                    });
                                  } else {
                                    customSnackBar(
                                        context: context,
                                        bgColor: UIColor.gold,
                                        titleColor: UIColor.white,
                                        width: 200.w,
                                        title: 'Please choose a delivery date');
                                  }
                                },
                                btnTextColor: UIColor.gold,
                                btnText: 'Confirm',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
StreamSubscription? _marketDataSubscription;

@override
void initState() {
  super.initState();
  
  // Check if pricing data is already available before fetching
  final orderHistoryViewModel = context.read<OrderHistoryViewModel>();
  if (orderHistoryViewModel.cashPricingModel == null) {
    orderHistoryViewModel.getCashPricing('Cash');
  }
  
  if (orderHistoryViewModel.bankPricingModel == null) {
    orderHistoryViewModel.getBankPricing('Bank');
  }
  
  // Setup animation controller
  animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  
  animation = CurvedAnimation(
    parent: animationController!,
    curve: Curves.easeInOut,
  );
  
  // Get spot rate only if not already available
  final productViewModel = context.read<ProductViewModel>();
  if (productViewModel.goldSpotRate == null) {
    productViewModel.getSpotRate();
  }
  
  // Set up market data stream with proper subscription management
  _marketDataSubscription = ProductService.marketDataStream.listen((marketData) {
    // Store prices based on the symbol
    String symbol = marketData['symbol'].toString().toLowerCase();

    if (mounted) {
      // Check if the widget is still mounted
      if (symbol == 'gold') {
        setState(() {
          goldBid = (marketData['bid'] is int)
              ? (marketData['bid'] as int).toDouble()
              : marketData['bid'];
        });
      }
    }
  });
  
  // Check guest mode if needed, but only once
  if (productViewModel.isGuest == null) {
    productViewModel.checkGuestMode();
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: CustomOutlinedBtn(
              btnText: 'Order now',
              btnTextColor: UIColor.gold,
              borderColor: UIColor.gold,
              borderRadius: 12.sp,
              iconColor: UIColor.gold,
              padH: 10.w,
              padV: 14.h,
              onTapped: () {
               showAnimatedDialog2(
                      context,
                      animationController!,
                      animation!,
                      'Choose Your Payment Option',
                      'You can either pay using cash or opt for gold as your preferred payment method. Select an option to proceed',
                      [
                        SizedBox(
                          height: 30.h,
                        ),
                        CustomOutlinedBtn(
                          borderRadius: 12.sp,
                          borderColor: UIColor.gold,
                          padH: 12.w,
                          padV: 12.h,
                          onTapped: () {
                            selectedValue = 'Gold';

                            Navigator.pop(context);

                            selectDate();
                          },
                          btnTextColor: UIColor.gold,
                          btnText: 'Gold',
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            selectDate(paymentMethod: context.read<OrderHistoryViewModel>().cashPricingModel?.data.methodType,pricingOption: context.read<OrderHistoryViewModel>().cashPricingModel?.data.pricingType,amount: context.read<OrderHistoryViewModel>().cashPricingModel?.data.value.toString());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.sp),
                              border: Border.all(color: UIColor.gold),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Cash',
                                  style: TextStyle(
                                      fontFamily: 'Familiar',
                                      color: UIColor.gold,
                                      fontSize: 14.sp),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  '${context.read<OrderHistoryViewModel>().cashPricingModel?.data.pricingType} :  ${context.read<OrderHistoryViewModel>().cashPricingModel?.data.value}',
                                  style: TextStyle(
                                      fontFamily: 'Familiar',
                                      color: UIColor.gold,
                                      fontSize: 13.sp),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            selectDate(paymentMethod: context.read<OrderHistoryViewModel>().cashPricingModel?.data.methodType,pricingOption: context.read<OrderHistoryViewModel>().cashPricingModel?.data.pricingType,amount: context.read<OrderHistoryViewModel>().cashPricingModel?.data.value.toString());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.sp),
                              border: Border.all(color: UIColor.gold),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bank Transfer',
                                  style: TextStyle(
                                      fontFamily: 'Familiar',
                                      color: UIColor.gold,
                                      fontSize: 14.sp),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  '${context.read<OrderHistoryViewModel>().bankPricingModel?.data.pricingType} :  ${context.read<OrderHistoryViewModel>().bankPricingModel?.data.value}',
                                  style: TextStyle(
                                      fontFamily: 'Familiar',
                                      color: UIColor.gold,
                                      fontSize: 13.sp),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]);
              }),
        ),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: UIColor.gold,
              )),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 350.h,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    itemCount: widget.prodImg.length,
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22.sp),
                          child: CachedNetworkImage(
                            imageUrl: widget.prodImg[index],
                            height: 400.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  children: List.generate(
                      widget.prodImg.length,
                      (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                pageController.jumpToPage(index);
                              });
                            },
                            child: Container(
                                height: 50.h,
                                width: 50.w,
                                margin: EdgeInsets.only(right: 15.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: currentIndex == index
                                            ? UIColor.gold
                                            : UIColor.white),
                                    borderRadius: BorderRadius.circular(12.sp)),
                                child: CachedNetworkImage(
                                  imageUrl: widget.prodImg[index],
                                  fit: BoxFit.cover,
                                )),
                          )),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  widget.title,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: UIColor.gold,
                      fontFamily: 'Familiar',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.normal),
                ),
                SizedBox(
                  height: 10.h,
                ),
                // Consumer<ProductViewModel>(builder: (context, model, child) {
                //   String priceToShow = widget.type.toLowerCase() == 'gold'
                //       ? goldPrice.toStringAsFixed(2)
                //       : '';

                //   List<String> priceParts = priceToShow.split('.');
                //   String integerPart = priceParts[0];
                //   String decimalPart =
                //       priceParts.length > 1 ? priceParts[1] : '';

                //   goldPrice =
                //       (((goldBid + model.goldSpotRate!.toDouble()) / 31.103) *
                //               3.674 *
                //               widget.weight *
                //               widget.purity /
                //               pow(10, widget.purity.toString().length) +
                //           widget.makingCharge);

                //   return RichText(
                //       text: TextSpan(
                //     children: [
                //       TextSpan(
                //         text: 'AED $integerPart',
                //         style: TextStyle(
                //           color: UIColor.gold,
                //           fontFamily: 'Familiar',
                //           fontSize: 19.sp,
                //         ),
                //       ),
                //       TextSpan(
                //         text: '.$decimalPart',
                //         style: TextStyle(
                //           color: UIColor.gold,
                //           fontSize: 14.sp, // Smaller size for the decimal part
                //         ),
                //       ),
                //     ],
                //   ));
                // }),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: CustomOutlinedBtn(
                          btnText: 'Description',
                          btnTextColor:
                              page2Index == 0 ? UIColor.white : UIColor.gold,
                          bgColor: page2Index == 0
                              ? UIColor.gold
                              : Colors.transparent,
                          borderColor: UIColor.gold,
                          borderRadius: 12.sp,
                          height: 35.h,
                          iconColor: UIColor.gold,
                          padH: 14.w,
                          padV: 5.h,
                          onTapped: () {
                            setState(() {
                              page2Index = 0;
                            });
                          }),
                    ),
                    SizedBox(
                      width: 40.w,
                    ),
                    Flexible(
                      child: CustomOutlinedBtn(
                          btnText: 'Specification',
                          btnTextColor:
                              page2Index == 1 ? UIColor.white : UIColor.gold,
                          borderColor: UIColor.gold,
                          borderRadius: 12.sp,
                          bgColor: page2Index == 1
                              ? UIColor.gold
                              : Colors.transparent,
                          height: 35.h,
                          padH: 14.w,
                          padV: 5.h,
                          onTapped: () {
                            setState(() {
                              page2Index = 1;
                            });
                          }),
                    )
                  ],
                ),
                page2Index == 0
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          widget.desc,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 15.sp,
                            fontFamily: 'Familiar',
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Purity : ',
                                  style: TextStyle(
                                    color: UIColor.gold,
                                    fontFamily: 'Familiar',
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Text(
                                  widget.purity.toString(),
                                  style: TextStyle(
                                    color: UIColor.gold,
                                    fontFamily: 'Familiar',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Weight : ',
                                  style: TextStyle(
                                      color: UIColor.gold,
                                      fontFamily: 'Familiar',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.weight.toString(),
                                  style: TextStyle(
                                      color: UIColor.gold,
                                      fontFamily: 'Familiar',
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              widget.stock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
void dispose() {
  // Clean up resources
  _marketDataSubscription?.cancel();
  animationController?.dispose();
  super.dispose();
}
}
