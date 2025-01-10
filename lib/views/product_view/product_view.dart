import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_snackbar.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/view_models/wishlist_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';
import 'package:swiss_gold/views/product_view/widgets/custom_tile.dart';

class ProductView extends StatefulWidget {
  final List<String> prodImg;
  final String title;
  final String desc;
  final String price;
  final String pId;
  final int purity;
  final int weight;
  final bool stock;
  final String type;
  const ProductView(
      {super.key,
      required this.prodImg,
      required this.title,
      required this.desc,
      required this.price,
      required this.pId,
      required this.purity,
      required this.weight,
      required this.stock,
      required this.type});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductViewModel>().checkGuestMode();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomOutlinedBtn(
                  btnIcon: PhosphorIcons.shoppingCartSimple(),
                  borderColor: UIColor.gold,
                  borderRadius: 12.sp,
                  iconColor: UIColor.gold,
                  padH: 10.w,
                  padV: 10.h,
                  onTapped: () {
                    if (context.read<ProductViewModel>().isGuest == false) {
                      context.read<CartViewModel>().addToCart({
                        'pId': widget.pId,
                      }).then((response) {
                        customSnackBar(
                            context: context,
                            title: response!.message.toString());
                      });
                    } else {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
                          (route) => false);
                    }
                  }),
              CustomOutlinedBtn(
                  btnText: 'Add to wishlist',
                  btnTextColor: UIColor.gold,
                  borderColor: UIColor.gold,
                  borderRadius: 12.sp,
                  padH: 10.w,
                  padV: 10.h,
                  fontSize: 18.sp,
                  onTapped: () {
                    if (context.read<ProductViewModel>().isGuest == false) {
                      context
                          .read<WishlistViewModel>()
                          .addToWishlist({'pId': widget.pId}).then((response) {
                        customSnackBar(
                            context: context,
                            title: response!.message.toString());
                      });
                    } else {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginView()),
                          (route) => false);
                    }
                  })
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: UIColor.gold,
              )),
        ),
        body: SingleChildScrollView(
          physics: PageScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 400.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.sp)),
                    child: CachedNetworkImage(
                      imageUrl: widget.prodImg[currentIndex],
                      fit: BoxFit.cover,
                    )),
                    SizedBox(height: 20.h,),
                Row(
                  children: List.generate(
                      widget.prodImg.length,
                      (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                            child: Container(
                                height: 40.h,
                                width: 40.w,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 5.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: currentIndex == index
                                            ? UIColor.gold
                                            : UIColor.white),
                                    borderRadius: BorderRadius.circular(12.sp)),
                                child: CachedNetworkImage(
                                  imageUrl: widget.prodImg[index],
                                  fit: BoxFit.cover,
                                )),
                          )),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  widget.title,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: UIColor.secondaryGold,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold),
                ),
                 SizedBox(
                  height: 10.h,
                ),
                Text(
                  widget.type,
                  style: TextStyle(color: UIColor.gold, fontSize: 22.sp),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  widget.price,
                  style: TextStyle(color: UIColor.gold, fontSize: 22.sp),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  widget.desc,
                  style: TextStyle(color: UIColor.gold, fontSize: 18.sp),
                ),
                SizedBox(
                  height: 10.h,
                ),
               CustomProdData(title: 'Purity', data:  widget.purity.toString()),
                SizedBox(
                  height: 10.h,
                ),
              CustomProdData(title: 'Weight', data:  widget.weight.toString()),
                SizedBox(
                  height: 10.h,
                ),
                CustomProdData(title: 'Stock', data: widget.stock?'In Stock':'Out of Stock')
              ],
            ),
          ),
        ),
      ),
    );
  }
}

