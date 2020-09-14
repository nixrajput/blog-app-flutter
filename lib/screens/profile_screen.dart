import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/auth_provider.dart';
import 'package:webapp/providers/blog_provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/widgets/app_bar/custom_app_bar.dart';
import 'package:webapp/widgets/bottom_sheet/bottom_sheet_button.dart';
import 'package:webapp/widgets/choosers/custom_date_chooser.dart';
import 'package:webapp/widgets/image_helper/rounded_network_image.dart';
import 'package:webapp/widgets/post/custom_body_text.dart';
import 'package:webapp/widgets/post/post_item.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "profile-screen";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var _firstName;
  var _lastName;
  var _phone;
  var _dob;
  File _userImageFile;
  var _isLoading = false;
  var _isEditing = false;
  var _autoValidate = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final _pickedImage = await picker.getImage(
      source: source,
      imageQuality: 50,
    );

    if (_pickedImage != null) {
      File _croppedFile = await ImageCropper.cropImage(
          sourcePath: _pickedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Theme.of(context).canvasColor,
              toolbarTitle: "Crop Image",
              backgroundColor: Theme.of(context).canvasColor),
          iosUiSettings: IOSUiSettings(
            title: "Crop Image",
            minimumAspectRatio: 1.0,
          ));

      setState(() {
        _userImageFile = _croppedFile;
      });
    }
  }

  Widget actionButton(BuildContext context, dob) {
    return _isEditing
        ? IconButton(
            icon: Icon(
              Icons.save,
              size: 32.0,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              _saveUserData(dob);
            },
          )
        : IconButton(
            icon: Icon(
              Icons.edit,
              size: 32.0,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<AuthProvider>(context, listen: false);
    final _currentUserData =
        Provider.of<UserDataProvider>(context, listen: true).currentUserData;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              _currentUserData.first.username,
              actionButton(context, _currentUserData.first.dob),
              Icons.arrow_back,
              _isEditing
                  ? () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    }
                  : () {
                      Navigator.pop(context);
                    },
            ),
            if (_isLoading) SizedBox(height: 20.0),
            if (_isLoading) CircularProgressIndicator(),
            if (_isLoading) SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                child: _isEditing
                    ? buildProfileEditScreen(
                        context,
                        _currentUserData,
                      )
                    : buildProfileScreen(
                        context,
                        _currentUserData,
                        _auth,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileScreen(BuildContext context, currentUserData, auth) {
    return Column(
      children: [
        SizedBox(height: 20.0),
        _imageArea(context, currentUserData.first),
        SizedBox(height: 20.0),
        CustomBodyText(
          title: "Name",
          value:
              "${currentUserData.first.firstName} ${currentUserData.first.lastName}",
        ),
        CustomBodyText(
          title: "Email",
          value: "${currentUserData.first.email}",
        ),
        CustomBodyText(
          title: "Phone",
          value: "${currentUserData.first.phone}",
        ),
        CustomBodyText(
          title: "Birth Date",
          value: "${currentUserData.first.dob}",
        ),
        Divider(
          color: Theme.of(context).accentColor,
        ),
        FutureBuilder(
          future: Provider.of<BlogProvider>(context, listen: false)
              .fetchUserBlogPost(auth.userId),
          builder: (_, _snapshot) {
            if (_snapshot.hasError) {
              print("${_snapshot.error}");
            }
            if (_snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return Consumer<BlogProvider>(
              builder: (_, _blogPostData, __) =>
                  _blogPostData.blogPosts.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: _blogPostData.blogPosts.length,
                          itemBuilder: (_, i) => BlogPostItem(
                            title: _blogPostData.blogPosts[i].title,
                            body: _blogPostData.blogPosts[i].body,
                            imageUrl: _blogPostData.blogPosts[i].imageUrl,
                            slug: _blogPostData.blogPosts[i].slug,
                            author: _blogPostData.blogPosts[i].author,
                            authorId: _blogPostData.blogPosts[i].authorId,
                            profilePicUrl: currentUserData.first.image,
                            likeCount: _blogPostData.blogPosts[i].likes.length
                                .toString(),
                            isLiked: _blogPostData.blogPosts[i].isLiked,
                            timestamp: TimeAgo.getTimeAgo(DateTime.parse(
                                _blogPostData.blogPosts[i].timestamp)),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.0,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "No post available.",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    if (pickedDate != null) {
      setState(() {
        _dob = DateFormat("y-MM-dd").format(pickedDate);
      });
    }
  }

  void _saveUserData(dob) async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_dob == null && dob == null) {
      final SnackBar _snackBar =
          SnackBar(content: Text("Birth Date can't be empty."));
      _scaffoldKey.currentState.showSnackBar(_snackBar);
      return;
    } else if (_dob != null) {
      setState(() {
        _dob = _dob;
      });
    } else {
      setState(() {
        _dob = dob;
      });
    }

    if (isValid) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<UserDataProvider>(context, listen: false)
            .updateUserData(
          _firstName,
          _lastName,
          _phone,
          _dob,
          DateTime.now().toString(),
        )
            .then((_) {
          final SnackBar _snackBar =
              SnackBar(content: Text("Data saved successfully."));
          _scaffoldKey.currentState.showSnackBar(_snackBar);
        });
      } catch (error) {
        print(error.toString());
        var errorMessage = "${error.toString()}";
        final SnackBar _snackBar = SnackBar(content: Text(errorMessage));
        _scaffoldKey.currentState.showSnackBar(_snackBar);
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
      return;
    }
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
  }

  Widget buildProfileEditScreen(BuildContext context, currentUserData) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 20.0),
            TextFormField(
              initialValue: currentUserData.first.firstName == null
                  ? ''
                  : "${currentUserData.first.firstName}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor),
              key: ValueKey('first_name'),
              validator: (value) {
                if (value.isEmpty) {
                  return "First Name can't be empty!";
                } else if (value.length < 3) {
                  return "First Name must be at least 3 characters long!";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "First Name",
                errorMaxLines: 2,
              ),
              onSaved: (value) {
                _firstName = value.trim();
              },
            ),
            SizedBox(height: 10.0),
            TextFormField(
              initialValue: currentUserData.first.lastName == null
                  ? ''
                  : "${currentUserData.first.lastName}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor),
              key: ValueKey('last_name'),
              validator: (value) {
                if (value.isEmpty) {
                  return "Last Name can't be empty!";
                } else if (value.length < 3) {
                  return "Last Name must be at least 3 characters long!";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Last Name",
                errorMaxLines: 2,
              ),
              onSaved: (value) {
                _lastName = value.trim();
              },
            ),
            SizedBox(height: 10.0),
            TextFormField(
              initialValue: currentUserData.first.phone == null
                  ? ''
                  : "${currentUserData.first.phone}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor),
              key: ValueKey('phone'),
              validator: (value) {
                if (value.length < 10) {
                  return "Phone Number is invalid!";
                }
                return null;
              },
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone",
                errorMaxLines: 2,
              ),
              onSaved: (value) {
                _phone = value.trim();
              },
            ),
            SizedBox(height: 10.0),
            CustomDateChooser(
              labelText: "Birth Date",
              valueText: _dob == null
                  ? (currentUserData.first.dob == null
                      ? 'Select Date'
                      : currentUserData.first.dob)
                  : _dob,
              onPressed: _selectDate,
            )
          ],
        ),
      ),
    );
  }

  void _uploadProfilePicture() async {
    if (_userImageFile == null) {
      final _snackBar = SnackBar(
        content: Text('Please add an image first.'),
      );
      _scaffoldKey.currentState.showSnackBar(_snackBar);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Provider.of<UserDataProvider>(context, listen: false)
        .uploadProfilePicture(
      _userImageFile,
      DateTime.now().toString(),
    );

    setState(() {
      _isLoading = false;
      _userImageFile = null;
    });
  }

  void _showImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        context: context,
        builder: (ctx) => Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BottomSheetButton(
                    title: "Camera",
                    icon: Icons.camera,
                    onTap: () async {
                      await _pickImage(ImageSource.camera);
                    },
                  ),
                  BottomSheetButton(
                    title: "Gallery",
                    icon: Icons.photo,
                    onTap: () async {
                      await _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ));
  }

  Widget _imageArea(BuildContext context, user) {
    return user.image == null
        ? _userImageFile != null
            ? GestureDetector(
                onTap: () {
                  _showImageBottomSheet(context);
                },
                child: Column(
                  children: [
                    Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(_userImageFile),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      onPressed: _uploadProfilePicture,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 40.0),
                      color: Theme.of(context).accentColor,
                      textColor: Theme.of(context).scaffoldBackgroundColor,
                      child: Text("Save"),
                    )
                  ],
                ),
              )
            : GestureDetector(
                onTap: () {
                  _showImageBottomSheet(context);
                },
                child: Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "Add Image",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ),
              )
        : _userImageFile != null
            ? GestureDetector(
                onTap: () {
                  _showImageBottomSheet(context);
                },
                child: Column(
                  children: [
                    Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(_userImageFile),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                      onPressed: _uploadProfilePicture,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 40.0),
                      color: Theme.of(context).accentColor,
                      textColor: Theme.of(context).scaffoldBackgroundColor,
                      child: Text("Save"),
                    )
                  ],
                ),
              )
            : GestureDetector(
                onTap: () {
                  _showImageBottomSheet(context);
                },
                child: RoundedNetworkImage(
                  imageSize: 200.0,
                  imageUrl: user.image,
                  strokeWidth: 4.0,
                  strokeColor: Theme.of(context).accentColor,
                ),
              );
  }
}
