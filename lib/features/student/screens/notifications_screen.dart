import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';

class NotificationsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const NotificationsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final notifications = [
    {
      'title': 'مواعيد الامتحانات',
      'message': 'الامتحان القادم في 30 يناير 2025',
      'date': '2025-01-25'
    },
    {
      'title': 'نتائج الامتحانات',
      'message': 'تم نشر نتائج امتحان الرياضيات',
      'date': '2025-01-22'
    },
    {
      'title': 'تحديثات النظام',
      'message': 'تم تعديل مواعيد الامتحانات',
      'date': '2025-01-21'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      child: ListView(
        children: [
          Text(
            "الإشعارات",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              ...notifications.map((notification) {
                return GestureDetector(
                  onTap: () {},
                  child: CustomListItem(
                    title: notification['title']!,
                    description: notification['message']!,
                    gradientColors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
