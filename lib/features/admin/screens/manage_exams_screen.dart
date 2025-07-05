import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_exam/shared/widgets/calendar.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/list_item.dart';
import '../../../shared/theme/colors.dart';
import '../controllers/admin_controller.dart';
import '../../../core/models/exam_model.dart';

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
  List<Exam> exams = [];
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
      if (!mounted) return;
      setState(() {
        exams = data;
        isLoading = false;
      });
    } catch (e) {
      print('خطأ أثناء تحميل الامتحانات: $e');
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المادة ونوع الامتحان')),
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ في جلب بيانات المستخدم')),
      );
      return;
    }

    final String adminUid = user.uid;

    if (!mounted) return;

    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => CustomContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("جاري إنشاء الامتحان..."),
              ],
            ),
          ),
        ),
      );

      await widget.controller.createExam(
          specialty: selectedSubject!,
          startTime: selectedDateTime,
          numberOfQuestions: numberOfQuestions,
          examDuration: examDuration,
          adminUid: adminUid);

      if (!mounted) return;
      Navigator.pop(context);

      await _loadExams();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء الامتحان بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إنشاء الامتحان: $e')),
      );
    }
  }

  Future<void> _approveExam(Exam exam) async {
    await widget.controller.approveExam(exam.id);
    if (mounted) await _loadExams();
  }

  Future<void> _editExamDate(Exam exam, DateTime newDateTime) async {
    await widget.controller.editExamDate(exam.id, newDateTime);
    if (mounted) await _loadExams();
  }

  void _showExamDetails(Exam exam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
          title: exam.title,
          description: "تفاصيل الامتحان وإدارته",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الحالة: ${exam.status}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "الموعد: ${exam.date.toString().substring(0, 16)}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "المدة: ${exam.duration} دقيقة",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "عدد الأسئلة: ${exam.questionsPerStudent}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (exam.canBeEdited) ...[
                if (!exam.isActive)
                  CustomButton(
                    gradientColors: widget.gradientColors,
                    onPressed: () {
                      _approveExam(exam);
                      Navigator.pop(context);
                    },
                    text: "الموافقة على الموعد",
                  ),
                if (!exam.isActive) const SizedBox(height: 10),
                CustomButton(
                  gradientColors: widget.gradientColors,
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: exam.date,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      final timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(exam.date),
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
                const SizedBox(height: 10),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    exam.calculated 
                        ? "لا يمكن تعديل الامتحان بعد اكتماله"
                        : "لا يمكن تعديل الامتحان بعد بدايته",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (exam.canBeDeleted)
                CustomButton(
                  gradientColors: [Colors.red, Colors.redAccent],
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: const Text('هل أنت متأكد من حذف هذا الامتحان؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      try {
                        await widget.controller.deleteExam(exam.id);
                        Navigator.pop(context);
                        await _loadExams();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم حذف الامتحان بنجاح')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل في حذف الامتحان: $e')),
                          );
                        }
                      }
                    }
                  },
                  text: "حذف الامتحان",
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

  Widget _getStatusIcon(Exam exam) {
    if (exam.calculated) {
      return Icon(Icons.task_alt, color: Colors.green);
    } else if (exam.isFinished) {
      return Icon(Icons.schedule, color: Colors.blue);
    } else if (exam.isStarted) {
      return Icon(Icons.play_circle, color: Colors.orange);
    } else if (exam.isActive) {
      return Icon(Icons.check_circle, color: Colors.green);
    } else {
      return Icon(Icons.warning_amber_rounded, color: Colors.orange);
    }
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
                          title: exam.title,
                          additionalTitles: ["الموعد", "الحالة"],
                          additionalDescriptions: [
                            exam.date.toString().substring(0, 16),
                            exam.status
                          ],
                          gradientColors: widget.gradientColors,
                          begin: widget.begin,
                          end: widget.end,
                          trailingIcon: _getStatusIcon(exam),
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
