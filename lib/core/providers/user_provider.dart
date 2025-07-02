import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart' as app_user;

class UserProvider with ChangeNotifier {
  app_user.User? _user;
  app_user.User? get user => _user;

  Future<void> fetchUserData(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        clearUserData();
        return;
      }

      final data = doc.data()!;
      _user = app_user.User.fromJson(data);

      await _saveUserToPrefs();
      notifyListeners();
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString('user_data');

      if (userDataJson == null) return;

      final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
      _user = app_user.User.fromJson(userData);

      notifyListeners();
    } catch (e) {
      print("Error loading user from prefs: $e");
    }
  }

  Future<void> _saveUserToPrefs() async {
    if (_user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = _user!.toJson();

      await prefs.setString('user_data', jsonEncode(userData));
    } catch (e) {
      print("Error saving user to prefs: $e");
    }
  }

  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      _user = null;
      notifyListeners();
    } catch (e) {
      print("Error clearing user data: $e");
    }
  }
}
