import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/views/bottom_nav/no_internet_view.dart';
import 'package:swiss_gold/views/cart/cart_view.dart';
import 'package:swiss_gold/views/order_history/order_history.dart';
import 'package:swiss_gold/views/support/contact_view.dart';
import 'package:swiss_gold/views/home/home_view.dart';
import 'package:swiss_gold/views/more/more_view.dart';
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

  List screens = [HomeView(),OrderHistory(), ContactView(), MoreView()];

  @override
  void initState() {
    super.initState();

    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        toolbarHeight: 120.h,
        title: Image.asset(
          ImageAssets.mainLogo,
          width: 250.w,
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
            }),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
          fontFamily: 'Familiar',
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Familiar',
        ),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          onTapped(index);
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.shoppingBagOpen(),
                size: 32.sp,
              ),
              label: 'Shop'
          ),
           BottomNavigationBarItem(
              icon: Icon(
               PhosphorIcons.article(),
                size: 32.sp,
              ),
              label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.headset(),
                size: 32.sp,
              ),
              label: 'Contact'),
             
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
