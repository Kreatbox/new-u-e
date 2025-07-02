import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String dateOfBirth;
  final String email;
  final String role; // "طالب", "أستاذ", "مدير"
  final String specialty;
  final String profileImage;
  final bool verified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.dateOfBirth,
    required this.email,
    required this.role,
    required this.specialty,
    required this.profileImage,
    required this.verified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      dateOfBirth: json['dateOfBirth'],
      email: json['email'],
      role: json['role'],
      specialty: json['specialty'],
      profileImage: json['photoBase64'] ?? '',
      verified: json['verified'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'firstName': firstName,
      'lastName': lastName,
      'fatherName': fatherName,
      'motherName': motherName,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'role': role,
      'specialty': specialty,
      'photoBase64': profileImage,
      'verified': verified,
      'createdAt': createdAt,
    };
  }
}
