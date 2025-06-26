import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> signUpUser({
    required String firstName,
    required String lastName,
    required String fatherName,
    required String motherName,
    required String dateOfBirth,
    required String email,
    required String password,
    required String role,
    required String? specialty,
    required Uint8List? profileImage,
    required BuildContext context,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String photoBase64 = "";
      if (profileImage != null) {
        Uint8List compressedImage = await _compressImage(profileImage);
        photoBase64 = base64Encode(compressedImage);
      }

      final isStudent = role == 'طالب';

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'fatherName': fatherName,
        'motherName': motherName,
        'dateOfBirth': dateOfBirth,
        'email': email,
        'role': role,
        'photoBase64': photoBase64,
        'uid': cred.user!.uid,
        'specialty': isStudent ? specialty : '',
        'varified': 'false'
      });

      await Provider.of<UserProvider>(context, listen: false)
          .fetchUserData(cred.user!.uid);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      await Provider.of<UserProvider>(context, listen: false)
          .fetchUserData(cred.user!.uid);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await Provider.of<UserProvider>(context, listen: false).clearUserData();
  }

  Future<Uint8List> _compressImage(Uint8List imageData) async {
    img.Image? image = img.decodeImage(imageData);
    if (image == null) return imageData;
    img.Image resized = img.copyResize(image, width: 128);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  }
}
