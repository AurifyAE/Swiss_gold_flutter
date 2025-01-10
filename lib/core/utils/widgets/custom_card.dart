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
      required this.price, this.subTitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: UIColor.gold),
            borderRadius: BorderRadius.circular(22.sp)),
        child: Padding(
          padding:  EdgeInsets.all(8.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(22.sp),
                  child: CachedNetworkImage(
                   imageUrl: prodImg,
                   progressIndicatorBuilder: (context, url, progress) => CategoryShimmer(width: double.infinity,height: 120.h,),
                    fit: BoxFit.contain,
                  )),
                  SizedBox(height: 10.h,),
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: UIColor.secondaryGold, fontSize: 18.sp,fontWeight: FontWeight.bold),
              ),
              Text(
                price,
                style: TextStyle(color: UIColor.gold, fontSize: 18.sp),
              ),
               Text(
                subTitle??"",
                style: TextStyle(color: UIColor.gold, fontSize: 18.sp),
              )
            ],
          ),
        ),
      ),
    );
  }
}
