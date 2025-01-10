import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/models/prodcuts/product_model.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'dart:math';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/widgets/cateogory_card.dart';
import 'package:swiss_gold/core/view_models/category_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';
import 'package:swiss_gold/views/home/widgets/custom_section.dart';
import 'package:swiss_gold/views/home/widgets/home_shimmer.dart';
import 'package:swiss_gold/views/products.dart/product_list_view.dart';
import 'package:swiss_gold/core/utils/widgets/prod_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ProductViewModel>();
      viewModel.getBanners();
      viewModel.getToprated();
      viewModel.getNewArrival();
      viewModel.getBestSeller();
      context.read<CategoryViewModel>().getCategory();
    });
  }

  Widget buildSection({
    required String title,
    required ViewState state,
    required ProductModel? model,
    required VoidCallback onTap,
  }) {
    if (state == ViewState.loading) {
      return HomeShimmer();
    } else if (model == null || model.data.isEmpty) {
      return SizedBox.shrink();
    } else {
      return CustomSection(
        sectionTitle: title,
        onTap: onTap,
        sectionData: List.generate(
          min(3, model.data.length),
          (index) => ProdCard(
            prodImg: model.data[index].prodImgs[0],
            title: model.data[index].title,
            price: 'Rs ${model.data[index].price}',
            subTitle: model.data[index].tags,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
        child: ListView(
          children: [
            Consumer<ProductViewModel>(
              builder: (context, model, child) => model.banners!.isEmpty
                  ? HomeShimmer()
                  : CarouselSlider(
                      items: List.generate(model.banners!.length, (index) {
                        return Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: UIColor.gold),
                              borderRadius: BorderRadius.circular(12.sp),
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      model.banners[index]))),
                        );
                      }),
                      options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 4,
                          viewportFraction: 1,
                          height: 200)),
            ),
            SizedBox(
              height: 20.h,
            ),
            Consumer<CategoryViewModel>(
              builder: (context, model, child) {
                if (model.state == ViewState.loading) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(5, (index) => CategoryShimmer()),
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
                        (index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: CategoryCard(
                            img: model.categoryModel!.data[index].cImg,
                            name: model.categoryModel!.data[index].name,
                            onTap: () {
                              context
                                  .read<ProductViewModel>()
                                  .productList
                                  .clear();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductListView(
                                    cId: model.categoryModel!.data[index].cId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: 10.h,
            ),

            Consumer<ProductViewModel>(
              builder: (context, model, child) => buildSection(
                  title: 'Top Rated',
                  state: model.topRatedState,
                  model: model.topRatedModel,
                  onTap: () {
                    model.productList.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListView(
                          tag: 'Top Rated',
                        ),
                      ),
                    );
                  }),
            ),

            // New Arrival products section
            Consumer<ProductViewModel>(
              builder: (context, model, child) => buildSection(
                  title: 'New Arrival',
                  state: model.newArrivalState,
                  model: model.newArrivalModel,
                  onTap: () {
                    model.productList.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListView(
                          tag: 'New Arrival',
                        ),
                      ),
                    );
                  }),
            ),

            // Best Seller products section
            Consumer<ProductViewModel>(
              builder: (context, model, child) => buildSection(
                title: 'Best Seller',
                state: model.bestSellerState,
                model: model.bestSellerModel,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListView(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
