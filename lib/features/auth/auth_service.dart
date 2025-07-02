import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:universal_exam/core/providers/user_provider.dart';

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
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String photoBase64 = "";
      if (profileImage != null) {
        Uint8List compressedImage = await _compressImage(profileImage);
        photoBase64 = base64Encode(compressedImage);
      }

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
        'specialty': specialty,
        'verified': false,
      });

      await Provider.of<UserProvider>(context, listen: false)
          .fetchUserData(cred.user!.uid);

      return cred.user!.uid;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            return 'البريد الإلكتروني مستخدم بالفعل.';
          case 'weak-password':
            return 'كلمة المرور ضعيفة جدًا.';
          case 'invalid-email':
            return 'البريد الإلكتروني غير صحيح.';
          default:
            return 'خطأ في التسجيل: ${e.message}';
        }
      }
      return 'حدث خطأ غير متوقع أثناء التسجيل.';
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await Provider.of<UserProvider>(context, listen: false)
          .fetchUserData(cred.user!.uid);

      return cred.user!.uid;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            return 'لم يتم العثور على المستخدم.';
          case 'wrong-password':
            return 'كلمة المرور غير صحيحة.';
          case 'invalid-email':
            return 'البريد الإلكتروني غير صحيح.';
          default:
            return 'خطأ في تسجيل الدخول: ${e.message}';
        }
      }
      return 'حدث خطأ أثناء تسجيل الدخول.';
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Provider.of<UserProvider>(context, listen: false).clearUserData();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageData) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      print('Failed to decode image');
      return imageData;
    }

    final resized = img.copyResize(image, width: 128);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  }
}
