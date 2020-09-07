import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/helpers/custom_route.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/screens/add_post_screen.dart';
import 'package:webapp/screens/home_screen.dart';
import 'package:webapp/screens/login_screen.dart';
import 'package:webapp/screens/register_screen.dart';
import 'package:webapp/screens/splash_screen.dart';

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
            previousBlogPosts == null ? [] : previousBlogPosts.blogPosts,
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
              ? HomeScreen()
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
            HomeScreen.routeName: (ctx) => HomeScreen(),
            CreateBlogPost.routeName: (ctx) => CreateBlogPost(),
            SplashScreen.routeName: (ctx) => SplashScreen(),
          },
        ),
      ),
    );
  }
}
