import 'package:flutter/material.dart';
import 'package:webapp/helpers/custom_route.dart';

const apiAccountUrl = 'https://nixlab-blog-api.herokuapp.com/account';
const apiBlogUrl = 'https://nixlab-blog-api.herokuapp.com';

final lightTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFFFDFDFD),
  accentColor: Colors.deepPurple,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CustomPageTransitionBuilder(),
      TargetPlatform.iOS: CustomPageTransitionBuilder(),
    },
  ),
);

final darkTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFF121212),
  accentColor: Colors.white,
  primaryTextTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.white),
      bodyText2: TextStyle(color: Colors.white)),
  iconTheme: IconThemeData(color: Colors.white),
  buttonTheme: ButtonThemeData(
      buttonColor: Colors.white,
      focusColor: Colors.white,
      disabledColor: Colors.grey),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Color(0xFF121212),
    modalBackgroundColor: Color(0xFF121212),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CustomPageTransitionBuilder(),
      TargetPlatform.iOS: CustomPageTransitionBuilder(),
    },
  ),
);
