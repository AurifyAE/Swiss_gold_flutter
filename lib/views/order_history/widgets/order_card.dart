import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';

class OrderCard extends StatelessWidget {
  final String status;
  final Function()? onTap;
  final String transactionId;
  final String deliveryDate;
  final void Function()? onRemoveTapped;
  final Widget child;
  final String paymentMethod;
  final bool expanded;
  final num totalPrice;
  final String? orderRemark;

  final IconData icon;

  const OrderCard({
    super.key,
    required this.status,
    required this.paymentMethod,
     this.orderRemark,
    this.onTap,
    this.onRemoveTapped,
    required this.totalPrice,
    required this.icon,
    required this.transactionId,
    required this.deliveryDate,
    required this.expanded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    int index = deliveryDate.indexOf('T');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: UIColor.gold,
          ),
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              transactionId,
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Row(
                          children: [
                            Text(
                              'Status :',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                  color: status == 'Rejected'
                                      ? Colors.red
                                      : status == 'Success'
                                          ? Colors.lightGreen
                                          : status == 'User Approval Pending'
                                              ? Colors.orangeAccent
                                              : Colors.lightBlueAccent,
                                  borderRadius: BorderRadius.circular(5.sp)),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: UIColor.white,
                                  fontSize: 9.sp,
                                  fontFamily: 'Familiar',
                                ),
                              ),
                            ),
                            Spacer(),
                            Icon(
                              icon,
                              color: UIColor.gold,
                            ),
                          ],
                        ),
                        orderRemark!=null?SizedBox(height: 5.h,):SizedBox.shrink(),

                         orderRemark!=null?
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reason :',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Flexible(
                              child: SizedBox(
                                
                                child: Text(
                                  orderRemark.toString(),
                                  maxLines: null,
                                  style: TextStyle(
                                    color: UIColor.gold,
                                    fontSize: 16.sp,
                                    fontFamily: 'Familiar',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ):SizedBox.shrink(),
                       
SizedBox(height: 5.h,),
                        Row(
                          children: [
                            Text(
                              'Total price :',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              totalPrice.toStringAsFixed(2),
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h,),

                        Row(
                          children: [
                            Text(
                              'Payment method :',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              paymentMethod,
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h,),

                        Row(
                          children: [
                            Text(
                              'Delivery date :',
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              deliveryDate.substring(0, index),
                              style: TextStyle(
                                color: UIColor.gold,
                                fontSize: 16.sp,
                                fontFamily: 'Familiar',
                              ),
                            ),
                          ],
                        ),
                        expanded
                            ? SizedBox(
                                height: 10.h,
                              )
                            : SizedBox.shrink(),
                        expanded
                            ? Divider(
                                color: UIColor.gold,
                              )
                            : SizedBox.shrink(),
                        child
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
