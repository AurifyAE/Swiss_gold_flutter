import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/product_service.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/view_models/wishlist_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/products/product_view.dart';
import 'package:swiss_gold/views/wishlist/widgets/wish_card.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {

    double goldBid = 0;
  double goldPrice = 0;


  @override
  void initState() {
    super.initState();
 context.read<ProductViewModel>().getSpotRate();
    

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<WishlistViewModel>();

      model.checkGuestMode();
                                    model.getWishlist();

      if (model.isGuest == false) {

         ProductService.marketDataStream.listen((marketData) {
      // Store prices based on the symbol
      String symbol = marketData['symbol'].toString().toLowerCase();

      if (mounted) {
        // Check if the widget is still mounted
        if (symbol == 'gold') {
          setState(() {
            goldBid = (marketData['bid'] is int)
                ? (marketData['bid'] as int).toDouble()
                : marketData['bid'];
          });
        }

        
        
       
      }
    });

      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: TextStyle(color: UIColor.gold, fontSize: 20.sp, fontFamily: 'Familiar',
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Consumer<WishlistViewModel>(
          builder: (context, model, child) {
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
            } else if (model.wishlistModel == null ||
                model.wishlistModel!.data.isEmpty) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      ImageAssets.emptyWishlist,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "You haven't added any products\n yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: UIColor.gold, fontSize: 20.sp,                fontFamily: 'Familiar',
),
                    )
                  ],
                ),
              );
            } else {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: model.wishlist.length,
                itemBuilder: (context, index) {

                       goldPrice = (((goldBid+ context.read<ProductViewModel>().goldSpotRate!) / 31.103) *
                        3.674 *
                         model.wishlist[index].productDetails.weight *
                          model.wishlist[index].productDetails.purity /
                        pow(
                            10,
                            model.wishlist[index].productDetails.purity
                                .toString()
                                .length)+model.wishlist[index].productDetails.makingCharge );
                       
                         

                 


                  return GestureDetector(
                    onTap: (){
                      navigateWithAnimationTo(
                                  context,
                                  ProductView(
                                    makingCharge:  model.wishlist[index].productDetails.makingCharge,
                                    prodImg: model.wishlist[index].productDetails.images,
                                    title: model.wishlist[index].productDetails.title,
                                    pId: model.wishlist[index].productId,
                                   
                                    desc: model.wishlist[index].productDetails.description,
                                    type: model.wishlist[index].productDetails.type,
                                    stock: true,
                                    purity: model.wishlist[index].productDetails.purity,
                                    weight: model.wishlist[index].productDetails.weight,
                                  ),0,1);

                    },
                    child: WishCard(
                      prodImg: model.wishlist[index].productDetails.images[0],
                      prodTitle: model.wishlist[index].productDetails.title,
                      price:  model.wishlist[index].productDetails.type
                                  .toLowerCase() ==
                              'gold'
                          ? 'AED ${goldPrice.toStringAsFixed(2)}'
                        
                                      : '0.0',
                      onRemoveTapped: () {
                        model.deleteFromWishlist({
                          'pId': model.wishlist[index].productId
                        }).then((response) {
                          if (response!.success == true) {
                            model.wishlist.removeAt(index);
                          }
                          customSnackBar(
                              context: context,
                              title: response.message.toString());
                        });
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
