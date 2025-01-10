import 'package:flutter/material.dart';
import 'package:swiss_gold/core/utils/colors.dart';

class CustomTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: UIColor.bg,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: UIColor.bg,
        unselectedIconTheme: IconThemeData(color: UIColor.white),
        selectedItemColor: UIColor.gold,
        unselectedItemColor: UIColor.kPrimaryTextColor,
       
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        

        backgroundColor: UIColor.bg,
      ),
      useMaterial3: true,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
