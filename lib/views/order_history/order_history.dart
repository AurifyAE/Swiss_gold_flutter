import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/order_history/widgets/order_card.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<OrderHistoryViewModel>();
      model.checkGuestMode().then((_) {
        model.getOrderHistory();
      });
    });
  }

  bool isExpanded = false;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order History',
          style: TextStyle(
            color: UIColor.gold,
            fontSize: 20.sp,
            fontFamily: 'Familiar',
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: UIColor.gold,
            )),
      ),
      body: Consumer<OrderHistoryViewModel>(builder: (context, model, child) {
        if (model.state == ViewState.loading) {
          return Center(
            child: CircularProgressIndicator(
              color: UIColor.gold,
            ),
          );
        } else if (model.isGuest == true) {
          return Center(
            child: CustomOutlinedBtn(
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
          );
        } else if (model.orderModel == null || model.orderModel!.data.isEmpty) {
          return Center(
            child: Text('No history'),
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: ListView.builder(
                itemCount: model.orderModel!.data.length,
                itemBuilder: (context, index) {
                  final prod = model.orderModel!.data[index];

                  return OrderCard(
                    status: prod.orderStatus,
                    totalPrice: prod.totalPrice,
                    orderRemark: model.orderModel!.data[index].orderRemark,
                    paymentMethod: model.orderModel!.data[index].paymentMethod,
                    transactionId: prod.transactionId,
                    deliveryDate: prod.deliveryDate,
                    expanded: isExpanded && currentIndex == index,
                    icon: isExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down_outlined,
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                        currentIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(
                        seconds: 1,
                      ),
                      child: isExpanded && currentIndex == index
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: prod.item.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                          bottom: 10.h, top: 20.h),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.sp),
                                              child: CachedNetworkImage(
                                                imageUrl: prod.item[index]
                                                    .product!.images[0],
                                                width: 80.w,
                                                errorWidget:
                                                    (context, url, error) {
                                                  return Image.asset(
                                                    ImageAssets.prod,
                                                    width: 80.w,
                                                    height: 40.h,
                                                  );
                                                },
                                              )),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                prod.item[index].product!.title,
                                                style: TextStyle(
                                                  color: UIColor.gold,
                                                  fontSize: 16.sp,
                                                  fontFamily: 'Familiar',
                                                ),
                                              ),
                                              Text(
                                                'AED ${prod.item[index].product!.price}'
                                                    .toString()
                                                    .substring(0, 10),
                                                style: TextStyle(
                                                  color: UIColor.gold,
                                                  fontSize: 16.sp,
                                                  fontFamily: 'Familiar',
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Quantity :',
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
                                                    prod.item[index].quantity
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: UIColor.gold,
                                                      fontSize: 16.sp,
                                                      fontFamily: 'Familiar',
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              if(prod.item[index]
                                                                    .status ==
                                                                'Rejected')

                                              Row(
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
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.w,
                                                            vertical: 1.h),
                                                    decoration: BoxDecoration(
                                                        color:  Colors.red,
                                                           
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    5.sp)),
                                                    child: Text(
                                                      prod.item[index].status,
                                                      style: TextStyle(
                                                        color: UIColor.white,
                                                        fontSize: 9.sp,
                                                        fontFamily: 'Familiar',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${prod.item[index].product!.weight.toString()} g',
                                                style: TextStyle(
                                                  color: UIColor.gold,
                                                  fontSize: 16.sp,
                                                  fontFamily: 'Familiar',
                                                ),
                                              ),
                                              Text(
                                                prod.item[index].product!.purity
                                                    .toString(),
                                                style: TextStyle(
                                                  color: UIColor.gold,
                                                  fontSize: 16.sp,
                                                  fontFamily: 'Familiar',
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            )
                          : null,
                    ),
                  );
                }),
          );
        }
      }),
    );
  }
}
