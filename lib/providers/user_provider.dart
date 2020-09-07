// import 'package:flutter/foundation.dart';
// import 'package:webapp/models/user.dart';
// import 'package:http/http.dart' as http;
//
// class UserDataProvider with ChangeNotifier {
//   List<User> _userData = [];
//
//   final String currentUserId;
//   final String token;
//
//   UserDataProvider(this.currentUserId, this.token, this._userData);
//
//   List<User> get userData {
//     return [..._userData];
//   }
//
//   Future<void> _fetchUserData() async {
//     final response = await http.get(
//       'https://nixlab-blog-api.herokuapp.com/account/details/',
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Token $_token',
//       },
//     );
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       print(responseData);
//       List<User> _fetchedUserData = [];
//
//       _futureUserData.add(
//         User(
//           id: responseData['id'],
//           firstName: responseData['first_name'],
//           lastName: responseData['last_name'],
//           email: responseData['email'],
//           username: responseData['username'],
//           dob: responseData['dob'],
//           phone: responseData['phone'],
//           image: responseData['image']['image'],
//         ),
//       );
//
//       _futureUserData = _fetchedUserData.toList();
//
//     } else {
//       final errorData = jsonDecode(response.body);
//       print(errorData);
//       final _snackBar = SnackBar(content: Text(errorData['detail']));
//       _scaffoldKey.currentState.showSnackBar(_snackBar);
//       return errorData;
//     }
//   }
//
// }
