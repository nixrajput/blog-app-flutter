import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/widgets/app_bar/custom_app_bar.dart';
import 'package:webapp/widgets/image_helper/image_picker.dart';

class CreateBlogPost extends StatefulWidget {
  static const routeName = 'add-post-screen';

  @override
  _CreateBlogPostState createState() => _CreateBlogPostState();
}

class _CreateBlogPostState extends State<CreateBlogPost>
    with AutomaticKeepAliveClientMixin {
  File _userImageFile;
  var _postTitle;
  var _postBody;
  var _isLoading = false;
  var _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  void _pickImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null) {
      final _snackBar = SnackBar(
        content: Text('Please add an image first.'),
        duration: Duration(seconds: 5),
      );
      _scaffoldKey.currentState.showSnackBar(_snackBar);
      return;
    }

    if (isValid) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<BlogProvider>(context, listen: false)
            .createPost(
          _userImageFile,
          _postTitle,
          _postBody,
          DateTime.now().toString(),
        )
            .then((_) {
          final _snackBar = SnackBar(
            content: Text('Post added successfully.'),
          );
          _scaffoldKey.currentState.showSnackBar(_snackBar);
          Timer(Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        });
      } catch (error) {
        print(error.toString());
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
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomAppBar(
                      "Add Post",
                      IconButton(
                        icon: Icon(
                          Icons.save,
                          size: 32.0,
                          color: Theme.of(context).accentColor,
                        ),
                        onPressed: _trySubmit,
                      ),
                      Icons.arrow_back,
                      () {
                        Navigator.pop(context);
                      },
                    ),
                    CustomImagePicker(
                      _pickImage,
                    ),
                    SizedBox(height: 10.0),
                    Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: TextFormField(
                            key: ValueKey('title'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Title can't be empty!";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: "Title", errorMaxLines: 2),
                            onSaved: (value) {
                              _postTitle = value.trim();
                            },
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: TextFormField(
                            maxLength: 1000,
                            key: ValueKey('body'),
                            decoration: InputDecoration(
                                labelText: "Write something", errorMaxLines: 2),
                            onSaved: (value) {
                              _postBody = value.trim();
                            },
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
