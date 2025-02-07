import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/global_variables.dart';
import 'package:swiss_gold/core/services/fcm_service.dart';
import 'package:swiss_gold/core/utils/theme.dart';
import 'package:swiss_gold/core/view_models/auth_view_model.dart';
import 'package:swiss_gold/core/view_models/cart_view_model.dart';
import 'package:swiss_gold/core/view_models/company_profile_view_model.dart';
import 'package:swiss_gold/core/view_models/order_history_view_model.dart';
import 'package:swiss_gold/core/view_models/product_view_model.dart';
import 'package:swiss_gold/core/view_models/profile_view_model.dart';
import 'package:swiss_gold/core/view_models/wishlist_view_model.dart';
import 'package:swiss_gold/firebase_options.dart';
import 'package:swiss_gold/views/splash/splash_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.setupFlutterNotifications();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(414, 896),
      child: MultiProvider(
         providers: [
          ChangeNotifierProvider(create: (context) => AuthViewModel()),
          ChangeNotifierProvider(create: (context) => ProductViewModel()),
          ChangeNotifierProvider(create: (context) => CartViewModel()),
          ChangeNotifierProvider(create: (context) => ProfileViewModel()),
          ChangeNotifierProvider(create: (context) => WishlistViewModel()),
          ChangeNotifierProvider(create: (context) => CompanyProfileViewModel()),
            ChangeNotifierProvider(create: (context) => OrderHistoryViewModel())


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
