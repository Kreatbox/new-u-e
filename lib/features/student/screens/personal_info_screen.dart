import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';

class PersonalInfoScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const PersonalInfoScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController fatherNameController;
  late TextEditingController motherNameController;
  late TextEditingController dateOfBirthController;
  late TextEditingController emailController;
  late TextEditingController verifiedController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    firstNameController = TextEditingController(text: user?.firstName);
    lastNameController = TextEditingController(text: user?.lastName);
    fatherNameController = TextEditingController(text: user?.fatherName);
    motherNameController = TextEditingController(text: user?.motherName);
    dateOfBirthController = TextEditingController(text: user?.dateOfBirth);
    emailController = TextEditingController(text: user?.email);
    verifiedController = TextEditingController(text: user?.verified.toString());
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    dateOfBirthController.dispose();
    emailController.dispose();
    verifiedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return CustomContainer(
      gradientColors: widget.gradientColors,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      child: ListView(
        children: [
          Text(
            "البيانات الشخصية",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: MemoryImage(base64Decode(user!.profileImage)),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: MediaQuery.of(context).size.width > 800 ? 60.0 : 0,
            ),
            child: Column(
              children: [
                CustomListItem(
                  additionalTitles: ['الاسم'],
                  additionalDescriptions: [firstNameController.text],
                  gradientColors: widget.gradientColors,
                  begin: widget.begin,
                  end: widget.end,
                ),
                CustomListItem(
                  additionalTitles: ['الكنية'],
                  additionalDescriptions: [lastNameController.text],
                  gradientColors: widget.gradientColors,
                  begin: widget.begin,
                  end: widget.end,
                ),
                CustomListItem(
                  additionalTitles: ['اسم الأب'],
                  additionalDescriptions: [fatherNameController.text],
                  gradientColors: widget.gradientColors,
                  begin: widget.begin,
                  end: widget.end,
                ),
                CustomListItem(
                  additionalTitles: ['اسم الأم'],
                  additionalDescriptions: [motherNameController.text],
                  gradientColors: widget.gradientColors,
                  begin: widget.begin,
                  end: widget.end,
                ),
                CustomListItem(
                  additionalTitles: ['تاريخ الميلاد'],
                  additionalDescriptions: [dateOfBirthController.text],
                  gradientColors: widget.gradientColors,
                  begin: widget.begin,
                  end: widget.end,
                ),
                CustomListItem(
                  additionalTitles: ['البريد الإلكتروني'],
                  additionalDescriptions: [emailController.text],
                  gradientColors: widget.gradientColors,
                  begin: widget.begin,
                  end: widget.end,
                ),
                CustomListItem(
                  additionalTitles: ['الحساب فعال'],
                  additionalDescriptions: [verifiedController.text],
                  gradientColors: widget.gradientColors,
                  begin: widget.begin,
                  end: widget.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
