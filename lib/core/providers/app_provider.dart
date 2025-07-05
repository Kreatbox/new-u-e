import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_exam/core/app_service.dart';
import 'package:universal_exam/features/exam/exam_service.dart';
import 'package:universal_exam/core/models/exam_model.dart';
import 'package:universal_exam/core/models/user_model.dart' as app_user;

class AppProvider with ChangeNotifier {
  final AppService _service = AppService();

  List<Map<String, dynamic>> _topStudents = [];
  List<Map<String, dynamic>> _topTeachers = [];
  Map<DateTime, List<String>> _examEvents = {};

  bool _loading = false;
  bool _isFetching = false;
  bool _isInitialized = false;
  bool _isUserFetching = false;

  app_user.User? _user;
  app_user.User? get user => _user;
  bool get isFetching => _isFetching;
  bool get isInitialized => _isInitialized;

  List<Map<String, dynamic>> get topStudents => _topStudents;
  List<Map<String, dynamic>> get topTeachers => _topTeachers;
  Map<DateTime, List<String>> get examEvents => _examEvents;
  bool get loading => _loading;

  void _safeNotifyListeners() {
    if (_isInitialized) {
      Future.microtask(() {
        if (_isInitialized) {
          notifyListeners();
        }
      });
    }
  }

  Future<void> initialize() async {
    if (!_loading) {
      _loading = true;
      notifyListeners();

      await loadUserFromPrefs();

      final shouldFetch = await _service.shouldFetchData();
      if (shouldFetch) {
        await _loadAndCacheData();
      } else {
        await _readFromStorage();
      }

      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserData(String uid) async {
    if (_isUserFetching) return;
    
    try {
      _isUserFetching = true;
      _isFetching = true;
      _safeNotifyListeners();
      
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) {
        await clearUserData();
        return;
      }

      final data = doc.data()!;
      _user = app_user.User.fromJson(data);

      await _saveUserToPrefs();
      _isFetching = false;
      _isUserFetching = false;
      _safeNotifyListeners();
    } catch (e) {
      print("Error fetching user data: $e");
      _isFetching = false;
      _isUserFetching = false;
      await clearUserData();
      _safeNotifyListeners();
    }
  }

  Future<void> loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString('user_data');

      if (userDataJson == null) {
        _isInitialized = true;
        _safeNotifyListeners();
        return;
      }

      final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
      _user = app_user.User.fromJson(userData);
      _isInitialized = true;
      _safeNotifyListeners();
    } catch (e) {
      print("Error loading user from prefs: $e");
      _isInitialized = true;
      _safeNotifyListeners();
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
      _isFetching = false;
      _safeNotifyListeners();
    } catch (e) {
      print("Error clearing user data: $e");
    }
  }

  Future<void> _loadAndCacheData() async {
    final students = await _service.fetchTopStudentsWithUserInfo();
    final teachers = await _service.fetchTopTeachersWithUserInfo();
    final exams = await _service.fetchExamEvents();
    _topStudents = _sanitizeMaps(students);
    _topTeachers = _sanitizeMaps(teachers);
    _examEvents = exams;
    
    final examsSnapshot =
        await FirebaseFirestore.instance.collection('exams').get();
    final now = DateTime.now();
    
    for (var doc in examsSnapshot.docs) {
      final data = doc.data();
      final exam = Exam.fromJson(doc.id, data);
      final examEndTime = exam.date.add(Duration(minutes: exam.duration));
      
      // Check if exam is finished and needs calculation
      if (exam.isActive && 
          now.isAfter(examEndTime) && 
          (data['calculated'] != true)) {
        await ExamService().calculateExamStatsIfNeeded(exam);
      }
    }

    await _cacheToStorage();
    await _service.markDataFetched();
  }

  List<Map<String, dynamic>> _sanitizeMaps(List<Map<String, dynamic>> list) {
    return list.map((item) {
      final clean = <String, dynamic>{};

      item.forEach((key, value) {
        if (value is DateTime || value is Timestamp) {
          return;
        }
        if (value is String || value is num || value is bool || value == null) {
          clean[key] = value;
        } else if (value is Map || value is List) {
          try {
            jsonEncode(value);
            clean[key] = value;
          } catch (e) {}
        }
      });

      return clean;
    }).toList();
  }

  Future<void> _cacheToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final studentJson = jsonEncode(_topStudents);
    final teacherJson = jsonEncode(_topTeachers);

    final examMap = _examEvents.map((date, titles) => MapEntry(
          date.toIso8601String(),
          titles,
        ));
    final examJson = jsonEncode(examMap);

    await prefs.setString('top_students', studentJson);
    await prefs.setString('top_teachers', teacherJson);
    await prefs.setString('exam_events', examJson);
  }

  Future<void> _readFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final studentJson = prefs.getString('top_students');
    final teacherJson = prefs.getString('top_teachers');
    final examJson = prefs.getString('exam_events');

    if (studentJson != null) {
      final List<dynamic> decoded = jsonDecode(studentJson);
      _topStudents = decoded.cast<Map<String, dynamic>>();
    }

    if (teacherJson != null) {
      final List<dynamic> decoded = jsonDecode(teacherJson);
      _topTeachers = decoded.cast<Map<String, dynamic>>();
    }

    if (examJson != null) {
      final Map<dynamic, dynamic> decoded = jsonDecode(examJson);
      final Map<DateTime, List<String>> parsed = {};
      decoded.forEach((key, value) {
        parsed[DateTime.parse(key)] = List<String>.from(value);
      });
      _examEvents = parsed;
    }
  }

  Future<void> refreshData() async {
    await _loadAndCacheData();
    notifyListeners();
  }
}
