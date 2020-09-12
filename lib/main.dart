import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/helpers/custom_route.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/home_screen.dart';
import 'package:webapp/screens/login_screen.dart';
import 'package:webapp/screens/profile_screen.dart';
import 'package:webapp/screens/register_screen.dart';
import 'package:webapp/screens/settings_screen.dart';
import 'package:webapp/screens/splash_screen.dart';

//flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BlogProvider>(
          update: (ctx, auth, previousBlogPosts) => BlogProvider(
            auth.token,
            auth.userId,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          update: (ctx, auth, previousUserData) => UserDataProvider(
            auth.token,
            auth.userId,
          ),
        )
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'BlogAPI',
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
          home: auth.isAuth
              ? HomeScreen(auth.userId)
              : FutureBuilder(
                  future: auth.autoLogin(),
                  builder: (ctx, authResult) =>
                      authResult.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : LoginScreen(),
                ),
          routes: {
            LoginScreen.routeName: (ctx) => LoginScreen(),
            RegisterScreen.routeName: (ctx) => RegisterScreen(),
            HomeScreen.routeName: (ctx) => HomeScreen(auth.userId),
            CreateBlogPost.routeName: (ctx) => CreateBlogPost(),
            SplashScreen.routeName: (ctx) => SplashScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
          },
        ),
      ),
    );
  }
}
