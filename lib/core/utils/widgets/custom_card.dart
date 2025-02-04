import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';

class CustomCard extends StatelessWidget {
  final String prodImg;
  final String title;
  final String price;
  final String? subTitle;
  final void Function()? onTap;
  const CustomCard(
      {super.key,
      required this.prodImg,
      required this.title,
      required this.price,
      this.subTitle,
      this.onTap});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.sp),
                    child: CachedNetworkImage(
                      imageUrl: prodImg,
                      progressIndicatorBuilder: (context, url, progress) =>
                          CategoryShimmer(
                        height: 80.h,
                        width: 80.w,
                      ),
                      fit: BoxFit.cover,
                      height: 80.h,
                      width: 80.w,
                    )),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: UIColor.gold,
                    fontFamily: 'Familiar',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 4.h,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: integerPart,
                      style: TextStyle(
                        color: UIColor.gold,
                        fontFamily: 'Familiar',

                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp, // Regular font size
                      ),
                    ),
                    TextSpan(
                      text: '.$decimalPart',
                      style: TextStyle(
                        fontFamily: 'Familiar',

                        fontWeight: FontWeight.bold,
                        color: UIColor.gold,
                        fontSize:
                            12.sp, // Smaller font size for the decimal part
                      ),
                    ),
                  ],
                ),
              ),
              //  Text(
              //   subTitle??"",
              //   style: TextStyle(color: UIColor.gold, fontSize: 18.sp),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
