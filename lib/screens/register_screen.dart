import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/helpers/http_exception.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = 'register-screen';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var _email = '';
  var _username = '';
  var _password = '';
  var _password2 = '';
  bool _obscureText = true;
  bool _isLoading = false;
  var _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var _errorMessage = "Registration failed.";

  String emailValidator = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+";

  void _trySubmit() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .register(_email, _username, _password, _password2,
                DateTime.now().toString())
            .then((value) {
          final SnackBar _snackBar = SnackBar(
            content: Text("Registration successful."),
          );
          _scaffoldKey.currentState.showSnackBar(_snackBar);
          Timer(Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          });
        });
      } on HttpException catch (error) {
        print(error.toString());
        if (error.toString().contains('EMAIL_EXISTS')) {
          _errorMessage = "This email is already in use.";
        } else if (error.toString().contains('USERNAME_EXISTS')) {
          _errorMessage = "This username is already in use.";
        }

        final SnackBar _snackBar = SnackBar(
          content: Text(_errorMessage),
          duration: Duration(seconds: 5),
        );
        _scaffoldKey.currentState.showSnackBar(_snackBar);
      } catch (error) {
        const errorMessage = "Registration failed.";
        final SnackBar _snackBar = SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 5),
        );
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

  Widget loadingScreen() {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: Offset(0.0, 0.0),
              blurRadius: 20.0,
              color: Colors.grey.withOpacity(0.5),
            )
          ]),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? loadingScreen()
              : Card(
                  elevation: 8.0,
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
                            "Sign Up".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
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
                                  key: ValueKey('email'),
                                  validator: (value) {
                                    RegExp regExp = RegExp(emailValidator);
                                    if (value.isEmpty) {
                                      return "Email can't be empty!";
                                    } else if (!regExp.hasMatch(value)) {
                                      return "Email is invalid!";
                                    }
                                    return null;
                                  },
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    errorMaxLines: 2,
                                  ),
                                  onSaved: (value) {
                                    _email = value.trim();
                                  },
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
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
                                    errorMaxLines: 2,
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
                                    errorMaxLines: 2,
                                    suffix: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Text(
                                        _obscureText ? "Show" : "Hide",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _password = value.trim();
                                  },
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  key: ValueKey('password2'),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Password can't be empty!";
                                    } else if (value.length < 7) {
                                      return "Password must be at least 8 characters long!";
                                    } else if (value.trim() != _password) {
                                      return "Password doesn't match!";
                                    }
                                    return null;
                                  },
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: "Confirm Password",
                                    errorMaxLines: 2,
                                    suffix: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Text(
                                        _obscureText ? "Show" : "Hide",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _password2 = value.trim();
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          RaisedButton(
                            onPressed: () {
                              _trySubmit();
                            },
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                            child: Text(
                              "Next".toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            color: Theme.of(context).accentColor,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          FlatButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, LoginScreen.routeName);
                            },
                            child: Text(
                              "Login to account".toUpperCase(),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold),
                            ),
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
