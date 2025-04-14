// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/money_format_heper.dart';

class BalanceCard extends StatelessWidget {
  final BalanceInfo balanceInfo;
  final Summary summary;
  
  // ignore: use_super_parameters
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
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: UIColor.gold),
        boxShadow: [
          BoxShadow(
            color: UIColor.gold.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gold accent line
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        fontFamily: 'Familiar',
                        color: UIColor.gold,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      balanceInfo.name,
                      style: TextStyle(
                        fontFamily: 'Familiar',
                        color: UIColor.gold.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 1,
                  width: 60.w,
                  color: UIColor.gold,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Balance section with precise alignment
            Row(
              children: [
                // Gold balance
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: UIColor.gold.withOpacity(0.5)),
                        ),
                        child: Icon(
                          Icons.savings,
                          color: UIColor.gold,
                          size: 18.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gold Balance',
                            style: TextStyle(
                              fontFamily: 'Familiar',
                              color: UIColor.gold.withOpacity(0.7),
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${balanceInfo.availableGold.toStringAsFixed(3)} g',
                            style: TextStyle(
                              fontFamily: 'Familiar',
                              color: UIColor.gold,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Vertical divider
                Container(
                  height: 40.h,
                  width: 1,
                  color: UIColor.gold.withOpacity(0.3),
                ),
                
                // Cash balance
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: UIColor.gold.withOpacity(0.5)),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: UIColor.gold,
                          size: 18.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Balance',
                            style: TextStyle(
                              fontFamily: 'Familiar',
                              color: UIColor.gold.withOpacity(0.7),
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'AED ${formatNumber(balanceInfo.cashBalance)}',
                            style: TextStyle(
                              fontFamily: 'Familiar',
                              color: UIColor.gold,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Transaction summary in a more elegant row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTransactionSummary(
                  'Credit',
                  summary.gold.creditCount + summary.cash.creditCount,
                  Icons.arrow_circle_up_outlined,
                ),
                _buildTransactionSummary(
                  'Debit',
                  summary.gold.debitCount + summary.cash.debitCount,
                  Icons.arrow_circle_down_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransactionSummary(String type, int count, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: UIColor.gold,
          size: 16.r,
        ),
        SizedBox(width: 6.w),
        Text(
          '$type: ',
          style: TextStyle(
            fontFamily: 'Familiar',
            color: UIColor.gold.withOpacity(0.8),
            fontSize: 13.sp,
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontFamily: 'Familiar',
            color: UIColor.gold,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}