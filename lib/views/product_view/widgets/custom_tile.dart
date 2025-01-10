import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class CustomProdData extends StatelessWidget {
  const CustomProdData({
    super.key, required this.title, required this.data,
   
  });

  final String title;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Row(
   
      children: [
        Text(
         title,
          style: TextStyle(color: UIColor.gold, fontSize: 18.sp),
        ),
        SizedBox(
          width: 30.w,
        ),
        Text(
         data,
          style: TextStyle(color: UIColor.gold, fontSize: 18.sp),
        ),
      ],
    );
  }
}
