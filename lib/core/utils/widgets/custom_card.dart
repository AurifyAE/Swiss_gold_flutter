import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';

class CustomCard extends StatelessWidget {
  final String prodImg;
  final String title;
  final String price;
  final String? subTitle;
  final int quantity;
  final void Function()? onTap;
  final void Function()? onIncrement;
  final void Function()? onDecrement;
  final void Function()? onAddToCart;
  const CustomCard(
      {super.key,
      required this.prodImg,
      required this.quantity,
      required this.title,
      required this.price,
      this.subTitle,
      this.onTap,
      this.onIncrement,
      this.onDecrement,
      this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    List<String> priceParts = price.split('.');

    String integerPart = priceParts[0];
    String decimalPart = priceParts.length > 1 ? priceParts[1] : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: UIColor.gold),
            borderRadius: BorderRadius.circular(22.sp)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center(
              //   child: ClipRRect(
              //       borderRadius: BorderRadius.circular(12.sp),
              //       child: CachedNetworkImage(
              //         imageUrl: prodImg,
              //         progressIndicatorBuilder: (context, url, progress) =>
              //             CategoryShimmer(
              //           height: 100.h,
              //           width: 100.w,
              //         ),
              //         fit: BoxFit.cover,
              //         height: 100.h,
              //         width: 100.w,
              //       )),
              // ),
              // SizedBox(
              //   height: 20.h,
              // ),
              Text(
                title,
                overflow: TextOverflow.visible,
                maxLines: null,
                style: TextStyle(
                    color: UIColor.gold,
                    fontFamily: 'Familiar',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),

              // SizedBox(
              //   height: 20.h,
              // ),

              // RichText(
              //   text: TextSpan(
              //     children: [
              //       TextSpan(
              //         text: integerPart,
              //         style: TextStyle(
              //           color: UIColor.gold,
              //           fontFamily: 'Familiar',

              //           fontWeight: FontWeight.bold,
              //           fontSize: 16.sp, // Regular font size
              //         ),
              //       ),
              //       TextSpan(
              //         text: '.$decimalPart',
              //         style: TextStyle(
              //           fontFamily: 'Familiar',

              //           fontWeight: FontWeight.bold,
              //           color: UIColor.gold,
              //           fontSize:
              //               14.sp, // Smaller font size for the decimal part
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Spacer(),

              Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: onDecrement,
                    child: CircleAvatar(
                        radius: 21.sp,
                        backgroundColor: UIColor.gold,
                        child: Icon(
                          Icons.remove,
                          color: UIColor.black,
                          size: 25.sp,
                        )),
                  ),
                  // SizedBox(
                  //   width: 10.w,
                  // ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(
                      color: UIColor.gold,
                      fontSize: 26.sp,
                    ),
                  ),
                  // SizedBox(
                  //   width: 10.w,
                  // ),
                  GestureDetector(
                    
                    onTap: onIncrement,
                    child: CircleAvatar(
                        radius: 21.sp,
                        backgroundColor: UIColor.gold,
                        child: Icon(
                          Icons.add,
                          color: UIColor.black,
                          size: 25.sp,
                        )),
                  ), 
                ],
              ),
              // SizedBox(
              //   height: 10.h,
              // ),
              // GestureDetector(
              //   onTap: onAddToCart,
              //   child: Container(
              //     width: double.infinity,
              //     padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
              //     decoration: BoxDecoration(
              //         color: UIColor.gold,
              //         borderRadius: BorderRadius.circular(8.sp)),
              //     child: Text(
              //       'Add to cart',
              //       textAlign: TextAlign.center,
              //       style: TextStyle(
              //         fontFamily: 'Familiar',

              //         fontWeight: FontWeight.bold,
              //         color: UIColor.black,
              //         fontSize: 14.sp, // Smaller font size for the decimal part
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
