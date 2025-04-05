import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';
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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  Map<int, int> productQuantities = {};
  List<Map<String, dynamic>> bookingData = [];
  AnimationController? animationController;
  Animation<double>? animation;
  String selectedValue = '';
  DateTime selectedDate = DateTime.now();
  final FocusNode _pageFocusNode = FocusNode();
  bool _initialFetchDone = false;

  void navigateToDeliveryDetails(
      {String? paymentMethod, String? pricingOption, String? amount}) {
    final effectivePaymentMethod =
        selectedValue != 'Gold' ? (paymentMethod ?? 'Cash') : 'Gold';

    Map<String, dynamic> finalPayload = {
      "bookingData": bookingData,
      "paymentMethod": effectivePaymentMethod,
      if (selectedValue != 'Gold' && pricingOption != null)
        "pricingOption": pricingOption,
      "deliveryDate": selectedDate.toString().split(' ')[0]
    };

    if (selectedValue == 'Gold' &&
        pricingOption == 'Premium' &&
        amount != null) {
      finalPayload['premium'] = amount;
    }
    if (selectedValue != 'Gold' &&
        pricingOption == 'Discount' &&
        amount != null) {
      finalPayload['discount'] = amount;
    }

    navigateWithAnimationTo(
      context,
      DeliveryDetailsView(
        orderData: finalPayload,
        onConfirm: (deliveryDetails) {
          processOrder(finalPayload);
        },
      ),
      0,
      1,
    );
  }

  void processOrder(Map<String, dynamic> finalPayload) {
    print(finalPayload);
    context
        .read<ProductViewModel>()
        .bookProducts(finalPayload)
        .then((response) {
      if (response!.success == true) {
        setState(() {
          selectedValue = '';
          bookingData.clear();
          productQuantities.clear();
        });

        context.read<ProductViewModel>().clearQuantities();

        customSnackBar(
            bgColor: UIColor.gold,
            titleColor: UIColor.white,
            width: 130.w,
            context: context,
            title: 'Booking success');
      } else {
        customSnackBar(
            bgColor: UIColor.gold,
            titleColor: UIColor.white,
            width: 130.w,
            context: context,
            title: 'Booking failed');
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

  scrollController.addListener(
    () {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          final model = context.read<ProductViewModel>();

          if (!model.isLoading && model.hasMoreData) {
            currentPage++;
            _loadMoreProducts();
          }
        }
      }
    },
  );

  _pageFocusNode.addListener(_onFocusChange);


      WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_initialFetchDone) {
      // First sync quantities from the view model
      _syncQuantitiesFromViewModel();
      
      // Then fetch products only if they haven't been fetched yet
      if (context.read<ProductViewModel>().productList.isEmpty) {
        context.read<ProductViewModel>().fetchProducts();
      }
      _initialFetchDone = true;
    }
  });
}

void _onFocusChange() {
  if (_pageFocusNode.hasFocus) {
    // Just sync quantities when focus changes, don't fetch products
    _syncQuantitiesFromViewModel();
  }
}

void _syncQuantitiesFromViewModel() {
  final viewModel = context.read<ProductViewModel>();
  setState(() {
    productQuantities = Map<int, int>.from(viewModel.productQuantities);
    _updateBookingData();
  });
}

// New method that updates booking data without triggering a fetch
void _updateBookingData() {
  bookingData.clear();

  final productList = context.read<ProductViewModel>().productList;
  productQuantities.forEach((index, quantity) {
    if (index < productList.length && quantity > 0) {
      final product = productList[index];
      if (product.pId != null) {
        bookingData.add({
          "productId": product.pId,
          "quantity": quantity,
        });
      }
    }
  });
}

void _rebuildBookingData() {
  bookingData.clear();

  final productList = context.read<ProductViewModel>().productList;
  productQuantities.forEach((index, quantity) {
    if (index < productList.length && quantity > 0) {
      final product = productList[index];
      if (product.pId != null) {
        bookingData.add({
          "productId": product.pId,
          "quantity": quantity,
        });
      }
    }
  });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProductsDirectly();
    });
  }

void _fetchProductsDirectly() {
  final viewModel = context.read<ProductViewModel>();

  setState(() {
    productQuantities = Map<int, int>.from(viewModel.productQuantities);
  });

  viewModel.fetchProducts();
}

