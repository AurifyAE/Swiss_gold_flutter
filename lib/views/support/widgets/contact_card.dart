import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class ContactCard extends StatelessWidget {
  final String icon;
  final String title;
  final Function()? onTap;
  const ContactCard({super.key, required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: UIColor.gold
          ),
          borderRadius: BorderRadius.circular(22.sp)
        ),
        child: Column(
          children: [
            Image.asset(icon),
            Text(
              title,
              style: TextStyle(color: UIColor.gold, fontSize: 22.sp),
            )
          ],
        ),
      ),
    );
  }
}
