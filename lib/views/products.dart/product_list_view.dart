import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/models/prodcuts/product_model.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';
import 'package:swiss_gold/core/utils/widgets/cateogory_card.dart';
import 'package:swiss_gold/core/utils/widgets/custom_card.dart';
import 'package:swiss_gold/core/view_models/category_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/views/product_view/product_view.dart';

class ProductListView extends StatefulWidget {
  final String? cId;
  final String? tag;
  const ProductListView({super.key, this.cId, this.tag});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController searchController = TextEditingController();
  List<Product> filteredProductList = [];
  double price = 0;
  double goldBid = 0;
  double silverBid = 0;
  double copperBid = 0;
  double platinumBid = 0;

  double getPrice(int index) {
    final model = context.watch<ProductViewModel>();
    final product = filteredProductList[index];
    if (model.marketModel != null) {
      if (model.marketModel!.symbol.toLowerCase() == 'gold') {
        goldBid = model.marketModel!.bid;
        // print('hello sdfsdf${model.marketModel!.bid}');
      }
      if (model.marketModel!.symbol.toLowerCase() == 'silver') {
        silverBid = model.marketModel!.bid;
        // print('hello silver${model.marketModel!.bid}');
      }

      if (model.marketModel!.symbol.toLowerCase() == 'platinum') {
        platinumBid = model.marketModel!.bid;
        // print('hello sdfsdf${model.marketModel!.bid}');
      }

      if (model.marketModel!.symbol.toLowerCase() == 'copper') {
        copperBid = model.marketModel!.bid;
        // print('hello sdfsdf${model.marketModel!.bid}');
      }
    }
    // Check product type and calculate price accordingly
    switch (product.type.toLowerCase()) {
      case 'gold':

        // Formula calculation
        price = ((goldBid / 31.103) *
            3.674 *
            filteredProductList[index].weight *
            filteredProductList[index].purity /
            pow(10, filteredProductList[index].purity.toString().length));

        print('Calculated Price for gold: $price');
        break;

      case 'silver':
      
        double grossWeight =
            product.weight.toDouble(); // Product's gross weight
        double purity = product.purity /
            pow(
              10,
              product.purity.toString().length,
            );

        // print('pow of purity $purity');

        // Purity of the product (e.g., 0.995 for 99.5%)

        // Formula calculation
        price = ((silverBid / 31.103) * 3.674 * grossWeight * purity);
                print('Calculated Price for silver : $price');

        break;
      case 'platinum':
        
        double grossWeight =
            product.weight.toDouble(); // Product's gross weight
        double purity = product.purity /
            pow(
              10,
              product.purity.toString().length,
            );

        // Formula calculation
        price = ((platinumBid / 31.103) * 3.674 * grossWeight * purity);
        break;
      case 'copper':
       
        double grossWeight =
            product.weight.toDouble(); // Product's gross weight
        double purity = product.purity /
            pow(
              10,
              product.purity.toString().length,
            );

        // Formula calculation
        price = ((copperBid / 31.103) * 3.674 * grossWeight * purity);
        break;
      default:
        price = model.marketModel!.bid; // Default price
    }

    // log('Price calculated for ${product.type}: $price');
    return price;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)async {
     await  Provider.of<ProductViewModel>(context, listen: false)
          .getRealtimePrices()
          .then((_) {
        if (widget.cId != null && widget.tag == null) {
          final model = context.read<ProductViewModel>();

          model.listProductsFromCategory(
              {'index': '1', 'cId': widget.cId}).then((_) {
            filterProducts();
          });
        }
        if (widget.tag != null && widget.cId == null) {
          context
              .read<ProductViewModel>()
              .listProductsFromTag({'index': '1', 'tag': widget.tag}).then((_) {
            filterProducts();
          });
        }
      });
    });
    searchController.addListener(() {
      filterProducts();
    });
  }

  void filterProducts() {
    final query = searchController.text.toLowerCase();
    final allProducts = context.read<ProductViewModel>().productList;

    setState(() {
      if (query.isEmpty) {
        filteredProductList = allProducts;
      } else {
        filteredProductList = allProducts
            .where((product) =>
                product.title.toLowerCase().contains(query) ||
                product.tags.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100.h),
        child: Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: UIColor.gold,
                ),
              ),
              SizedBox(
                width: 20.w,
              ),
              SizedBox(
                width: 300.w,
                height: 40.h,
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: searchController,
                  style: TextStyle(
                    color: UIColor.gold,
                  ),
                  cursorColor: UIColor.gold,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 4.h, horizontal: 15.w),
                    hintStyle: TextStyle(
                      color: UIColor.gold,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.sp)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35.sp),
                        borderSide: BorderSide(
                          color: UIColor.gold,
                        )),
                    focusColor: UIColor.gold,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: UIColor.gold),
                        borderRadius: BorderRadius.circular(22.sp)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: UIColor.gold,
                        ),
                        borderRadius: BorderRadius.circular(22.sp)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 20.h),
          child: Column(
            children: [
              Consumer<CategoryViewModel>(
                builder: (context, model, child) {
                  if (model.state == ViewState.loading) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            List.generate(5, (index) => CategoryShimmer()),
                      ),
                    );
                  } else if (model.categoryModel == null ||
                      model.categoryModel!.data.isEmpty) {
                    return SizedBox.shrink();
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          model.categoryModel!.data.length,
                          (index) => CategoryCard(
                            img: model.categoryModel!.data[index].cImg,
                            name: model.categoryModel!.data[index].name,
                            onTap: () {
                              context
                                  .read<ProductViewModel>()
                                  .productList
                                  .clear();
                              context
                                  .read<ProductViewModel>()
                                  .listProductsFromCategory({
                                'index': '1',
                                'cId': model.categoryModel!.data[index].cId
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: 20.h,
              ),
              Consumer<ProductViewModel>(builder: (context, model, child) {
                if (model.state == ViewState.loading &&
                    model.marketPriceState == ViewState.loading) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(5, (index) => CategoryShimmer()),
                    ),
                  );
                } else if (filteredProductList.isEmpty ||
                    model.marketModel == null) {
                  return Center(
                    heightFactor: 3.h,
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
                          style:
                              TextStyle(color: UIColor.gold, fontSize: 20.sp),
                        )
                      ],
                    ),
                  );
                } else {
                  return Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 300,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12),
                      itemCount: filteredProductList.length,
                      itemBuilder: (context, index) {
                      
                        return 
                          
                         CustomCard(
                            prodImg: filteredProductList[index].prodImgs[0],
                            title: filteredProductList[index].title,
                            price: price.toStringAsFixed(5),
                            subTitle: filteredProductList[index].type,
                            onTap: () {
                              navigateTo(
                                  context,
                                  ProductView(
                                    prodImg:
                                        filteredProductList[index].prodImgs,
                                    title: filteredProductList[index].title,
                                    pId: filteredProductList[index].pId,
                                    price:  getPrice(index).toString(),
                                    desc: filteredProductList[index].desc,
                                    type: filteredProductList[index].type,
                                    stock: filteredProductList[index].stock,
                                    purity: filteredProductList[index].purity,
                                    weight: filteredProductList[index].weight,
                                  ));
                            },
                          );
                        
                      },
                    ),
                  );
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
