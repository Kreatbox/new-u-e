import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_exam/core/providers/app_provider.dart';
import 'package:universal_exam/core/providers/user_provider.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/widgets/app_bar.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/calendar.dart';
import 'package:universal_exam/shared/widgets/card.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'package:universal_exam/shared/widgets/dropdown_list.dart';
import '../auth/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = Provider.of<UserProvider>(context).user;

    if (appProvider.loading) {
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
          padding: EdgeInsets.zero,
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
                  final examEvents = appProvider.examEvents;
                  final topStudents = appProvider.topStudents;
                  final topTeachers = appProvider.topTeachers;

                  if (constraints.maxWidth < 800) {
                    return Column(
                      children: [
                        CustomCalendar(
                            initialEvents: examEvents, doesReturn: false),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (topStudents.isNotEmpty)
                              LeaderboardCard(leaders: topStudents),
                            if (topStudents.isNotEmpty &&
                                topTeachers.isNotEmpty)
                              const SizedBox(width: 4),
                            if (topTeachers.isNotEmpty)
                              LeaderboardCard(leaders: topTeachers),
                          ],
                        )
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomCalendar(
                              initialEvents: examEvents, doesReturn: false),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (topStudents.isNotEmpty)
                                LeaderboardCard(leaders: topStudents),
                              if (topStudents.isNotEmpty &&
                                  topTeachers.isNotEmpty)
                                const SizedBox(width: 4),
                              if (topTeachers.isNotEmpty)
                                LeaderboardCard(leaders: topTeachers),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 4),
              CustomContainer(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    '© 2025 نظام الامتحان الموحد - جميع الحقوق محفوظة',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
