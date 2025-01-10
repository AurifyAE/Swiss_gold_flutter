import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/wishlist_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/wishlist/widgets/wish_card.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<WishlistViewModel>();
      model.checkGuestMode();
      if (model.isGuest == false) {
        model.getWishlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: TextStyle(color: UIColor.gold, fontSize: 20.sp),
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
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 12.h),
        child: Consumer<WishlistViewModel>(
          builder: (context, model, child) {
            if (model.state == ViewState.loading) {
              return Center(
                child: CircularProgressIndicator(),
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
                      style: TextStyle(color: UIColor.gold, fontSize: 20.sp),
                    )
                  ],
                ),
              );
            } else {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: model.wishlist.length,
                itemBuilder: (context, index) {
                  return WishCard(
                    prodImg: model.wishlist[index].productDetails.images[0],
                    prodTitle: model.wishlist[index].productDetails.title,
                    price: 'Rs. ${model.wishlist[index].productDetails.price}',
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
