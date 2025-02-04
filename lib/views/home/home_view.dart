import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_card.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';
import 'package:swiss_gold/views/home/widgets/home_shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swiss_gold/views/products/product_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ScrollController scrollController = ScrollController();
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();

    ProductService.marketDataStream.listen((marketData) {
      // Store prices based on the symbol
      String symbol = marketData['symbol'].toString().toLowerCase();

      if (mounted) {
        if (symbol == 'gold') {
          setState(() {
            goldBid = (marketData['bid'] is int)
                ? (marketData['bid'] as int).toDouble()
                : marketData['bid'];
          });
        }
      }
    });

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
      viewModel.getRealtimePrices().then((_) {
        viewModel.getBanners();
        viewModel.getSpotRate();

        viewModel.listProducts({'index': '1'});
      });
    });
  }

  double goldBid = 0;

  double goldPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<ProductViewModel>(
              builder: (context, model, child) => model.banners.isEmpty
                  ? HomeShimmer()
                  : CarouselSlider(
                      items: List.generate(model.banners.length, (index) {
                        return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: UIColor.gold),
                              borderRadius: BorderRadius.circular(12.sp),
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      model.banners[index]),
                                  fit: BoxFit.cover)),
                        );
                      }),
                      options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1,
                          height: 200)),
            ),
            SizedBox(
              height: 30.h,
            ),
            Consumer<ProductViewModel>(builder: (context, model, child) {
              if (model.state == ViewState.loading ||
                  model.marketPriceState == ViewState.loading) {
                return GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 180,
                        mainAxisSpacing: 35,
                        crossAxisSpacing: 35),
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
                          mainAxisExtent: 180,
                          mainAxisSpacing: 35,
                          crossAxisSpacing: 35),
                      itemCount: model.productList.length,
                      itemBuilder: (context, index) {
                        return Consumer<ProductViewModel>(
                            builder: (context, model, child) {
                          goldPrice =
                              (((goldBid + model.goldSpotRate!) / 31.103) *
                                      3.674 *
                                      model.productList[index].weight *
                                      model.productList[index].purity /
                                      pow(
                                          10,
                                          model.productList[index].purity
                                              .toString()
                                              .length) +
                                  model.productList[index].makingCharge);

                          return CustomCard(
                            prodImg: model.productList[index].prodImgs[0],
                            title: model.productList[index].title,
                            price:
                                model.productList[index].type.toLowerCase() ==
                                        'gold'
                                    ? 'AED ${goldPrice.toStringAsFixed(2)}'
                                    : '0',
                            subTitle: model.productList[index].type,
                            onTap: () {
                              print(model.productList[index].pId.toString());
                              navigateWithAnimationTo(
                                  context,
                                  ProductView(
                                    prodImg: model.productList[index].prodImgs,
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
    );
  }
}
