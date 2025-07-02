// Combines TimeOfDay from picker with date from calendar into one DateTime.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_exam/shared/widgets/calendar.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'package:universal_exam/shared/theme/colors.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.initialDate,
    required this.onDateTimeSelected,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime;
  }

  void _onDatePicked(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
  }

  void _onTimeChanged(TimeOfDay newTime) {
    setState(() {
      selectedTime = newTime;
    });
  }

  DateTime _combine() {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CustomContainer(
        padding: EdgeInsets.all(16),
        gradientColors: [
          AppColors.primary,
          AppColors.highlight,
          AppColors.primary
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              doesReturn: true,
              minSelectableDate: DateTime.now(),
              maxSelectableDate: DateTime(2026),
              disableHolidays: true,
              onDateSelected: _onDatePicked,
            ),
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
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              height: 150,
              gradientColors: [AppColors.highlight, AppColors.primary],
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
                  onDateTimeChanged: (DateTime newTime) {
                    _onTimeChanged(TimeOfDay.fromDateTime(newTime));
                  },
                  minimumDate: DateTime(2000, 1, 1, 8, 0),
                  maximumDate: DateTime(2000, 1, 1, 16, 0),
                  minuteInterval: 15,
                ),
              ),
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'تم',
              onPressed: () {
                final combined = _combine();
                widget.onDateTimeSelected(combined);
              },
            ),
          ],
        ),
      ),
    );
  }
}