void _loadMoreProducts() {
  final viewModel = context.read<ProductViewModel>();
  final String adminId = viewModel.adminId ?? '';
  final String categoryId = viewModel.categoryId ?? '';
  viewModel.fetchProducts(adminId, categoryId, currentPage.toString());
}

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
    if (index >= context.read<ProductViewModel>().productList.length) {
      return;
    }

    final product = context.read<ProductViewModel>().productList[index];
    if (product.pId == null) return;

    setState(() {
      if (productQuantities[index] != null) {
        productQuantities[index] = productQuantities[index]! + 1;
      } else {
        productQuantities[index] = 1;
      }

      context
          .read<ProductViewModel>()
          .getTotalQuantity(Map<int, int>.from(productQuantities));

      addToBookingData(index, product.pId!);
    });
  }

  void decrementQuantity(int index) {
    if (index >= context.read<ProductViewModel>().productList.length) {
      return;
    }

    final product = context.read<ProductViewModel>().productList[index];
    if (product.pId == null) return;

    setState(() {
      if (productQuantities[index] != null && productQuantities[index]! > 0) {
        productQuantities[index] = productQuantities[index]! - 1;

        if (productQuantities[index] == 0) {
          productQuantities.remove(index);
        }
      }

      context
          .read<ProductViewModel>()
          .getTotalQuantity(Map<int, int>.from(productQuantities));

      removeFromBookingData(index, product.pId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _pageFocusNode,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Consumer<ProductViewModel>(
                builder: (context, model, child) => Text(
                  'Total Quantity: ${model.totalQuantity}',
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
                          SizedBox(height: 30.h),
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
                            btnText: 'Gold to Gold',
                          ),
                          SizedBox(height: 10.h),
                          CustomOutlinedBtn(
                            borderRadius: 12.sp,
                            borderColor: UIColor.gold,
                            padH: 12.w,
                            padV: 12.h,
                            onTapped: () {
                              selectedValue = 'Cash';
                              Navigator.pop(context);
                              navigateToDeliveryDetails(
                                  paymentMethod: context
                                      .read<OrderHistoryViewModel>()
                                      .cashPricingModel
                                      ?.data
                                      .methodType,
                                  pricingOption: context
                                      .read<OrderHistoryViewModel>()
                                      .cashPricingModel
                                      ?.data
                                      .pricingType,
                                  amount: context
                                      .read<OrderHistoryViewModel>()
                                      .cashPricingModel
                                      ?.data
                                      .value
                                      .toString());
                            },
                            btnTextColor: UIColor.gold,
                            btnText: 'Cash',
                          ),
                        ]);
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
            controller: scrollController,
            child: Column(
              children: [
                Consumer<ProductViewModel>(builder: (context, model, child) {
                  if (model.state == ViewState.loading) {
                    return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
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
                          Image.asset(ImageAssets.noProducts),
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
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16.h,
                                  crossAxisSpacing: 16.w),
                          itemCount: model.productList.length,
                          itemBuilder: (context, index) {
                            final product = model.productList[index];

                            final String productId = product.pId ?? '';
                            final String imageUrl = product.prodImgs.isNotEmpty
                                ? product.prodImgs[0].url
                                : 'https://via.placeholder.com/150';
                            final String title =
                                product.title ?? 'Unknown Product';
                            final int quantity = productQuantities[index] ?? 0;
                            final String price = product.type?.toLowerCase() ==
                                    'gold'
                                ? 'AED ${(model.goldSpotRate ?? 0).toStringAsFixed(2)}'
                                : 'AED ${(product.price ?? 0).toStringAsFixed(2)}';
                            final String productType =
                                product.type ?? 'Unknown';

                            return CustomCard(
                              onIncrement: () => incrementQuantity(index),
                              onDecrement: () => decrementQuantity(index),
                              onAddToCart: () {
                                if (model.isGuest == false) {
                                  context
                                      .read<CartViewModel>()
                                      .updateQuantityFromHome(productId, {
                                    'quantity': productQuantities[index] ?? 1
                                  }).then((response) {
                                    if (response?.success == true) {
                                      setState(() {
                                        productQuantities.remove(index);
                                      });
                                      context
                                          .read<ProductViewModel>()
                                          .getTotalQuantity(Map<int, int>.from(
                                              productQuantities));
                                    }
                                    customSnackBar(
                                      context: context,
                                      width: 250.w,
                                      bgColor: UIColor.gold,
                                      title: response?.message?.toString() ??
                                          'Action completed',
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
                              prodImg: imageUrl,
                              title: title,
                              quantity: quantity,
                              price: price,
                              subTitle: productType,
                              onTap: () {
                                navigateWithAnimationTo(
                                    context,
                                    ProductView(
                                      prodImg: product.prodImgs
                                          .map((e) => e.url ?? '')
                                          .toList(),
                                      title: title,
                                      pId: productId,
                                      desc: product.desc ?? '',
                                      type: productType,
                                      stock: product.stock ?? false,
                                      purity: product.purity ?? 0,
                                      weight: product.weight ?? 0,
                                      makingCharge: product.makingCharge ?? 0,
                                    ),
                                    0,
                                    1);
                              },
                            );
                          },
                        ),
                        if (model.state == ViewState.loadingMore)
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: UIColor.gold),
                            ),
                          ),
                      ],
                    );
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageFocusNode.removeListener(_onFocusChange);
    _pageFocusNode.dispose();
    animationController?.dispose();
    scrollController.dispose();
    super.dispose();
  }
}