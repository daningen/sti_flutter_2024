class User {
  final String authId;
  final String email;
  final String username;
  final List<String> rights;

  User({
    required this.authId,
    required this.email,
    required this.username,
    this.rights = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      authId: json['authId'],
      email: json['email'],
      username: json['username'],
      rights: List<String>.from(json['rights']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authId': authId,
      'email': email,
      'username': username,
      'rights': rights,
    };
  }
}
