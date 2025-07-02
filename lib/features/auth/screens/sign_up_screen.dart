import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import '../utils/sign_up_vaildator.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/constrained_box.dart';
import '../../../shared/widgets/app_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/container.dart';
import '../auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = "طالب";
  String? specialty;
  Uint8List? profileImage;
  bool isLoading = false;
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        profileImage = bytes;
      });
    }
  }

  void _signUp() async {
    String? firstNameError =
        Validator.validateName(firstNameController.text.trim());
    String? lastNameError =
        Validator.validateName(lastNameController.text.trim());
    String? fatherNameError =
        Validator.validateName(fatherNameController.text.trim());
    String? motherNameError =
        Validator.validateFullname(motherNameController.text.trim());
    String? dobError =
        Validator.validateDateOfBirth(dateOfBirthController.text.trim());
    String? emailError = Validator.validateEmail(emailController.text.trim());
    String? passwordError = Validator.validatePassword(passwordController.text);

    if (firstNameError != null ||
        lastNameError != null ||
        fatherNameError != null ||
        motherNameError != null ||
        dobError != null ||
        emailError != null ||
        passwordError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("يرجى التأكد من صحة البيانات")));
      return;
    }

    setState(() => isLoading = true);

    String result = await AuthService().signUpUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        fatherName: fatherNameController.text.trim(),
        motherName: motherNameController.text.trim(),
        dateOfBirth: dateOfBirthController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: role,
        profileImage: profileImage,
        specialty: specialty,
        context: context);

    setState(() => isLoading = false);

    if (result == "success") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("تم إنشاء الحساب بنجاح")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        DateTime selectedDate = DateTime(2000);

        return CustomContainer(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime(2000),
                    minimumDate: DateTime(1915),
                    maximumDate:
                        DateTime.now().subtract(Duration(days: 365 * 18)),
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime dateTime) {
                      selectedDate = dateTime;
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    padding:
                        EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
                    onPressed: () => Navigator.pop(context),
                    text: "إلغاء",
                  ),
                  CustomButton(
                    padding:
                        EdgeInsets.symmetric(horizontal: 48.0, vertical: 8.0),
                    onPressed: () {
                      setState(() {
                        dateOfBirthController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                      Navigator.pop(context);
                    },
                    text: "تأكيد",
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: ('إنشاء حساب'),
      ),
      body: CustomConstrainedBox(
        title: 'إنشاء حساب جديد',
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(
                labelText: "اختر الدور",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "طالب", child: Text("طالب")),
                DropdownMenuItem(value: "أستاذ", child: Text("أستاذ")),
              ],
              onChanged: (value) => setState(() => role = value!),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 100,
                backgroundImage:
                    profileImage != null ? MemoryImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'الاسم الأول',
                border: OutlineInputBorder(),
                errorText: Validator.validateName(firstNameController.text),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'الكنية',
                border: OutlineInputBorder(),
                errorText: Validator.validateName(lastNameController.text),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fatherNameController,
              decoration: InputDecoration(
                labelText: 'اسم الأب',
                border: OutlineInputBorder(),
                errorText: Validator.validateName(fatherNameController.text),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motherNameController,
              decoration: InputDecoration(
                labelText: 'اسم الأم وكنيتها',
                border: OutlineInputBorder(),
                errorText:
                    Validator.validateFullname(motherNameController.text),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateOfBirthController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'تاريخ الميلاد',
                border: OutlineInputBorder(),
              ),
              onTap: () => _showDatePicker(context),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
                errorText: Validator.validateEmail(emailController.text),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
                errorText: Validator.validatePassword(passwordController.text),
              ),
            ),
            const SizedBox(height: 24),
            if (role == "طالب") ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: specialty,
                hint: Text("اختر الاختصاص"),
                decoration: const InputDecoration(
                  labelText: "الاختصاص",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: "الهندسة المعلوماتية",
                      child: Text("الهندسة المعلوماتية")),
                  DropdownMenuItem(
                      value: "الطب البشري", child: Text("الطب البشري")),
                  DropdownMenuItem(
                      value: "طب الأسنان", child: Text("طب الأسنان")),
                  DropdownMenuItem(value: "الصيدلة", child: Text("الصيدلة")),
                ],
                onChanged: (value) => setState(() => specialty = value),
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              onPressed: isLoading ? () {} : _signUp,
              text: isLoading ? "جاري التسجيل..." : "إنشاء الحساب",
            )
          ],
        ),
      ),
      backgroundColor: AppColors.primary,
    );
  }
}
