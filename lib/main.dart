import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/global_variables.dart';
import 'package:swiss_gold/core/models/admin_profile_model.dart';
import 'package:swiss_gold/core/utils/theme.dart';
import 'package:swiss_gold/core/view_models/auth_view_model.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/category_view_model.dart';
import 'package:swiss_gold/core/view_models/company_profile_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/view_models/profile_view_model.dart';
import 'package:swiss_gold/core/view_models/wishlist_view_model.dart';
import 'package:swiss_gold/views/splash/splash_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(414, 896),
      child: MultiProvider(
         providers: [
          ChangeNotifierProvider(create: (context) => AuthViewModel()),
          ChangeNotifierProvider(create: (context) => ProductViewModel()),
          ChangeNotifierProvider(create: (context) => CategoryViewModel()),
          ChangeNotifierProvider(create: (context) => CartViewModel()),
          ChangeNotifierProvider(create: (context) => ProfileViewModel()),
          ChangeNotifierProvider(create: (context) => WishlistViewModel()),
          ChangeNotifierProvider(create: (context) => CompanyProfileViewModel()),


          ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Swiss Gold',
          theme: CustomTheme.theme,
                    scaffoldMessengerKey: scaffoldMessengerKey,
        
          home: SplashView(),
        ),
      ),
    );
  }
}
