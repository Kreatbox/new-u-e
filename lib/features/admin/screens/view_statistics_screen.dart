import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/container.dart';

class ViewStatisticsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const ViewStatisticsScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    Key? key,
  }) : super(key: key);

  @override
  State<ViewStatisticsScreen> createState() => _ViewStatisticsScreenState();
}

class _ViewStatisticsScreenState extends State<ViewStatisticsScreen> {
  List<Map<String, dynamic>> studentGrades = [
    {
      'subject': 'رياضيات',
      'grades': [80, 75, 90, 85]
    },
    {
      'subject': 'فيزياء',
      'grades': [60, 65, 70, 50]
    },
    {
      'subject': 'كيمياء',
      'grades': [90, 95, 80, 88]
    },
    {
      'subject': 'أحياء',
      'grades': [85, 88, 80, 92]
    },
  ];

  String selectedSubject = 'جميع المواد';

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barChartData = studentGrades.map((subjectData) {
      List<int> validGrades =
          List<int>.from(subjectData['grades'].whereType<int>());
      return BarChartGroupData(
        x: studentGrades.indexOf(subjectData),
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: validGrades.isNotEmpty
                ? validGrades.reduce((a, b) => a + b) / validGrades.length
                : 0, // إذا كانت القائمة فارغة، اجعل القيمة 0
            color: AppColors.primary,
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'عرض الإحصائيات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedSubject,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubject = newValue!;
                    });
                  },
                  items: ['جميع المواد', 'رياضيات', 'فيزياء', 'كيمياء', 'أحياء']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true, border: Border.all()),
                barGroups: barChartData,
                alignment: BarChartAlignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
