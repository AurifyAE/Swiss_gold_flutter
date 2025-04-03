import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_alert.dart';
import 'package:swiss_gold/core/utils/widgets/custom_card.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';
import 'package:swiss_gold/views/delivery/delivery_view.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/products/product_view.dart';
// import 'package:swiss_gold/views/delivery/delivery_details_view.dart'; // Add this import

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  int currentIndex = 1;
  Map<int, int> productQuantities = {};
  List<Map<String, dynamic>> bookingData = [];
  AnimationController? animationController;
  Animation<double>? animation;
  String selectedValue = '';
  DateTime selectedDate = DateTime.now(); // Always use current date
  int totalQuantity = 0;

  // This new method will navigate to delivery details page
void navigateToDeliveryDetails({String? paymentMethod, String? pricingOption, String? amount}) {
  Map<String, dynamic> finalPayload = {
    "bookingData": bookingData,
    "paymentMethod": selectedValue != 'Gold' ? paymentMethod : 'Gold',
    if (selectedValue != 'Gold') "pricingOption": pricingOption,
    "deliveryDate": selectedDate.toString().split(' ')[0]
  };

  if (selectedValue == 'Gold' && (pricingOption == 'Premium')) {
    finalPayload['premium'] = amount;
  }
  if (selectedValue != 'Gold' && (pricingOption == 'Discount')) {
    finalPayload['discount'] = amount;
  }

  // Navigate to the simplified delivery details page with the order data
  navigateWithAnimationTo(
    context,
    DeliveryDetailsView(
      orderData: finalPayload,
      onConfirm: (deliveryDetails) {
        // No user data is collected now, just process the order
        processOrder(finalPayload);
      },
    ),
    0,
    1,
  );
}

  // Method to process the final order
  void processOrder(Map<String, dynamic> finalPayload) {
    context.read<ProductViewModel>().bookProducts(finalPayload).then((response) {
      if (response!.success == true) {
        selectedValue = '';

        customSnackBar(
          bgColor: UIColor.gold,
          titleColor: UIColor.white,
          width: 130.w,
          context: context,
          title: 'Booking success'
        );
        
        bookingData.clear();
        productQuantities.clear();
        // Clear quantities in the ViewModel too
        context.read<ProductViewModel>().clearQuantities();
      } else {
        customSnackBar(
          bgColor: UIColor.gold,
          titleColor: UIColor.white,
          width: 130.w,
          context: context,
          title: 'Booking failed'
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryViewModel>().getCashPricing('Cash');
    context.read<OrderHistoryViewModel>().getBankPricing('Bank');

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          final model = context.read<ProductViewModel>();

          if (currentIndex < (model.productModle?.page?.totalPage ?? 0)) {
            model.loadMoreProducts({
              'index': currentIndex.toString(),
            }).then((_) {
              currentIndex++;
              model.loadMoreProducts({'index': currentIndex.toString()});
            });
          }
        }
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ProductViewModel>();
      viewModel.checkGuestMode();
      
      // Initialize quantities from the ViewModel
      setState(() {
        productQuantities = Map<int, int>.from(viewModel.productQuantities);
      });
      
      viewModel.getRealtimePrices().then((_) {
        viewModel.getBanners();
        viewModel.getSpotRate();

        viewModel.listProducts({'index': '1'}).then((_) {
          // Rebuild booking data after products are loaded
          _rebuildBookingData();
        });
      });
    });
  }

  // Add this method to rebuild booking data from stored quantities
  void _rebuildBookingData() {
    bookingData.clear();
    final model = context.read<ProductViewModel>();
    
    if (model.productList.isNotEmpty) {
      productQuantities.forEach((index, quantity) {
        if (index < model.productList.length && quantity > 0) {
          String pId = model.productList[index].pId;
          
          int existingIndex = bookingData.indexWhere((item) => item["productId"] == pId);
          if (existingIndex != -1) {
            bookingData[existingIndex]["quantity"] = quantity;
          } else {
            bookingData.add({
              "productId": pId,
              "quantity": quantity,
            });
          }
        }
      });
    }
  }

  double goldBid = 0;
  double goldPrice = 0;

  void addToBookingData(int index, String pId) {
    int quantity = productQuantities[index] ?? 1;

    int existingIndex =
        bookingData.indexWhere((item) => item["productId"] == pId);

    if (existingIndex != -1) {
      bookingData[existingIndex]["quantity"] =
          (bookingData[existingIndex]["quantity"] ?? 0) + 1;
    } else {
      bookingData.add({
        "productId": pId,
        "quantity": quantity,
      });
    }
  }

  void removeFromBookingData(int index, String pId) {
    int existingIndex =
        bookingData.indexWhere((item) => item["productId"] == pId);

    if (existingIndex != -1) {
      if (bookingData[existingIndex]["quantity"] > 1) {
        bookingData[existingIndex]["quantity"] =
            (bookingData[existingIndex]["quantity"] ?? 0) - 1;
      } else {
        bookingData.removeAt(existingIndex);
      }
    }
  }

  void incrementQuantity(int index) {
    setState(() {
      if (productQuantities[index] != null) {
        productQuantities[index] = productQuantities[index]! + 1;
      } else {
        productQuantities[index] = 1;
      }
      // Update the ViewModel with the updated quantities
      context.read<ProductViewModel>().getTotalQuantity(Map<int, int>.from(productQuantities));
      addToBookingData(index, context.read<ProductViewModel>().productList[index].pId);
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (productQuantities[index] != null && productQuantities[index]! >= 1) {
        productQuantities[index] = productQuantities[index]! - 1;
      }
      // Update the ViewModel with the updated quantities
      context.read<ProductViewModel>().getTotalQuantity(Map<int, int>.from(productQuantities));
      removeFromBookingData(index, context.read<ProductViewModel>().productList[index].pId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Consumer<ProductViewModel>(
              builder: (context, model, child) => Text(
                'Total Quantity : ${model.totalQuantity}',
                style: TextStyle(
                    color: UIColor.gold,
                    fontFamily: 'Familiar',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.normal),
              ),
            ),
            Spacer(),
            Flexible(
                child: CustomOutlinedBtn(
              btnTextColor: UIColor.gold,
              height: 40.h,
              borderRadius: 12.sp,
              borderColor: UIColor.gold,
              padH: 5.w,
              padV: 5.h,
              onTapped: () {
                if (bookingData.isNotEmpty) {
                  showAnimatedDialog2(
                    context,
                    animationController!,
                    animation!,
                    'Choose Your Payment Option',
                    'You can either pay using cash or opt for gold as your preferred payment method. Select an option to proceed',
                    [
                      SizedBox(
                        height: 30.h,
                      ),
                      CustomOutlinedBtn(
                        borderRadius: 12.sp,
                        borderColor: UIColor.gold,
                        padH: 12.w,
                        padV: 12.h,
                        onTapped: () {
                          selectedValue = 'Gold';
                          Navigator.pop(context);
                          navigateToDeliveryDetails();
                        },
                        btnTextColor: UIColor.gold,
                        btnText: 'Gold',
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          navigateToDeliveryDetails(
                            paymentMethod: context.read<OrderHistoryViewModel>().cashPricingModel?.data.methodType,
                            pricingOption: context.read<OrderHistoryViewModel>().cashPricingModel?.data.pricingType,
                            amount: context.read<OrderHistoryViewModel>().cashPricingModel?.data.value.toString()
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.sp),
                            border: Border.all(color: UIColor.gold),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Cash',
                                style: TextStyle(
                                    fontFamily: 'Familiar',
                                    color: UIColor.gold,
                                    fontSize: 14.sp),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                '${context.read<OrderHistoryViewModel>().cashPricingModel?.data.pricingType} :  ${context.read<OrderHistoryViewModel>().cashPricingModel?.data.value}',
                                style: TextStyle(
                                    fontFamily: 'Familiar',
                                    color: UIColor.gold,
                                    fontSize: 13.sp),
                              )
                            ],
                          ),
                        ),
                      ),
                    ]
                  );
                } else {
                  customSnackBar(
                      bgColor: UIColor.gold,
                      titleColor: UIColor.white,
                      width: 180.w,
                      context: context,
                      title: 'Please select products');
                }
              },
              btnText: 'Place order',
            ))
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Consumer<ProductViewModel>(builder: (context, model, child) {
                if (model.state == ViewState.loading ||
                    model.marketPriceState == ViewState.loading) {
                  return GridView.builder(
                      shrinkWrap: true,
                      itemCount: 6,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w),
                      itemBuilder: (context, index) {
                        return CategoryShimmer();
                      });
                } else if (model.productList.isEmpty) {
                  return Center(
                    heightFactor: 2.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImageAssets.noProducts,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Sorry no products found\ntry some other category",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 20.sp,
                            fontFamily: 'Familiar',
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        key: PageStorageKey('productKey'),
                        controller: scrollController,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 16.w),
                        itemCount: model.productList.length,
                        itemBuilder: (context, index) {
                          return Consumer<ProductViewModel>(
                              builder: (context, model, child) {
                            return CustomCard(
                              onIncrement: () {
                                incrementQuantity(index);
                              },
                              onDecrement: () {
                                decrementQuantity(index);
                              },
                              onAddToCart: () {
                                if (context.read<ProductViewModel>().isGuest ==
                                    false) {
                                  context
                                      .read<CartViewModel>()
                                      .updateQuantityFromHome(
                                          model.productList[index].pId, {
                                    'quantity': productQuantities[index] ?? 1
                                  }).then((response) {
                                    if (response!.success == true) {
                                      productQuantities.remove(index);
                                      // Update the view model when items are added to cart
                                      context.read<ProductViewModel>().getTotalQuantity(Map<int, int>.from(productQuantities));
                                    }
                                    customSnackBar(
                                      context: context,
                                      width: 250.w,
                                      bgColor: UIColor.gold,
                                      title: response!.message.toString(),
                                    );
                                  });
                                } else {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginView()),
                                      (route) => false);
                                }
                              },
                              prodImg: model.productList[index].prodImgs[0],
                              title: model.productList[index].title,
                              quantity: productQuantities[index] ?? 0,
                              price:
                                  model.productList[index].type.toLowerCase() ==
                                          'gold'
                                      ? 'AED ${goldPrice.toStringAsFixed(2)}'
                                      : '0',
                              subTitle: model.productList[index].type,
                              onTap: () {
                                navigateWithAnimationTo(
                                    context,
                                    ProductView(
                                      prodImg:
                                          model.productList[index].prodImgs,
                                      title: model.productList[index].title,
                                      pId: model.productList[index].pId,
                                      desc: model.productList[index].desc,
                                      type: model.productList[index].type,
                                      stock: model.productList[index].stock,
                                      purity: model.productList[index].purity,
                                      weight: model.productList[index].weight,
                                      makingCharge:
                                          model.productList[index].makingCharge,
                                    ),
                                    0,
                                    1);
                              },
                            );
                          });
                        },
                      ),
                      model.state == ViewState.loadingMore
                          ? Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: UIColor.gold,
                                ),
                              ),
                            )
                          : SizedBox.shrink()
                    ],
                  );
                }
              })
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    animationController?.dispose();
    scrollController.dispose();
    super.dispose();
  }
}