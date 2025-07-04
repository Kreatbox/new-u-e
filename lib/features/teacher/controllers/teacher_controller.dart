import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherController {
  final questionController = TextEditingController();
  late List<TextEditingController> optionControllers = [];

  String? selectedCorrectAnswer;
  String? selectedSubject;
  String questionType = "MCQ";

  Uint8List? questionImage;

  void addOption() {
    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length > 2) {
      optionControllers[index].dispose();
      optionControllers.removeAt(index);
    }
  }

  Future<void> pickQuestionImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final imageData = await imageFile.readAsBytes();
      questionImage = imageData;
    }
  }

  void clearImage() {
    questionImage = null;
  }

  Future<bool> _isDuplicateQuestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedSubject == null) return false;

    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection('questions')
        .where('createdBy', isEqualTo: user.uid)
        .where('text', isEqualTo: questionController.text.trim())
        .get();

    if (querySnapshot.docs.isEmpty) return false;
    if (questionType == "MCQ") {
      final List<String> currentOptions = optionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final duplicateWithSameOptions = querySnapshot.docs.where((doc) {
        final savedOptions = (doc.data()['options'] as List<dynamic>)
            .map((e) => e.toString().trim())
            .toSet();

        return savedOptions.length == currentOptions.length &&
            savedOptions.containsAll(currentOptions);
      }).isNotEmpty;

      return duplicateWithSameOptions;
    }

    return true;
  }

  Future<void> updateQuestion(String questionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        selectedSubject == null ||
        questionController.text.isEmpty) {
      return;
    }

    final firestore = FirebaseFirestore.instance;
    List<String> options = [];

    if (questionType == "MCQ") {
      options = optionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      selectedCorrectAnswer = selectedCorrectAnswer?.trim() ?? options.first;
    } else {
      options = ["صح", "خطأ"];
      selectedCorrectAnswer = selectedCorrectAnswer ?? "صح";
    }

    String? imageBase64;
    if (questionImage != null) {
      imageBase64 = base64Encode(questionImage!);
    }

    await firestore.collection('questions').doc(questionId).update({
      'text': questionController.text.trim(),
      'type': questionType,
      'options': options,
      'correctAnswer': selectedCorrectAnswer,
      'imageBase64': imageBase64 ?? '',
    });
  }

  Future<bool> createQuestion({bool allowDuplicates = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        selectedSubject == null ||
        questionController.text.isEmpty) {
      return false;
    }

    final firestore = FirebaseFirestore.instance;

    if (!allowDuplicates && await _isDuplicateQuestion()) {
      return false;
    }

    List<String> options = [];

    if (questionType == "MCQ") {
      options = optionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      if (options.length < 2) return false;
      selectedCorrectAnswer = selectedCorrectAnswer?.trim() ?? options.first;
    } else {
      options = ["صح", "خطأ"];
      selectedCorrectAnswer = selectedCorrectAnswer ?? "صح";
    }

    String? imageBase64;
    if (questionImage != null) {
      imageBase64 = base64Encode(questionImage!);
    }

    try {
      await firestore.collection('questions').add({
        'text': questionController.text.trim(),
        'specialty': selectedSubject,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'type': questionType,
        'options': options,
        'correctAnswer': selectedCorrectAnswer,
        'disabled': false,
        'imageBase64': imageBase64 ?? '',
      });

      return true;
    } catch (e) {
      debugPrint("Error creating question: $e");
      return false;
    }
  }

  void dispose() {
    questionController.dispose();
    for (var c in optionControllers) {
      c.dispose();
    }
  }
}
