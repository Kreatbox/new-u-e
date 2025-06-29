import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/app_bar.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/calendar.dart';
import '../../shared/widgets/card.dart';
import '../../shared/widgets/container.dart';
import '../../shared/widgets/dropdown_list.dart';
import '../auth/auth_service.dart';
import 'home_service.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();

  List<Map<String, dynamic>> bestStudents = [];
  List<Map<String, dynamic>> bestTeachers = [];
  Map<DateTime, List<String>> events = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final students = await _homeService.getBestStudents();
    final teachers = await _homeService.getBestTeachers();
    final evnts = await _homeService.getEvents();

    setState(() {
      bestStudents = students;
      bestTeachers = teachers;
      events = evnts;
      isLoading = false;
    });
  }

  Image imageFromBase64String(String base64String) {
    try {
      return Image.memory(base64Decode(base64String));
    } catch (e) {
      return Image.asset('assets/default_avatar.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'نظام الامتحان الموحد',
        actions: [
          if (user != null) ...[
            if (user.role == 'طالب') ...[
              IntrinsicHeight(
                child: CustomButton(
                  text: "صفحة المستخدم",
                  onPressed: () => Navigator.pushNamed(context, '/student'),
                ),
              ),
              const SizedBox(width: 16),
              IntrinsicHeight(
                child: CustomButton(
                  text: 'البرنامج',
                  onPressed: () => Navigator.pushNamed(context, '/exam'),
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (user.role == 'أستاذ') ...[
               IntrinsicHeight(
                                child: CustomButton(
                  text: "صفحة المستخدم",
                  onPressed: () => Navigator.pushNamed(context, '/student'),
                ),
              ),
              const SizedBox(width: 16),
              IntrinsicHeight(
                child: CustomButton(
                  text: "صفحة الأستاذ",
                  onPressed: () => Navigator.pushNamed(context, '/teacher'),
                ),
              ),
              const SizedBox(width: 16),
              IntrinsicHeight(
                child: CustomButton(
                  text: 'البرنامج',
                  onPressed: () => Navigator.pushNamed(context, '/exam'),
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (user.role == 'مدير') ...[
              IntrinsicHeight(
                child: CustomButton(
                  text: "صفحة المدير",
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                ),
              ),
              const SizedBox(width: 16),

            ],
            IntrinsicHeight(
              child: CustomButton(
                text: "تسجيل خروج",
                onPressed: () async {
                  await AuthService().signOut(context);
                  context.read<UserProvider>().clearUserData();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ),
            const SizedBox(width: 16),
          ] else ...[
            IntrinsicHeight(
              child: CustomDropdownMenu(
                items: ['تسجيل دخول', 'انشاء حساب'],
                onItemSelected: (selected) {
                  if (selected == 'انشاء حساب') {
                    Navigator.pushNamed(context, '/sign_up');
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                },
                buttonText: 'تسجيل دخول',
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: CustomContainer(
          padding: EdgeInsets.all(0),
          gradientColors: [AppColors.primary, AppColors.lightSecondary],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CustomContainer(
                  gradientColors: const [
                    AppColors.lightSecondary,
                    AppColors.highlight,
                    AppColors.lightSecondary
                  ],
                  height: 150,
                  child: Center(
                    child: Text(
                      'مرحبًا بك في نظام الامتحان الموحد',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return Wrap(
                      children: [
                        CustomCalendar(events: events),
                        Wrap(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CustomCard(
                                persons: bestStudents.map((student) {
                                  return {
                                    "title": student['title'],
                                    "name": student['name'],
                                    "score": student['score'],
                                    "imageWidget": imageFromBase64String(
                                        student['imageBase64']),
                                  };
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CustomCard(
                                persons: bestTeachers.map((teacher) {
                                  return {
                                    "title": teacher['title'],
                                    "name": teacher['name'],
                                    "subject": teacher['subject'],
                                    "imageWidget": imageFromBase64String(
                                        teacher['imageBase64']),
                                  };
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: CustomCalendar(events: events),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: CustomCard(
                                  persons: bestStudents.map((student) {
                                    return {
                                      "title": student['title'],
                                      "name": student['name'],
                                      "score": student['score'],
                                      "imageWidget": imageFromBase64String(
                                          student['imageBase64']),
                                    };
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: CustomCard(
                                  persons: bestTeachers.map((teacher) {
                                    return {
                                      "title": teacher['title'],
                                      "name": teacher['name'],
                                      "subject": teacher['subject'],
                                      "imageWidget": imageFromBase64String(
                                          teacher['imageBase64']),
                                    };
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
