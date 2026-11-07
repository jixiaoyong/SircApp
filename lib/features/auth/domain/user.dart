class User {
  final String username;
  final String? email;

  const User({
    required this.username,
    this.email,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => username.hashCode ^ email.hashCode;

  @override
  String toString() => 'User(username: $username, email: $email)';
}
