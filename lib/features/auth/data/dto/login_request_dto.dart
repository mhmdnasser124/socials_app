class LoginRequestDto {
  final String username;
  final String password;

  LoginRequestDto({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }
}
