import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';

class CartCard extends StatelessWidget {
  final String prodImg;
  final String price;
  final String prodTitle;
  final int quantity;
  final bool state;
  final void Function()? onDecrementTapped;
  final void Function()? onIncrementTapped;
  final void Function()? onRemoveTapped;

  const CartCard(
      {super.key,
      required this.prodImg,
      required this.price,
      required this.prodTitle,
      required this.quantity,
      this.onDecrementTapped,
      this.onIncrementTapped,
      this.onRemoveTapped, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: UIColor.gold,
        ),
        borderRadius: BorderRadius.circular(22.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(22.sp),
              child: CachedNetworkImage(
                imageUrl: prodImg,
                width: 100.sp,
              )),
          SizedBox(
            width: 10.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prodTitle,
                style: TextStyle(color: UIColor.gold, fontSize: 22.sp),
              ),
              Text(
                price,
                style: TextStyle(color: UIColor.gold, fontSize: 16.sp),
              ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: onDecrementTapped,
                    icon: Icon(Icons.remove, color: UIColor.gold),
                    padding: EdgeInsets.zero,
                  ),
                  state?Center(child: SizedBox(
                    width: 15.w,
                    height: 15.h,
                    child: CircularProgressIndicator(
                      color: UIColor.gold,
                      strokeWidth: 3,
                    ),
                  )):
                  Text(
                    quantity.toString(),
                    style: TextStyle(color: UIColor.gold, fontSize: 16.sp),
                  ),
                  IconButton(
                    onPressed: onIncrementTapped,
                    icon: Icon(Icons.add, color: UIColor.gold),
                    padding: EdgeInsets.zero,
                  ),
                ],
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
