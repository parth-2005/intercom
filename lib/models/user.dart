class User {
  final String username;
  final bool isOnline;

  const User({
    required this.username,
    required this.isOnline,
  });

  User copyWith({
    String? username,
    bool? isOnline,
  }) {
    return User(
      username: username ?? this.username,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
