import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/order_history/order_history.dart';
import 'package:swiss_gold/views/profile/profile_view.dart';
import 'package:swiss_gold/views/transaction/transaction_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final InAppReview inAppReview = InAppReview.instance;

    Future<void> openUrl(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Consumer<OrderHistoryViewModel>(
      builder: (context, productProvider, child) {
        bool isGuestUser = productProvider.isGuest ?? false;

        // If user is a guest, show login button similar to OrderHistory
        if (isGuestUser) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Please login to access more options',
                  style: TextStyle(
                    color: UIColor.gold,
                    fontSize: 16.sp,
                    fontFamily: 'Familiar',
                  ),
                ),
                SizedBox(height: 20.h),
                CustomOutlinedBtn(
                  borderRadius: 22.sp,
                  borderColor: UIColor.gold,
                  padH: 10.w,
                  padV: 10.h,
                  width: 200.w,
                  btnText: 'Login',
                  btnTextColor: UIColor.gold,
                  fontSize: 22.sp,
                  onTapped: () {
                    navigateTo(context, LoginView());
                  },
                ),
              ],
            ),
          );
        }

        // Regular view for logged in users
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              CustomOutlinedBtn(
                borderRadius: 12.sp,
                borderColor: UIColor.gold,
                padH: 20.w,
                padV: 20.h,
                btnText: 'Profile',
                btnIcon: PhosphorIcons.userCircle(),
                suffixIcon: Icons.arrow_forward_ios,
                iconColor: UIColor.gold,
                btnTextColor: UIColor.gold,
                fontSize: 17.sp,
                align: MainAxisAlignment.start,
                onTapped: () {
                  navigateTo(context, ProfileView());
                },
              ),
              SizedBox(height: 20.h),
              
      

              CustomOutlinedBtn(
                borderRadius: 12.sp,
                borderColor: UIColor.gold,
                padH: 20.w,
                padV: 20.h,
                btnIcon: PhosphorIcons.article(),
                iconColor: UIColor.gold,
                btnText: 'Payment history',
                btnTextColor: UIColor.gold,
                suffixIcon: Icons.arrow_forward_ios,
                fontSize: 17.sp,
                align: MainAxisAlignment.start,
                onTapped: () {
                  navigateTo(context, TransactionHistoryView());
                },
              ),
              SizedBox(height: 20.h),

              CustomOutlinedBtn(
                borderRadius: 12.sp,
                borderColor: UIColor.gold,
                padH: 20.w,
                padV: 20.h,
                btnText: 'Terms and conditions',
                btnIcon: PhosphorIcons.link(),
                iconColor: UIColor.gold,
                btnTextColor: UIColor.gold,
                suffixIcon: Icons.arrow_forward_ios,
                fontSize: 17.sp,
                align: MainAxisAlignment.start,
                onTapped: () {
                  openUrl('https://rakgolds.ae/terms-conditions');
                },
              ),
              SizedBox(height: 20.h),

              CustomOutlinedBtn(
                borderRadius: 12.sp,
                borderColor: UIColor.gold,
                padH: 20.w,
                padV: 20.h,
                suffixIcon: Icons.arrow_forward_ios,
                btnText: 'FAQs',
                btnTextColor: UIColor.gold,
                btnIcon: PhosphorIcons.link(),
                iconColor: UIColor.gold,
                fontSize: 17.sp,
                align: MainAxisAlignment.start,
                onTapped: () {
                  openUrl('https://rakgolds.ae/faq');
                },
              ),
              SizedBox(height: 20.h),

              CustomOutlinedBtn(
                borderRadius: 12.sp,
                borderColor: UIColor.gold,
                padH: 20.w,
                padV: 20.h,
                btnIcon: PhosphorIcons.paperPlaneTilt(),
                iconColor: UIColor.gold,
                btnText: 'Share App',
                suffixIcon: Icons.arrow_forward_ios,
                btnTextColor: UIColor.gold,
                fontSize: 17.sp,
                align: MainAxisAlignment.start,
                onTapped: () async {
                  Share.share('Discover the best gold deals on Swiss Gold! Check it out now!');
                },
              ),
              SizedBox(height: 20.h),

              CustomOutlinedBtn(
                borderRadius: 12.sp,
                borderColor: UIColor.gold,
                padH: 20.w,
                padV: 20.h,
                btnText: 'Rate Us',
                suffixIcon: Icons.arrow_forward_ios,
                btnIcon: PhosphorIcons.star(),
                iconColor: UIColor.gold,
                btnTextColor: UIColor.gold,
                fontSize: 17.sp,
                align: MainAxisAlignment.start,
                onTapped: () async {
                  inAppReview.openStoreListing(appStoreId: 'ios app id');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}