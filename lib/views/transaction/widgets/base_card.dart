import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/money_format_heper.dart';

class BalanceCard extends StatelessWidget {
  final BalanceInfo balanceInfo;
  final Summary summary;
  
  const BalanceCard({
    Key? key,
    required this.balanceInfo,
    required this.summary,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UIColor.gold.withOpacity(0.8),
            UIColor.gold,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Balance',
                  style: TextStyle(
                    fontFamily: 'Familiar',
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  balanceInfo.name,
                  style: TextStyle(
                    fontFamily: 'Familiar',
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Gold balance
            Row(
              children: [
                Icon(
                  Icons.savings,
                  color: Colors.white,
                  size: 24.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${balanceInfo.availableGold.toStringAsFixed(3)} g',
                  style: TextStyle(
                    fontFamily: 'Familiar',
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Gold Balance',
              style: TextStyle(
                fontFamily: 'Familiar',
                color: Colors.white.withOpacity(0.8),
                fontSize: 12.sp,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Cash balance
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'AED ${formatNumber(balanceInfo.cashBalance)}',
                  style: TextStyle(
                    fontFamily: 'Familiar',
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Cash Balance',
              style: TextStyle(
                fontFamily: 'Familiar',
                color: Colors.white.withOpacity(0.8),
                fontSize: 12.sp,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Transaction summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Credit Transactions',
                  summary.gold.creditCount + summary.cash.creditCount,
                  Colors.green.withOpacity(0.2),
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Debit Transactions',
                  summary.gold.debitCount + summary.cash.debitCount,
                  Colors.red.withOpacity(0.2),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String title, int count, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Familiar',
              color: Colors.white,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            count.toString(),
            style: TextStyle(
              fontFamily: 'Familiar',
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}