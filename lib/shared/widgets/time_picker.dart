import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_exam/features/home/home_service.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/calendar.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'package:universal_exam/shared/theme/colors.dart';

class CustomCupertinoTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<DateTime> onTimeSelected;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  CustomCupertinoTimePicker({
    required this.initialTime,
    required this.onTimeSelected,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  _CustomCupertinoTimePickerState createState() =>
      _CustomCupertinoTimePickerState();
}

class _CustomCupertinoTimePickerState extends State<CustomCupertinoTimePicker> {
  late DateTime selectedTime;
  DateTime? _selectedCalendarDate;
  Map<DateTime, List<String>> events = {};
  bool selected = false;
  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    selectedTime = DateTime(
        2000, 1, 1, widget.initialTime.hour, widget.initialTime.minute);
    _selectedCalendarDate = DateTime.now();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final fetchedEvents = await _homeService.getEvents();
    setState(() {
      events = fetchedEvents;
    });
  }

  void _onDateTimeChanged(DateTime newTime) {
    setState(() {
      selectedTime = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'حدد التاريخ والوقت',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: CustomContainer(
                padding: EdgeInsets.all(16.0),
                gradientColors: widget.gradientColors,
                begin: widget.begin,
                end: widget.end,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر التاريخ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    SizedBox(height: 4),
                    CustomCalendar(
                      events: events,
                      doesReturn: true,
                      minSelectableDate: DateTime.now(),
                      maxSelectableDate: DateTime(2026),
                      disableHolidays: true,
                      onDateSelected: (selectedDate) {
                        setState(() {
                          _selectedCalendarDate = selectedDate;
                          selected = true;
                        });
                      },
                    ),
                    SizedBox(height: 4),
                    Text(
                      'اختر الوقت',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    SizedBox(height: 4),
                    CustomContainer(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                      height: 150,
                      gradientColors: widget.gradientColors,
                      begin: widget.end,
                      end: widget.begin,
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: selectedTime,
                          onDateTimeChanged: _onDateTimeChanged,
                          minimumDate: DateTime(2000, 1, 1, 8),
                          maximumDate: DateTime(2000, 1, 1, 16),
                          minuteInterval: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    (selected)
                        ? CustomButton(
                            text: 'تم',
                            onPressed: () {
                              DateTime combined = DateTime(
                                _selectedCalendarDate?.year ??
                                    DateTime.now().year,
                                _selectedCalendarDate?.month ??
                                    DateTime.now().month,
                                _selectedCalendarDate?.day ??
                                    DateTime.now().day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                              widget.onTimeSelected(combined);
                              Navigator.pop(context);
                            },
                          )
                        : SizedBox(height: 4),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
