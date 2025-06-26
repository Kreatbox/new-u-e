import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';

class ResultsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const ResultsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<Map<String, String>> results;

  @override
  void initState() {
    super.initState();
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
            "النتائج",
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
                    additionalTitles: [
                      'النتيجة',
                      'الترتيب',
                      'التاريخ',
                    ],
                    additionalDescriptions: [
                      result['score']!,
                      result['rank']!,
                      result['date']!,
                    ],
                    gradientColors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
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
