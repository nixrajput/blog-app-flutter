import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/constants.dart';
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
import 'package:webapp/screens/user_profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BlogProvider>(
          update: (_, auth, __) => BlogProvider(
            auth.token,
            auth.userId,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          update: (_, auth, __) => UserDataProvider(
            auth.token,
            auth.userId,
          ),
        )
      ],
      child: Consumer<AuthProvider>(
        builder: (_, auth, __) => MaterialApp(
          title: 'BlogAPI',
          debugShowCheckedModeBanner: false,
          theme: lightTheme.copyWith(
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.black,
                  displayColor: Colors.black,
                ),
          ),
          darkTheme: darkTheme.copyWith(
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
              inputDecorationTheme:
                  Theme.of(context).inputDecorationTheme.copyWith(
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      )),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.autoLogin(),
                  builder: (_, authResult) =>
                      authResult.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : LoginScreen(),
                ),
          routes: {
            LoginScreen.routeName: (_) => LoginScreen(),
            RegisterScreen.routeName: (_) => RegisterScreen(),
            HomeScreen.routeName: (_) => HomeScreen(),
            CreateBlogPost.routeName: (_) => CreateBlogPost(),
            SplashScreen.routeName: (_) => SplashScreen(),
            ProfileScreen.routeName: (_) => ProfileScreen(),
            SettingsScreen.routeName: (_) => SettingsScreen(),
            UserProfileScreen.routeName: (_) => UserProfileScreen(),
          },
        ),
      ),
    );
  }
}
