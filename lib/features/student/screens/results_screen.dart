import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';

class ResultsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final bool isStudent;

  const ResultsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.isStudent,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<Map<String, String>> results;

  @override
  void initState() {
    super.initState();
    if (widget.isStudent) {
      _loadStudentResults();
    } else {
      _loadTeacherResults();
    }
  }

  void _loadStudentResults() {
    results = [
      {
        'name': 'امتحان الرياضيات',
        'score': '90%',
        'rank': '5',
        'date': '2025-01-20',
      },
      {
        'name': 'امتحان الفيزياء',
        'score': '80%',
        'rank': '12',
        'date': '2025-01-18',
      },
    ];
  }

  void _loadTeacherResults() {
    results = [
      {
        'name': 'متوسط نجاح الطلاب',
        'score': '75%',
        'total': '150',
        'date': '2025-01-20',
      },
      {
        'name': 'أفضل سؤال',
        'score': '85%',
        'total': '150',
        'date': '2025-01-18',
      },
      {
        'name': 'أسوأ سؤال',
        'score': '45%',
        'total': '150',
        'date': '2025-01-18',
      },
    ];
  }

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
            widget.isStudent ? "النتائج" : "إحصائيات النتائج",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: results.map((result) {
              return Column(
                children: [
                  CustomListItem(
                    title: result['name']!,
                    additionalTitles: widget.isStudent 
                        ? ['النتيجة', 'الترتيب', 'التاريخ']
                        : ['النسبة', 'الإجمالي', 'التاريخ'],
                    additionalDescriptions: [
                      result['score']!,
                      result[widget.isStudent ? 'rank' : 'total']!,
                      result['date']!,
                    ],
                    gradientColors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
                    trailingIcon: Icon(
                      widget.isStudent ? Icons.grade : Icons.analytics,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
