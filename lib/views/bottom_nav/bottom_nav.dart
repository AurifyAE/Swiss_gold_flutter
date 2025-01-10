import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/navigate.dart';
import 'package:swiss_gold/views/bottom_nav/no_internet_view.dart';
import 'package:swiss_gold/views/cart/cart_view.dart';
import 'package:swiss_gold/views/support/contact_view.dart';
import 'package:swiss_gold/views/home/home_view.dart';
import 'package:swiss_gold/views/more/more_view.dart';
import 'package:swiss_gold/views/wishlist/wishlist_view.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;
  bool isConnected = true;
  StreamSubscription? internetStreamSubscription;

  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void checkConnection() async {
    // Listen to status changes
    internetStreamSubscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      print(status);

      if (mounted) {
        switch (status) {
          case InternetStatus.connected:
            if (!isConnected) {
              _checkInternetAccess().then((isOnline) {
                if (isOnline) {
                  setState(() {
                    isConnected = true;
                  });
                  print("Internet connected");
                } else {
                  _retryConnection();
                }
              });
            }
            break;
          case InternetStatus.disconnected:
            if (isConnected) {
              setState(() {
                isConnected = false;
              });
              // print("Internet disconnected");
              _retryConnection();
            }
            break;
          default:
            if (isConnected) {
              setState(() {
                isConnected = false;
              });
              _retryConnection();
            }
            break;
        }
      }
    });
  }

  void _retryConnection() async {
    await Future.delayed(Duration(seconds: 5));
    checkConnection(); // Recheck the connection
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  List screens = [HomeView(), CartView(), ContactView(), MoreView()];

  @override
  void initState() {
    super.initState();

    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 70.h),
        child: Padding(
          padding: EdgeInsets.only(top: 8.h, left: 5.w, right: 5.w),
          child: Row(
            
            children: [
              Image.asset(ImageAssets.mainLogo, width: 80.w),
              SizedBox(width: 70.w,),
              Text(
                'Swiss Gold',
                style: TextStyle(color: UIColor.gold, fontSize: 20.sp),
              ),
               
            ],
          ),
        ),
      ),
      body: isConnected
          ? AnimatedSwitcher(
              duration: const Duration(
                  milliseconds: 400), // Duration of the fade effect
              child: screens[currentIndex],
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
            )
          : NoInternetView(onRetry: () {
              _retryConnection();
              // LocalStorage.remove([
              //   'userId',
              //   'userName',
              //   'location',
              //   'mobile',
              //   'category',
              // ]);
            }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          onTapped(index);
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.house(),
                size: 32.sp,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.storefront(), size: 32.sp),
              label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.headphones(),
                size: 32.sp,
              ),
              label: 'Support'),
          BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.gearSix(),
                size: 32.sp,
              ),
              label: 'More'),
        ],
      ),
    );
  }
}
