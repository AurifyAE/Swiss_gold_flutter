import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';

class WishCard extends StatelessWidget {
  final String prodImg;
  final String price;
  final String prodTitle;
  final void Function()? onRemoveTapped;

  const WishCard({
    super.key,
    required this.prodImg,
    required this.price,
    required this.prodTitle,
    this.onRemoveTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: UIColor.gold,
        ),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12.sp),
              child: CachedNetworkImage(
                imageUrl: prodImg,
                width: 80.w,
              )),
          SizedBox(
            width: 10.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${prodTitle.toString().length > 16 ? prodTitle.toString().substring(0, 16) : prodTitle}..',
                style: TextStyle(
                  color: UIColor.gold,
                  fontSize: 16.sp,
                  fontFamily: 'Familiar',
                ),
              ),
              SizedBox(height: 5.h,),
              Text(
                price,
                style: TextStyle(
                  color: UIColor.gold,
                  fontSize: 16.sp,
                  fontFamily: 'Familiar',
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
            ],
          ),
          Spacer(),
          CustomOutlinedBtn(
            borderRadius: 22.sp,
            borderColor: UIColor.gold,
            padH: 12.w,
            padV: 5.h,
            onTapped: onRemoveTapped,
            btnText: 'Remove',
            btnTextColor: UIColor.gold,
          )
        ],
      ),
    );
  }
}
