import 'package:flutter/material.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/list_item.dart';

class ExamsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const ExamsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  _ExamsScreenState createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  @override
  Widget build(BuildContext context) {
    final upcomingExams = [
      {'name': 'امتحان الرياضيات', 'date': '2025-01-30', 'time': '10:00 AM'},
      {'name': 'امتحان الفيزياء', 'date': '2025-02-05', 'time': '12:00 PM'},
    ];

    final pastExams = [
      {
        'name': 'امتحان الكيمياء',
        'date': '2025-01-10',
        'score': '85%',
        'reviewLink': '#'
      },
      {
        'name': 'امتحان اللغة العربية',
        'date': '2025-01-15',
        'score': '92%',
        'reviewLink': '#'
      },
    ];

    return CustomContainer(
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      child: ListView(
        children: [
          Text(
            "الامتحانات",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _sectionTitle("الامتحانات القادمة"),
                const SizedBox(height: 10),
                ...upcomingExams.map((exam) {
                  return CustomListItem(
                    title: exam['name']!,
                    additionalTitles: ['تاريخ', 'الوقت'],
                    additionalDescriptions: [exam['date']!, exam['time']!],
                    gradientColors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
                    trailingIcon: Icon(
                      Icons.event_available,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _sectionTitle("الامتحانات السابقة"),
                const SizedBox(height: 10),
                ...pastExams.map((exam) {
                  return CustomListItem(
                    title: exam['name']!,
                    additionalTitles: ['تاريخ', 'الدرجة'],
                    additionalDescriptions: [exam['date']!, exam['score']!],
                    gradientColors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
                    trailingIcon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    onPressed: () {},
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: AppColors.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
