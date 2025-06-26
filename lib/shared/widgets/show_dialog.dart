import 'package:flutter/material.dart';
import '../../core/models/exam_model.dart';
import 'button.dart';
import 'container.dart';

class CustomShowDialog extends StatelessWidget {
  final String title;
  final String description;
  final Map<String, String> userDetails;
  final List<Exam> exams;
  final String profileImageUrl;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const CustomShowDialog({
    required this.title,
    required this.description,
    required this.userDetails,
    required this.exams,
    required this.profileImageUrl,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CustomContainer(
        gradientColors: gradientColors,
        begin: begin,
        end: end,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: userDetails.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(
                      "${entry.key}: ${entry.value}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (exams.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  "الامتحانات:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                ...exams.map((exam) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      "${exam.name}: ${exam.grade}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ],
              SizedBox(height: 20),
              CustomButton(
                text: "إغلاق",
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                gradientColors: gradientColors,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
