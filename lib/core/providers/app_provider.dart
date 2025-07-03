// app_provider.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_exam/core/app_service.dart';

class AppProvider with ChangeNotifier {
  final AppService _service = AppService();

  List<Map<String, dynamic>> _topStudents = [];
  List<Map<String, dynamic>> _topTeachers = [];
  Map<DateTime, List<String>> _examEvents = {};

  bool _loading = false;

  List<Map<String, dynamic>> get topStudents => _topStudents;
  List<Map<String, dynamic>> get topTeachers => _topTeachers;
  Map<DateTime, List<String>> get examEvents => _examEvents;
  bool get loading => _loading;

  Future<void> initialize() async {
    if (!_loading) {
      _loading = true;
      notifyListeners();

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

  Future<void> _loadAndCacheData() async {
    final students = await _service.fetchTopStudentsWithUserInfo();
    final teachers = await _service.fetchTopTeachersWithUserInfo();
    final exams = await _service.fetchExamEvents();
    _topStudents = _sanitizeMaps(students);
    _topTeachers = _sanitizeMaps(teachers);
    _examEvents = exams;

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
