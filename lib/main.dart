import 'package:flutter/material.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/home_screen.dart';
import 'package:webapp/screens/login_screen.dart';
import 'package:webapp/screens/register_screen.dart';
import 'package:webapp/screens/splash_screen.dart';
import 'package:webapp/services/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFDFDFD),
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CustomPageTransitionBuilder(),
          TargetPlatform.iOS: CustomPageTransitionBuilder(),
        }),
      ),
      home: SplashScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => LoginScreen(),
        RegisterScreen.routeName: (ctx) => RegisterScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        CreateBlogPost.routeName: (ctx) => CreateBlogPost(),
        SplashScreen.routeName: (ctx) => SplashScreen(),
      },
    );
  }
}
