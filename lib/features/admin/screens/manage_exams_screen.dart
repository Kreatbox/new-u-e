import 'package:flutter/material.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/list_item.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/time_picker.dart';
import '../controllers/admin_controller.dart';

class ManageExamsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final AdminController controller;

  const ManageExamsScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<ManageExamsScreen> createState() => _ManageExamsScreenState();
}

class _ManageExamsScreenState extends State<ManageExamsScreen> {
  List<String> subjects = ['معلوماتية', 'طب أسنان', 'طب بشري'];
  List<String> examTypes = ['صعب', 'سهل'];
  late TimeOfDay selectedTime;
  late DateTime selectedDate;

  String? selectedSubject;
  String? selectedExamType;
  int numberOfQuestions = 30;
  int examDuration = 60;

  List<Map<String, dynamic>> exams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay(hour: 9, minute: 0);
    selectedDate = DateTime(2000, 1, 1, 0, 0);
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await widget.controller.fetchExams();
      setState(() {
        exams = data;
        isLoading = false;
      });
    } catch (e) {
      print('خطأ أثناء تحميل الامتحانات: $e');
      setState(() {
        isLoading = false;
      });
    }
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

  Future<void> _createExam() async {
    if (selectedSubject == null || selectedExamType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المادة ونوع الامتحان')),
      );
      return;
    }
    await widget.controller.createExam(
      subject: selectedSubject!,
      examType: selectedExamType!,
      startTime: selectedDate,
      numberOfQuestions: numberOfQuestions,
      examDuration: examDuration,
    );
    await _loadExams();
  }

  Future<void> _approveExam(Map<String, dynamic> exam) async {
    await widget.controller.approveExam(exam['id']);
    await _loadExams();
  }

  Future<void> _editExamDate(
      Map<String, dynamic> exam, DateTime newDateTime) async {
    await widget.controller.editExamDate(exam['id'], newDateTime);
    await _loadExams();
  }

  void _showExamDetails(Map<String, dynamic> exam) {
    DateTime? newDateTime;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
          title: exam['subject'],
          description: "تفاصيل الامتحان وإدارته",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الحالة الحالية: ${exam['status']}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "الموعد الحالي: ${exam['startTime']}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              CustomButton(
                gradientColors: widget.gradientColors,
                onPressed: () {
                  _approveExam(exam);
                  Navigator.pop(context);
                },
                text: "الموافقة على الموعد",
              ),
              const SizedBox(height: 10),
              CustomButton(
                gradientColors: widget.gradientColors,
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return CustomCupertinoTimePicker(
                        gradientColors: widget.gradientColors,
                        begin: widget.begin,
                        end: widget.end,
                        initialTime: TimeOfDay.fromDateTime(exam['startTime']),
                        onTimeSelected: (DateTime newTime) {
                          newDateTime = newTime;
                        },
                      );
                    },
                  );
                  if (newDateTime != null) {
                    await _editExamDate(exam, newDateTime!);
                  }
                  Navigator.pop(context);
                },
                text: "تعديل الموعد",
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                CustomContainer(
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
                            'إعدادات الامتحانات',
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
                                  MediaQuery.of(context).size.width < 700
                                      ? 8.0
                                      : 32.0,
                            ),
                            gradientColors: widget.gradientColors,
                            begin: widget.begin,
                            end: widget.end,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'اختيار المادة:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: _onQuestionCountChanged,
                                  decoration: InputDecoration(
                                    labelText: 'عدد الأسئلة',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                      text: '$numberOfQuestions'),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'مدة الامتحان (دقائق):',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: _onDurationChanged,
                                  decoration: InputDecoration(
                                    labelText: 'المدة بالدقائق',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                      text: '$examDuration'),
                                ),
                                SizedBox(height: 32),
                                CustomButton(
                                  text: 'حفظ التعديلات',
                                  onPressed: _createExam,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomContainer(
                    gradientColors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
                    padding: EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal:
                          MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: exams.length,
                      itemBuilder: (context, index) {
                        final exam = exams[index];
                        return CustomListItem(
                          title: exam['subject'],
                          additionalTitles: ["الموعد", "الحالة"],
                          additionalDescriptions: [
                            exam['startTime'].toString().substring(0, 16),
                            exam['status']
                          ],
                          gradientColors: widget.gradientColors,
                          begin: widget.begin,
                          end: widget.end,
                          trailingIcon: Icon(
                            exam['status'] == "Pending"
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle,
                            color: exam['status'] == "Pending"
                                ? Colors.orange
                                : Colors.green,
                          ),
                          onPressed: () => _showExamDetails(exam),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
