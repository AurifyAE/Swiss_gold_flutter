import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/models/transaction_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/transaction_view_model.dart';

import 'widgets/base_card.dart';
import 'widgets/item_card.dart';
// import 'package:swiss_gold/views/transactions/widgets/balance_card.dart';
// import 'package:swiss_gold/views/transactions/widgets/transaction_item.dart';

class TransactionHistoryView extends StatefulWidget {
  // final String userId;
  
  const TransactionHistoryView({
    Key? key, 
    
  }) : super(key: key);

  @override
  State<TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<TransactionHistoryView> {
  final ScrollController _scrollController = ScrollController();
  final List<String> filters = ['All', 'Gold', 'Cash', 'Credit', 'Debit'];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().fetchTransactions();
    });
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        final model = context.read<TransactionViewModel>();
        if (model.pagination != null && 
            model.pagination!.currentPage < model.pagination!.totalPages) {
          model.loadMoreTransactions();
        }
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: TextStyle(
            fontFamily: 'Familiar',
            color: UIColor.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        // backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: UIColor.gold),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: UIColor.gold),
            onPressed: () {
              context.read<TransactionViewModel>().refreshTransactions();
            },
          ),
        ],
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, model, child) {
          if (model.state == ViewState.loading) {
            return Center(
              child: CircularProgressIndicator(color: UIColor.gold),
            );
          } else if (model.state == ViewState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60.r,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load transactions',
                    style: TextStyle(
                      fontFamily: 'Familiar',
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColor.gold,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () {
                      model.fetchTransactions();
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Familiar',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            color: UIColor.gold,
            onRefresh: () async {
              await model.fetchTransactions();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: model.balanceInfo != null && model.summary != null
                        ? BalanceCard(
                            balanceInfo: model.balanceInfo!,
                            summary: model.summary!,
                          )
                        : SizedBox.shrink(),
                  ),
                ),
                
                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filters.map((filter) {
                          final isSelected = model.selectedFilter == filter;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : UIColor.gold,
                                  fontFamily: 'Familiar',
                                  fontSize: 14.sp,
                                ),
                              ),
                              backgroundColor: Colors.black,
                              selectedColor: UIColor.gold,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: UIColor.gold,
                                  width: 1,
                                ),
                              ),
                              onSelected: (selected) {
                                model.setFilter(filter);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Text(
                          'Transactions',
                          style: TextStyle(
                            fontFamily: 'Familiar',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(${model.filteredTransactions.length})',
                          style: TextStyle(
                            fontFamily: 'Familiar',
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        if (model.transactions.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              // Implement sort functionality
                              model.toggleSortOrder();
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Sort',
                                  style: TextStyle(
                                    fontFamily: 'Familiar',
                                    fontSize: 14.sp,
                                    color: UIColor.gold,
                                  ),
                                ),
                                Icon(
                                  model.isAscending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 16.r,
                                  color: UIColor.gold,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                model.filteredTransactions.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 60.r,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontFamily: 'Familiar',
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < model.filteredTransactions.length) {
                          final transaction = model.filteredTransactions[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            child: TransactionItem(transaction: transaction),
                          );
                        } else if (model.loadingMore) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.r),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: UIColor.gold,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: model.filteredTransactions.length + (model.loadingMore ? 1 : 0),
                    ),
                  ),
                  
                // Add spacing at the bottom
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}