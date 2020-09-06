class User {
  final String id;
  final String email;
  final String username;
  final String token;

  User({this.id, this.email, this.username, this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        email: json['email'],
        username: json['username'],
        token: json['token']);
  }
}
