import 'package:flutter/widgets.dart';

class User {
  final ImageProvider<Object>? profileImage;
  final String imagePath;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String degree;
  final String year_of_entry;
  final String gender;
  final bool isDarkMode;
  final String? entry_no;

  const User({
    required this.profileImage,
    required this.name,
    required this.imagePath,
    required this.email,
    required this.phone,
    required this.department,
    required this.degree,
    required this.year_of_entry,
    required this.gender,
    required this.isDarkMode,
    this.entry_no,
  });

  User copyWith({
    String? name,
    String? email,
    String? entry_no,
  }) {
    return User(
      name: name ?? this.name,
      imagePath: this.imagePath,
      profileImage: this.profileImage,
      email: email ?? this.email,
      phone: this.phone,
      department: this.department,
      degree: this.degree,
      year_of_entry: this.year_of_entry,
      gender: this.gender,
      isDarkMode: this.isDarkMode,
      entry_no: entry_no,
    );
  }
}

class GuardUser {
  final ImageProvider<Object>? profileImage;
  final String imagePath;
  final String name;
  final String email;
  final String location;
  final bool isDarkMode;

  const GuardUser({
    required this.imagePath,
    required this.name,
    required this.email,
    required this.location,
    required this.isDarkMode,
    this.profileImage,  
  });
}

class AuthorityUser {
  final String imagePath;
  final String name;
  final String email;
  final String designation;
  final bool isDarkMode;

  const AuthorityUser({
    required this.imagePath,
    required this.name,
    required this.email,
    required this.designation,
    required this.isDarkMode,
  });
}

class AdminUser {
  final String imagePath;
  final String name;
  final String email;
  final bool isDarkMode;

  const AdminUser({
    required this.imagePath,
    required this.name,
    required this.email,
    required this.isDarkMode,
  });
}

