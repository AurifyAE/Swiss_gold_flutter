import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/views/profile/profile_view.dart';
import 'package:swiss_gold/views/wishlist/wishlist_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> openUrl(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          CustomOutlinedBtn(
            borderRadius: 22.sp,
            borderColor: UIColor.gold,
            padH: 20.w,
            padV: 10.h,
            btnText: 'Profile',
            btnTextColor: UIColor.gold,
            fontSize: 25.sp,
            align: MainAxisAlignment.start,
            onTapped: () {
              navigateTo(context, ProfileView());
            },
          ),
          SizedBox(
            height: 15.h,
          ),
          CustomOutlinedBtn(
            borderRadius: 22.sp,
            borderColor: UIColor.gold,
            padH: 20.w,
            padV: 10.h,
            btnText: 'Wishlist',
            btnTextColor: UIColor.gold,
            fontSize: 25.sp,
            align: MainAxisAlignment.start,
            onTapped: () {
              navigateTo(context, WishlistView());
            },
          ),
          SizedBox(
            height: 15.h,
          ),
          CustomOutlinedBtn(
            borderRadius: 22.sp,
            borderColor: UIColor.gold,
            padH: 20.w,
            padV: 10.h,
            btnText: 'Terms and conditions',
            btnTextColor: UIColor.gold,
            fontSize: 25.sp,
            align: MainAxisAlignment.start,
            onTapped: () {
              openUrl('https://rakgolds.ae/terms-conditions');
            },
          ),
          SizedBox(
            height: 15.h,
          ),
          CustomOutlinedBtn(
            borderRadius: 22.sp,
            borderColor: UIColor.gold,
            padH: 20.w,
            padV: 10.h,
            btnText: 'FAQs',
            btnTextColor: UIColor.gold,
            fontSize: 25.sp,
            align: MainAxisAlignment.start,
            onTapped: () {
              openUrl('https://rakgolds.ae/faq');
            },
          )
        ],
      ),
    );
  }
}
