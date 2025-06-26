import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class TeacherController {
  final questionController = TextEditingController();
  final option1Controller = TextEditingController();
  final option2Controller = TextEditingController();
  final option3Controller = TextEditingController();
  final option4Controller = TextEditingController();
  String? selectedCorrectAnswer;
  String? selectedSubject;

  Uint8List? questionImage;

  TeacherController();

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

    img.Image resized = img.copyResize(image, width: 1080);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }

  void clearImage() {
    questionImage = null;
  }

  Future<void> createQuestion() async {
    print('Creating question...');
    print('Question: ${questionController.text}');
    print('Correct Answer: $selectedCorrectAnswer');
    print('Subject: $selectedSubject');
    print('Image attached: ${questionImage != null}');
  }

  void dispose() {
    questionController.dispose();
    option1Controller.dispose();
    option2Controller.dispose();
    option3Controller.dispose();
    option4Controller.dispose();
  }
}
