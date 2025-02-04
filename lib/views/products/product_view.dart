import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/view_models/wishlist_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';

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

class _ProductViewState extends State<ProductView> {
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
  DateTime? selectedDate;
  final PageController pageController = PageController();
  final PageController pageController2 = PageController();

  Future<void> selectDate() async {
    selectedDate = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              primaryColor: UIColor.gold,
              colorScheme: ColorScheme.dark(
                onPrimary: UIColor.black, // header text color
                onSurface: UIColor.gold, // body text color
              ),
            ),
            child: Material(
              child: Container(
                color: UIColor.black,
                child: Column(
                  children: [
                    StatefulBuilder(
                        builder: (context, setState) => Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    value: 'Gold',
                                    groupValue: selectedValue,
                                    activeColor: UIColor.gold,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value!;
                                      });
                                    },
                                    title: Text(
                                      'Gold',
                                      style: TextStyle(
                                        fontFamily: 'Familiar',
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    value: 'Cash',
                                    activeColor: UIColor.gold,
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value!;
                                      });
                                    },
                                    title: Text(
                                      'Cash',
                                      style: TextStyle(
                                        fontFamily: 'Familiar',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                    child!,
                  ],
                ),
              ),
            ),
          );
        },
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
  }

  @override
  void initState() {
    super.initState();
    context.read<ProductViewModel>().getSpotRate();
    ProductService.marketDataStream.listen((marketData) {
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
    context.read<ProductViewModel>().checkGuestMode();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: CustomOutlinedBtn(
                    btnText: 'Add to Cart',
                    btnTextColor: UIColor.gold,
                    borderColor: UIColor.gold,
                    borderRadius: 12.sp,
                    iconColor: UIColor.gold,
                    padH: 10.w,
                    padV: 14.h,
                    onTapped: () {
                      if (context.read<ProductViewModel>().isGuest == false) {
                        context.read<CartViewModel>().addToCart({
                          'pId': widget.pId,
                        }).then((response) {
                          customSnackBar(
                              context: context,
                              width: 200.w,
                              bgColor: UIColor.gold,
                              title: response!.message.toString());
                        });
                      } else {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginView()),
                            (route) => false);
                      }
                    }),
              ),
              SizedBox(
                width: 40.w,
              ),
              Flexible(
                child: CustomOutlinedBtn(
                    btnText: 'Add to wishlist',
                    btnTextColor: UIColor.gold,
                    borderColor: UIColor.gold,
                    borderRadius: 12.sp,
                    padH: 10.w,
                    padV: 14.h,
                    onTapped: () {
                      if (context.read<ProductViewModel>().isGuest == false) {
                        context.read<WishlistViewModel>().addToWishlist(
                            {'pId': widget.pId}).then((response) {
                          customSnackBar(
                              context: context,
                              width: 200.w,
                              bgColor: UIColor.gold,
                              title: response!.message.toString());
                        });
                      } else {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginView()),
                            (route) => false);
                      }
                    }),
              )
            ],
          ),
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
                Consumer<ProductViewModel>(builder: (context, model, child) {
                  String priceToShow = widget.type.toLowerCase() == 'gold'
                      ? goldPrice.toStringAsFixed(2)
                      : '';

                  List<String> priceParts = priceToShow.split('.');
                  String integerPart = priceParts[0];
                  String decimalPart =
                      priceParts.length > 1 ? priceParts[1] : '';

                  goldPrice =
                      (((goldBid + model.goldSpotRate!.toDouble()) / 31.103) *
                              3.674 *
                              widget.weight *
                              widget.purity /
                              pow(10, widget.purity.toString().length) +
                          widget.makingCharge);

                  return RichText(
                      text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'AED $integerPart',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontFamily: 'Familiar',
                          fontSize: 19.sp,
                        ),
                      ),
                      TextSpan(
                        text: '.$decimalPart',
                        style: TextStyle(
                          color: UIColor.gold,
                          fontSize: 14.sp, // Smaller size for the decimal part
                        ),
                      ),
                    ],
                  ));
                }),
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
               page2Index==0? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Column(
                    children: [
                      Text(
                        widget.desc,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: UIColor.gold,
                          fontSize: 15.sp,
                          fontFamily: 'Familiar',
                        ),
                      ),
                        Text(
                        widget.desc,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: UIColor.gold,
                          fontSize: 15.sp,
                          fontFamily: 'Familiar',
                        ),
                      ),
                        Text(
                        widget.desc,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: UIColor.gold,
                          fontSize: 15.sp,
                          fontFamily: 'Familiar',
                        ),
                      ),
                        Text(
                        widget.desc,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: UIColor.gold,
                          fontSize: 15.sp,
                          fontFamily: 'Familiar',
                        ),
                      ),
                    ],
                  ),
                ):
                Padding(
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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal),
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
                                fontWeight: FontWeight.normal),
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
}
