import 'package:flutter/material.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/time_picker.dart';
import '../controllers/admin_controller.dart';

class SystemSettingsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final AdminController controller;

  const SystemSettingsScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  List<String> subjects = ['رياضيات', 'فيزياء', 'كيمياء', 'أحياء'];
  List<String> examTypes = ['صعب', 'سهل'];
  late TimeOfDay selectedTime;
  late DateTime selectedDate;

  String? selectedSubject;
  String? selectedExamType;
  int numberOfQuestions = 30;
  int examDuration = 60;

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay(hour: 9, minute: 0);
    selectedDate = DateTime(2000, 1, 1, 0, 0);
  }

  void _onSubjectChanged(String? value) {
    setState(() {
      selectedSubject = value;
    });
  }

  void _onExamTypeChanged(String? value) {
    setState(() {
      selectedExamType = value;
    });
  }

  void _onQuestionCountChanged(String value) {
    setState(() {
      numberOfQuestions = int.tryParse(value) ?? 30;
    });
  }

  void _onDurationChanged(String value) {
    setState(() {
      examDuration = int.tryParse(value) ?? 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'إعدادات النظام',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16),
              CustomContainer(
                padding: EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal:
                      MediaQuery.of(context).size.width < 700 ? 8.0 : 32.0,
                ),
                gradientColors: widget.gradientColors,
                begin: widget.begin,
                end: widget.end,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختيار المادة:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: selectedSubject,
                      onChanged: _onSubjectChanged,
                      hint: Text('اختر المادة'),
                      items: subjects.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'نوع الامتحان:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: selectedExamType,
                      onChanged: _onExamTypeChanged,
                      hint: Text('اختر نوع الامتحان'),
                      items: examTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'وقت بداية الامتحان: ${selectedDate == DateTime(2000, 1, 1, 0, 0) ? ' ' : selectedDate}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    CustomCupertinoTimePicker(
                      gradientColors: widget.gradientColors,
                      begin: widget.begin,
                      end: widget.end,
                      initialTime: selectedTime,
                      onTimeSelected: (DateTime newTime) {
                        setState(() {
                          selectedDate = newTime;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'عدد الأسئلة:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: _onQuestionCountChanged,
                      decoration: InputDecoration(
                        labelText: 'عدد الأسئلة',
                        border: OutlineInputBorder(),
                      ),
                      controller:
                          TextEditingController(text: '$numberOfQuestions'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'مدة الامتحان (دقائق):',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: _onDurationChanged,
                      decoration: InputDecoration(
                        labelText: 'المدة بالدقائق',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: '$examDuration'),
                    ),
                    SizedBox(height: 32),
                    CustomButton(
                      text: 'حفظ التعديلات',
                      onPressed: () async {
                        if (selectedSubject != null &&
                            selectedExamType != null &&
                            selectedDate != DateTime(2000, 1, 1, 0, 0)) {
                          await widget.controller.createExam(
                            subject: selectedSubject!,
                            examType: selectedExamType!,
                            startTime: selectedDate,
                            numberOfQuestions: numberOfQuestions,
                            examDuration: examDuration,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
