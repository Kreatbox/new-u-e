// Shows detailed profile info for TopStudent or TopTeacher.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_exam/core/models/user_info_model.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'package:universal_exam/shared/theme/colors.dart';

class CustomShowDialog extends StatelessWidget {
  final UserInfo userInfo;
  final String title;
  final String description;

  const CustomShowDialog({
    super.key,
    required this.userInfo,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomContainer(
        gradientColors: [
          AppColors.lightSecondary,
          AppColors.highlight,
          AppColors.lightSecondary
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _buildImage(),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              _infoRow("الاسم", userInfo.fullName),
              _infoRow("التخصص", userInfo.specialty),
              SizedBox(height: 20),
              CustomButton(
                text: "إغلاق",
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                gradientColors: [
                  AppColors.primary,
                  AppColors.highlight,
                  AppColors.primary,
                ],
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  ImageProvider _buildImage() {
    if (userInfo.profileImage.isEmpty) {
      return AssetImage('assets/images/default_avatar.png');
    }

    try {
      final bytes = base64Decode(userInfo.profileImage);
      return MemoryImage(bytes);
    } catch (e) {
      return AssetImage('assets/images/default_avatar.png');
    }
  }
}
