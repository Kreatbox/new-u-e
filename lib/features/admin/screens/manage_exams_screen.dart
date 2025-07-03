import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_exam/core/providers/user_provider.dart';
import 'package:universal_exam/shared/widgets/calendar.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/list_item.dart';
import '../../../shared/theme/colors.dart';
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
  List<String> subjects = [
    "الطب البشري",
    "طب الأسنان",
    "الصيدلة",
    "الهندسة المعلوماتية"
  ];
  List<String> examTypes = ['صعب', 'سهل'];
  late DateTime selectedDateTime;
  String? selectedSubject;
  String? selectedExamType;
  int numberOfQuestions = 30;
  int examDuration = 60;
  List<Map<String, dynamic>> exams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now().add(Duration(days: 1));
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await widget.controller.fetchExams();
      setState(() {
        exams = data.cast<Map<String, dynamic>>();
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

    final adminUid = UserProvider().user!.id;

    await widget.controller.createExam(
      specialty: selectedSubject!,
      examType: selectedExamType!,
      startTime: selectedDateTime,
      numberOfQuestions: numberOfQuestions,
      examDuration: examDuration,
      adminUid: adminUid,
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
                "الموعد الحالي: ${exam['startTime'].toDate().toString().substring(0, 16)}",
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
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: exam['startTime'].toDate(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    final timeOfDay = await showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay.fromDateTime(exam['startTime'].toDate()),
                    );
                    if (timeOfDay != null) {
                      final newDateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        timeOfDay.hour,
                        timeOfDay.minute,
                      );
                      await _editExamDate(exam, newDateTime);
                    }
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

  void _selectDateTime(BuildContext context) {
    DateTime? tempDate;
    TimeOfDay? tempTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return CustomContainer(
              padding: EdgeInsets.all(16),
              gradientColors: widget.gradientColors,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر التاريخ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4),
                  CustomCalendar(
                    doesReturn: false,
                    minSelectableDate: DateTime.now(),
                    maxSelectableDate: DateTime.now().add(Duration(days: 365)),
                    disableHolidays: true,
                    onDateSelected: (date) {
                      setStateModal(() {
                        tempDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          tempTime?.hour ?? selectedDateTime.hour,
                          tempTime?.minute ?? selectedDateTime.minute,
                        );
                      });
                    },
                  ),

                  // Only show time picker after date is picked
                  if (tempDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'اختر الوقت',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        CustomContainer(
                          padding:
                              EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                          height: 150,
                          gradientColors: [
                            AppColors.highlight,
                            AppColors.primary
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                              textTheme: CupertinoTextThemeData(
                                dateTimePickerTextStyle: TextStyle(
                                  fontFamily: 'HSI',
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: DateTime(2000),
                              onDateTimeChanged: (DateTime newTime) {
                                setStateModal(() {
                                  tempTime = TimeOfDay.fromDateTime(newTime);
                                  tempDate = DateTime(
                                    tempDate!.year,
                                    tempDate!.month,
                                    tempDate!.day,
                                    newTime.hour,
                                    newTime.minute,
                                  );
                                });
                              },
                              minimumDate: DateTime(2000, 1, 1, 8),
                              maximumDate: DateTime(2000, 1, 1, 16),
                              minuteInterval: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (tempTime != null)
                    Column(
                      children: [
                        SizedBox(height: 16),
                        CustomButton(
                          text: 'تم',
                          onPressed: () {
                            setState(() {
                              selectedDateTime = tempDate!;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )
                ],
              ),
            );
          },
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            horizontal: MediaQuery.of(context).size.width < 700
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                                'وقت بداية الامتحان: ${selectedDateTime.toString().substring(0, 16)}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              CustomButton(
                                text: 'اختر التاريخ والوقت',
                                onPressed: () => _selectDateTime(context),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'عدد الأسئلة:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                            exam['startTime']
                                .toDate()
                                .toString()
                                .substring(0, 16),
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
