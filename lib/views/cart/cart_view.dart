import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/views/cart/widgets/cart_card.dart';
import 'package:swiss_gold/views/login/login_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  int? selectedProdIndex;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<CartViewModel>();
      model.checkGuestMode().then((_){
         if (model.isGuest == false) {
        model.getCart();
      }
      });
     
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 12.h),
      child: Consumer<CartViewModel>(
        builder: (context, model, child) {
          if (model.state == ViewState.loading) {
            return Center(
              child: CircularProgressIndicator(
              color: UIColor.gold,
              ),
            );
          }
            else if (model.isGuest == true) {
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
          }
            else if (model.cartModel == null ||
                  model.cartModel!.data.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ImageAssets.emptycart,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Your Swiss Gold Cart is empty",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: UIColor.gold, fontSize: 20.sp),
                  )
                ],
              ),
            );
          } 
        
          else {
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: model.cartList.length,
              itemBuilder: (context, index) {
                return CartCard(
                  prodImg: model.cartList[index].productDetails.images[0],
                  prodTitle: model.cartList[index].productDetails.title,
                  price: 'Rs. ${model.cartList[index].productDetails.price}',
                  state: index == selectedProdIndex &&
                      (model.quantityState == ViewState.loading),
                  onDecrementTapped: () {
                    model.decrementQuantity(
                        {'pId': model.cartList[index].productId}, index);
                    selectedProdIndex = index;
                  },
                  onIncrementTapped: () {
                    selectedProdIndex = index;

                    model.incrementQuantity(
                        {'pId': model.cartList[index].productId}, index);
                  },
                  quantity: model.cartList[index].quantity,
                  onRemoveTapped: () {
                    model.deleteFromCart({
                      'pId': model.cartList[index].productId
                    }).then((response) {
                      if (response!.success == true) {
                        model.cartList.removeAt(index);
                      }
                      customSnackBar(
                          context: context, title: response.message.toString());
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
