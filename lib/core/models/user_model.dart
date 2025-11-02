import 'dart:convert';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String? image;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
    };
  }

  String toRawJson() {
    return jsonEncode(toJson());
  }

  factory UserModel.fromRawJson(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  factory UserModel.emptyUser() {
    return UserModel(
      id: 0,
      username: 'UserName',
      email: 'user@example.com',
      firstName: 'FirstName',
      lastName: 'LastName',
      gender: 'male',
      image: null,
    );
  }
}
