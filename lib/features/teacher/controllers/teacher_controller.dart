import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherController {
  final questionController = TextEditingController();
  List<TextEditingController> optionControllers = [];
  String? selectedCorrectAnswer;
  String? selectedSubject;
  String questionType = "MCQ";

  Uint8List? questionImage;

  TeacherController() {
    optionControllers = [TextEditingController(), TextEditingController()];
  }

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
      questionImage = await _compressImage(imageData);
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageData) async {
    img.Image? image = img.decodeImage(imageData);
    if (image == null) return imageData;
    img.Image resized = img.copyResize(image, width: 2000);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }

  void clearImage() {
    questionImage = null;
  }

  Future<void> createQuestion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        selectedSubject == null ||
        questionController.text.isEmpty) {
      return;
    }

    final firestore = FirebaseFirestore.instance;
    List<String> options = [];
    String correctAnswer = "";

    if (questionType == "true_false") {
      options = ["صح", "خطأ"];
      correctAnswer = selectedCorrectAnswer ?? "";
    } else {
      options = optionControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      if (options.length < 2) return;
      correctAnswer = selectedCorrectAnswer ?? "";
    }

    String imageBase64 = "";
    if (questionImage != null) {
      imageBase64 = base64Encode(questionImage!);
    }

    await firestore.collection('questions').add({
      'text': questionController.text,
      'specialty': selectedSubject,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'type': questionType,
      'options': options,
      'correctAnswer': correctAnswer,
      'disabled': false,
      'imageBase64': imageBase64,
    });
    await _updateTopTeacherStats(user.uid, selectedSubject!, firestore);
  }

  Future<void> _updateTopTeacherStats(
      String teacherUid, String specialty, FirebaseFirestore firestore) async {
    final userData = await firestore.collection('users').doc(teacherUid).get();
    final firstName = userData.get('firstName') ?? '';
    final lastName = userData.get('lastName') ?? '';
    final fullName = "$firstName $lastName";
    final photoBase64 = userData.get('photoBase64') ?? '';

    final questionsSnapshot = await firestore
        .collection('questions')
        .where('createdBy', isEqualTo: teacherUid)
        .where('specialty', isEqualTo: specialty)
        .get();

    final totalQuestions = questionsSnapshot.size;
    double totalAvgScore = 0;
    int questionCountWithScores = 0;

    for (var doc in questionsSnapshot.docs) {
      final avgScore =
          doc.data().containsKey('avgScore') ? doc.get('avgScore') as num? : 0;
      totalAvgScore += (avgScore?.toDouble() ?? 0);
      questionCountWithScores++;
    }

    double avgStudentScore = questionCountWithScores > 0
        ? totalAvgScore / questionCountWithScores
        : 0;
    final topTeacherRef = firestore.collection('topTeachers').doc(teacherUid);

    await topTeacherRef.set({
      'teacherId': teacherUid,
      'fullName': fullName,
      'photoBase64': photoBase64,
      'specialty': specialty,
      'avgStudentScore': avgStudentScore,
      'totalQuestions': totalQuestions,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void dispose() {
    questionController.dispose();
    for (var c in optionControllers) {
      c.dispose();
    }
  }
}
