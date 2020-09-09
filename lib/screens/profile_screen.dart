import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webapp/providers/user_provider.dart';
import 'package:webapp/widgets/bottom_sheet_button.dart';
import 'package:webapp/widgets/custom_app_bar.dart';
import 'package:webapp/widgets/custom_body_text.dart';
import 'package:webapp/widgets/custom_date_chooser.dart';
import 'package:webapp/widgets/rounded_network_image.dart';

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

  Widget actionButton(dob) {
    return Container(
      child: _isEditing
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
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: FutureBuilder(
            future: Provider.of<UserDataProvider>(context, listen: false)
                .fetchUserData(),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                print('${snapshot.error}');
                return Text('${snapshot.error}');
              }
              return Consumer<UserDataProvider>(
                builder: (ctx, userData, _) => Column(
                  children: [
                    CustomAppBar(userData.userData[0].username,
                        actionButton(userData.userData[0].dob)),
                    SizedBox(height: 20.0),
                    if (_isLoading) CircularProgressIndicator(),
                    if (_isLoading) SizedBox(height: 20.0),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _isEditing
                            ? buildProfileEditScreen(userData.userData[0])
                            : buildProfileScreen(userData.userData[0]),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget buildProfileScreen(user) {
    return Column(
      children: [
        _imageArea(user),
        SizedBox(height: 20.0),
        CustomBodyText(
          title: "Name",
          value: "${user.firstName} ${user.lastName}",
        ),
        CustomBodyText(
          title: "Email",
          value: "${user.email}",
        ),
        CustomBodyText(
          title: "Phone",
          value: "${user.phone}",
        ),
        CustomBodyText(
          title: "Birth Date",
          value: "${user.dob}",
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Future<void> _selectDate() async {
    DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
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

    if (isValid) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      if (_dob != null) {
        try {
          await Provider.of<UserDataProvider>(context, listen: false)
              .updateUserData(
            _firstName,
            _lastName,
            _phone,
            _dob,
            DateTime.now().toString(),
          )
              .then((value) {
            final SnackBar _snackBar =
                SnackBar(content: Text("Data saved successfully."));
            _scaffoldKey.currentState.showSnackBar(_snackBar);
          });
        } on HttpException catch (error) {
          print(error.toString());
          var _errorMessage = "An error occurred.";

          final SnackBar _snackBar = SnackBar(content: Text(_errorMessage));
          _scaffoldKey.currentState.showSnackBar(_snackBar);
        } catch (error) {
          const errorMessage = "An error occurred.";
          final SnackBar _snackBar = SnackBar(content: Text(errorMessage));
          _scaffoldKey.currentState.showSnackBar(_snackBar);
        }
      } else {
        try {
          await Provider.of<UserDataProvider>(context, listen: false)
              .updateUserData(
            _firstName,
            _lastName,
            _phone,
            dob,
            DateTime.now().toString(),
          )
              .then((value) {
            final SnackBar _snackBar =
                SnackBar(content: Text("Data saved successfully."));
            _scaffoldKey.currentState.showSnackBar(_snackBar);
          });
        } on HttpException catch (error) {
          print(error.toString());
          var _errorMessage = "${error.toString()}";

          final SnackBar _snackBar = SnackBar(content: Text(_errorMessage));
          _scaffoldKey.currentState.showSnackBar(_snackBar);
        } catch (error) {
          const errorMessage = "An error occurred.";
          final SnackBar _snackBar = SnackBar(content: Text(errorMessage));
          _scaffoldKey.currentState.showSnackBar(_snackBar);
        }
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
  }

  Widget buildProfileEditScreen(user) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 40.0),
            TextFormField(
              initialValue: user.firstName == null ? '' : "${user.firstName}",
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
              initialValue: user.lastName == null ? '' : "${user.lastName}",
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
              initialValue: user.phone == null ? '' : "${user.phone}",
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
              valueText: _dob == null ? user.dob : _dob,
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

  Widget _imageArea(user) {
    return _userImageFile == null
        ? GestureDetector(
            onTap: () {
              _showImageBottomSheet(context);
            },
            child: RoundedNetworkImage(
              imageSize: 200.0,
              imageUrl: user.image,
              strokeWidth: 4.0,
              strokeColor: Theme.of(context).accentColor,
            ),
          )
        : GestureDetector(
            onTap: () {
              _showImageBottomSheet(context);
            },
            child: _userImageFile != null
                ? Column(
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
                  )
                : Container(
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
          );
  }
}
