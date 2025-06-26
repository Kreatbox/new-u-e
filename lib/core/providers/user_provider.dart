import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart' as app_user;

class UserProvider with ChangeNotifier {
  app_user.User? _user;
  app_user.User? get user => _user;

  Future<void> fetchUserData(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _user = app_user.User(
      id: uid,
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      fatherName: doc['fatherName'],
      motherName: doc['motherName'],
      dateOfBirth: doc['dateOfBirth'],
      email: doc['email'],
      role: doc['role'],
      specialty: doc.data()?['specialty'] ?? '',
      profileImage: doc['photoBase64'],
    );

    await _saveUserToPrefs();
    notifyListeners();
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;
    _user = app_user.User(
      id: uid,
      firstName: prefs.getString('firstName') ?? '',
      lastName: prefs.getString('lastName') ?? '',
      fatherName: prefs.getString('fatherName') ?? '',
      motherName: prefs.getString('motherName') ?? '',
      dateOfBirth: prefs.getString('dateOfBirth') ?? '',
      email: prefs.getString('email') ?? '',
      role: prefs.getString('role') ?? '',
      specialty: prefs.getString('specialty') ?? '',
      profileImage: prefs.getString('photoBase64') ?? '',
    );

    notifyListeners();
  }

  Future<void> _saveUserToPrefs() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', _user!.id);
    await prefs.setString('email', _user!.email);
    await prefs.setString('firstName', _user!.firstName);
    await prefs.setString('lastName', _user!.lastName);
    await prefs.setString('role', _user!.role);
    await prefs.setString('specialty', _user!.specialty ?? '');
    await prefs.setString('photoBase64', _user!.profileImage);
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
