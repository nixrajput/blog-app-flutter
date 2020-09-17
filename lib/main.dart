import 'package:blog_api_app/constants.dart';
import 'package:blog_api_app/providers/auth_provider.dart';
import 'package:blog_api_app/providers/blog_provider.dart';
import 'package:blog_api_app/providers/user_provider.dart';
import 'package:blog_api_app/screens/add_post_screen.dart';
import 'package:blog_api_app/screens/home_screen.dart';
import 'package:blog_api_app/screens/login_screen.dart';
import 'package:blog_api_app/screens/profile_screen.dart';
import 'package:blog_api_app/screens/register_screen.dart';
import 'package:blog_api_app/screens/settings_screen.dart';
import 'package:blog_api_app/screens/splash_screen.dart';
import 'package:blog_api_app/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
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
                  bodyColor: lightColor,
                  displayColor: lightColor,
                ),
          ),
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
