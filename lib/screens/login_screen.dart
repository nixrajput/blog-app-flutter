import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/helpers/http_exception.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/screens/home_screen.dart';
import 'package:webapp/screens/register_screen.dart';
import 'package:webapp/widgets/card/custom_body_card.dart';
import 'package:webapp/widgets/loaders/custom_loading_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _username;
  var _password;
  bool _obscureText = true;
  var _isLoading = false;
  var _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var _errorMessage = "Authentication failed.";

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .login(_username, _password)
            .then((_) {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        });
      } on HttpException catch (error) {
        print(error.toString());
        if (error.toString().contains('INVALID_USERNAME')) {
          _errorMessage = "Username is incorrect.";
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          _errorMessage = "Password is incorrect.";
        }

        final SnackBar _snackBar = SnackBar(content: Text(_errorMessage));
        _scaffoldKey.currentState.showSnackBar(_snackBar);
      } catch (error) {
        print(error.toString());
        final SnackBar _snackBar = SnackBar(content: Text(error.toString()));
        _scaffoldKey.currentState.showSnackBar(_snackBar);
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? CustomLoadingScreen()
              : CustomBodyCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 40.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "BlogAPI",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 40.0,
                            ),
                          ),
                          Text(
                            "A Blogging World",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Sign In".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Form(
                            key: _formKey,
                            autovalidate: _autoValidate,
                            child: Column(
                              children: [
                                TextFormField(
                                  key: ValueKey('username'),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Username can't be empty!";
                                    } else if (value.length < 3) {
                                      return "Username must be at least 3 characters long!";
                                    }
                                    return null;
                                  },
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  decoration: InputDecoration(
                                    labelText: "Username",
                                  ),
                                  onSaved: (value) {
                                    _username = value.trim();
                                  },
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  key: ValueKey('password'),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Password can't be empty!";
                                    } else if (value.length < 7) {
                                      return "Password must be at least 8 characters long!";
                                    }
                                    return null;
                                  },
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    suffix: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Text(
                                        _obscureText ? "Show" : "Hide",
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onSaved: (value) {
                                    _password = value.trim();
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Forgot Password?",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          RaisedButton(
                            onPressed: () {
                              _trySubmit();
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                            child: Text(
                              "Login".toUpperCase(),
                              style: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          FlatButton(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, RegisterScreen.routeName);
                            },
                            child: Text(
                              "Create an Account".toUpperCase(),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
